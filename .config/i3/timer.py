#!/usr/bin/env python3
# Copyright (C) 2024-2025 taylor.fish <contact@taylor.fish>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
#
# Parts of this file were derived from HyperTimer
# (https://codeberg.org/unfa/HyperTimer), which is covered by the
# following copyright and license notice:
#
#   HyperTimer
#   Copyright (C) 2023  unfa
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <https://www.gnu.org/licenses/>.

from dataclasses import dataclass
from typing import assert_type, Optional, Self
import bisect
import fcntl
import json
import io
import itertools
import os
import re
import select
import subprocess
import sys
import time

WIDTH = 800
ASSUMED_CHAR_WIDTH = 7
FIFO_PATH = os.path.join(os.path.dirname(__file__), ".timer_fifo")

InstantMs = int
DurationMs = int

UPDATE_INTERVAL: DurationMs = 50
UI_PRECISION: DurationMs = 100
BLINK_INTERVAL: DurationMs = 500
STANDARD_DPI = 96


def scale(px: int, dpi: int) -> int:
    # Try to avoid division operations by handling common cases.
    if dpi == STANDARD_DPI:
        return px
    if dpi == STANDARD_DPI * 2:
        return px * 2
    return (px * dpi + (STANDARD_DPI // 2)) // STANDARD_DPI


@dataclass
class SystemInfo:
    dpi: int

    @classmethod
    def _make(cls) -> Self:
        dpi_str = subprocess.run(
            r"xrdb -query | grep '^Xft\.dpi:' | cut -f2",
            shell=True,
            stdout=subprocess.PIPE,
            check=True,
        ).stdout
        try:
            dpi = int(dpi_str)
        except ValueError:
            dpi = STANDARD_DPI
        return cls(dpi)

    _instance: Optional["SystemInfo"] = None

    @classmethod
    def get(cls) -> "SystemInfo":
        if cls._instance is None:
            cls._instance = cls._make()
        return cls._instance


def monotonic_ms() -> InstantMs:
    return int(time.monotonic() * 1000)


@dataclass(frozen=True)
class TimerSpec:
    duration: DurationMs
    text: str


@dataclass(frozen=True)
class RunningCountdown:
    spec: TimerSpec
    start: InstantMs

    @property
    def duration(self) -> DurationMs:
        return self.spec.duration

    @property
    def end(self) -> InstantMs:
        return self.start + self.duration

    def pause(self, now: InstantMs) -> "PausedCountdown":
        return PausedCountdown(
            spec=self.spec,
            elapsed=min(now - self.start, self.duration),
        )


@dataclass(frozen=True)
class PausedCountdown:
    elapsed: DurationMs
    spec: TimerSpec

    @property
    def duration(self) -> DurationMs:
        return self.spec.duration

    @property
    def remaining(self) -> DurationMs:
        return self.duration - self.elapsed

    def resume(self, now: InstantMs) -> RunningCountdown:
        return RunningCountdown(
            spec=self.spec,
            start=now - self.elapsed,
        )


Countdown = RunningCountdown | PausedCountdown


class IntervalUpdater:
    interval: DurationMs
    _start: InstantMs
    _last_update: Optional[InstantMs] = None

    def __init__(self, interval: DurationMs, *, now: InstantMs):
        self.interval = interval
        self._start = now

    def copy_and_reset(self, now: InstantMs) -> "IntervalUpdater":
        return IntervalUpdater(self.interval, now=now)

    def time_until_update(self, now: InstantMs) -> DurationMs:
        if self._last_update is None:
            return 0
        interval = self.interval
        elapsed = now - self._start
        target = ((self._last_update - self._start) // interval + 1) * interval
        return max(0, target - elapsed)

    def mark_updated(self, now: InstantMs) -> None:
        self._last_update = now


@dataclass(frozen=True)
class Update:
    timeout: Optional[DurationMs]
    data: bytes = b""


FloatColor = tuple[float, float, float]


@dataclass(frozen=True)
class AnimFrame:
    time: float
    color: FloatColor


PROGRESS_FRAMES = [
    AnimFrame(0, (0.415686, 1, 0)),
    AnimFrame(0.175, (0.03, 1, 0.498833)),
    AnimFrame(0.325, (0, 0.611765, 1)),
    AnimFrame(0.475, (0.717647, 0, 1)),
    AnimFrame(0.625, (0.807843, 0.501961, 0.498039)),
    AnimFrame(0.75, (1, 1, 0)),
    AnimFrame(0.875, (1, 0.501961, 0)),
    AnimFrame(1, (1, 0, 0)),
]


def get_anim_color(frames: list[AnimFrame], progress: float) -> FloatColor:
    index = bisect.bisect_right(frames, progress, key=lambda f: f.time)
    if index >= len(frames):
        return frames[-1].color
    start = frames[index - 1]
    end = frames[index]
    transition_progress = (progress - start.time) / (end.time - start.time)
    r, g, b = (a + (b - a) * transition_progress
               for a, b in zip(start.color, end.color))
    return (r, g, b)


def float_color_to_hex(color: FloatColor) -> str:
    return "#" + "".join(f"{round(c * 255):02x}" for c in color)


USUAL_TEXT_LEN = len(" 0h 00m 00.0s ")
ASSUMED_TEXT_WIDTH = USUAL_TEXT_LEN * ASSUMED_CHAR_WIDTH
MAX_PADDING = (WIDTH - ASSUMED_TEXT_WIDTH) // 2


@dataclass
class RenderData:
    text: str
    padding: Optional[int]
    color: str = "#000000"


class Timer:
    _updater: Optional[IntervalUpdater] = None
    _countdown: Optional[Countdown] = None
    _stale: bool = False

    def start(
        self,
        duration: DurationMs,
        total: Optional[DurationMs] = None,
        text: Optional[str] = None,
    ) -> None:
        now = monotonic_ms()
        if total is None:
            total = duration
        if text is None:
            text = "TIME IS UP!"
        start = now + duration - total
        spec = TimerSpec(duration=total, text=text)
        self._countdown = RunningCountdown(spec=spec, start=start)
        self._updater = IntervalUpdater(UPDATE_INTERVAL, now=now)

    def stop(self) -> None:
        if self._countdown is not None:
            self._stale = True
        self._countdown = None
        self._updater = None

    def pause(self) -> bool:
        if not isinstance(self._countdown, RunningCountdown):
            return False
        now = monotonic_ms()
        if now >= self._countdown.end:
            return False
        self._countdown = self._countdown.pause(now)
        self._updater = None
        self._stale = True
        return True

    def resume(self) -> bool:
        if not isinstance(self._countdown, PausedCountdown):
            return False
        now = monotonic_ms()
        self._countdown = self._countdown.resume(now)
        self._updater = IntervalUpdater(UPDATE_INTERVAL, now=now)
        return True

    @staticmethod
    def fmt_duration(d: DurationMs) -> str:
        chunks = (d + (UI_PRECISION - 1) // 2) // UI_PRECISION
        chunks_per_sec = 1000 // UI_PRECISION
        seconds, chunks = divmod(chunks, chunks_per_sec)
        minutes, seconds = divmod(seconds, 60)
        hours, minutes = divmod(minutes, 60)
        seconds_str = f"{seconds:02}"
        if UI_PRECISION < 1000:
            max_len = len(str((1000 - 1) // UI_PRECISION))
            seconds_str += f".{chunks:0{max_len}}"
        return f"{hours}h {minutes:02}m {seconds_str}s"

    def _render(self) -> Optional[RenderData]:
        if self._countdown is None:
            return None

        now = monotonic_ms()
        if isinstance(self._countdown, PausedCountdown):
            return RenderData(
                f"[PAUSED] {self.fmt_duration(self._countdown.remaining)} ",
                padding=0,
                color="#000000",
            )
        assert_type(self._countdown, RunningCountdown)

        remaining = self._countdown.end - now
        if remaining <= 0:
            color = ["#000000", "#ff0000"][-remaining // BLINK_INTERVAL % 2]
            return RenderData(
                text=self._countdown.spec.text,
                padding=None,
                color=color,
            )
        return RenderData(
            text=f" {self.fmt_duration(remaining)} ",
            padding=((MAX_PADDING * remaining + remaining // 2) //
                     self._countdown.duration),
            color=float_color_to_hex(get_anim_color(
                PROGRESS_FRAMES,
                (now - self._countdown.start) / self._countdown.duration,
            )),
        )

    @property
    def status_blocks(self) -> list[object]:
        data = self._render()
        if data is None:
            return []
        block = {
            "name": "timer",
            "full_text": data.text,
            "border_top": 0,
            "border_bottom": 0,
            "border_right": data.padding or 0,
            "border_left": data.padding or 0,
            "separator_block_width": 0,
        }
        if data.padding is None:
            block["background"] = data.color
            block["min_width"] = scale(WIDTH, SystemInfo.get().dpi)
            block["align"] = "center"
            right_width = 0
        else:
            block["border"] = data.color
            right_width = MAX_PADDING - data.padding
        right = {
            "name": "timer_right",
            "full_text": " ",
            "border_top": 0,
            "border_bottom": 0,
            "border_right": 0,
            "border_left": right_width,
            "separator_block_width": 0,
        }
        if right_width > 0:
            right["border"] = "#000000"
        return [block, right]

    @property
    def _data(self) -> bytes:
        return f"{json.dumps(self.status_blocks)}\n".encode()

    def update(self) -> Update:
        now = monotonic_ms()
        if not self._stale:
            timeout = None
            if self._updater is not None:
                timeout = self._updater.time_until_update(now)
            if timeout != 0:
                return Update(timeout=timeout)

        self._stale = False
        if self._updater is None:
            return Update(data=self._data, timeout=None)

        done = (isinstance(self._countdown, RunningCountdown) and
                now >= self._countdown.end)
        if done:
            self._updater.interval = BLINK_INTERVAL
        timeout = self._updater.interval
        self._updater.mark_updated(now)
        return Update(data=self._data, timeout=timeout)


DURATION_PATTERN = re.compile(r"(?:(\d+)h)?(?:(\d+)m)?(?:(\d+)s)?")


def parse_duration(string: str) -> DurationMs:
    match = DURATION_PATTERN.fullmatch(string) if string else None
    if match is None:
        raise ValueError
    h, m, s = (int(g) if g else 0 for g in match.groups())
    return ((h * 60 + m) * 60 + s) * 1000


def handle_line(line: str, timer: Timer) -> None:
    if line.startswith("start "):
        _, arg1, *rest = line.split(" ", 3)
        try:
            duration = parse_duration(arg1)
        except ValueError:
            print("error: could not parse duration")
            return
        args = itertools.chain(rest, itertools.repeat(None))
        if (arg := next(args)) is None or arg == "-":
            total = None
        else:
            try:
                total = parse_duration(arg)
            except ValueError:
                print("error: could not parse total duration")
                return
            if total < duration:
                print("error: total duration cannot be less than remaining "
                      "time")
                return
        text = next(args)
        timer.start(duration, total=total, text=text)
        return

    if line == "stop":
        timer.stop()
        return
    if line == "pause":
        timer.pause()
        return
    if line == "resume":
        timer.resume()
        return
    print("unknown command")


def open_fifo() -> int:
    return os.open(FIFO_PATH, os.O_RDWR | os.O_NONBLOCK)


def main() -> None:
    try:
        fd = open_fifo()
    except FileNotFoundError:
        os.mkfifo(FIFO_PATH)
        fd = open_fifo()
    fcntl.fcntl(fd, fcntl.F_SETFL, os.O_WRONLY | os.O_NONBLOCK)
    fifo = os.fdopen(fd, "wb", buffering=0)
    stdin = sys.stdin.buffer
    assert isinstance(stdin, io.BufferedIOBase)

    poll = select.poll()
    poll.register(stdin, select.POLLIN)
    fifo_registered = False

    stdin_buffer = bytearray()
    fifo_buffer = bytearray()
    timer = Timer()

    while True:
        update = timer.update()
        fifo_buffer += update.data

        if fifo_buffer:
            poll.register(fifo, select.POLLOUT)
        elif fifo_registered:
            poll.unregister(fifo)
        fifo_registered = bool(fifo_buffer)

        for fd, events in poll.poll(update.timeout):
            if events & select.POLLNVAL:
                raise ValueError(f"fd {fd} not open (POLLNVAL)")
            if events & select.POLLERR:
                raise ValueError(f"error polling fd {fd} (POLLERR)")

            if fd == stdin.fileno() and events & select.POLLIN:
                data = stdin.read1()
                if not data:
                    return
                stdin_buffer += data
            if fd == stdin.fileno() and events & select.POLLHUP:
                return

            if fd == fifo.fileno() and events & select.POLLOUT:
                n = fifo.write(fifo_buffer)
                if n is not None:
                    del fifo_buffer[:n]
            if events & select.POLLHUP:
                print(f"warning: unexpected POLLHUP on fd {fd}",
                      file=sys.stderr)

        *lines, rest = stdin_buffer.split(b"\n")
        del stdin_buffer[:len(stdin_buffer) - len(rest)]
        for line in lines:
            handle_line(line.decode(errors="replace"), timer)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        try:
            print(file=sys.stderr)
        except Exception:
            pass
