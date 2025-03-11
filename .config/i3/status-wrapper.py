#!/usr/bin/env -S python3 -u
# Copyright (C) 2023-2024 taylor.fish <contact@taylor.fish>
# License: GNU GPL version 3 or later

from decimal import Decimal
from typing import Any, BinaryIO, Iterator, Optional
import io
import json
import os
import re
import select
import subprocess
import sys

color_normal = "#ffffff"
color_good = "#60ff80"
color_degraded = "#ffd060"
color_bad = "#ff5050"

if os.getenv("MONOCHROME") == "2":
    color_normal = "#000000"
    color_good = color_normal
    color_degraded = color_normal
    color_bad = color_normal

color_map = {
    "#000001": color_good,
    "#000002": color_degraded,
    "#000003": color_bad,
}

Block = dict[str, Any]


def get_cpu_temps() -> Iterator[Decimal]:
    output = json.loads(
        subprocess.run(
            ["sensors", "-j", "*-isa-*"],
            capture_output=True,
            check=True,
            text=True,
        ).stdout,
    )
    components = (c for chip in output.values() for c in chip.items())
    for component in components:
        if not re.search(r"\bCore \d+$", component[0], re.I):
            continue
        for prop in component[1].items():
            if re.fullmatch(r"temp\d*_input", prop[0]):
                yield Decimal(prop[1])


def get_mem_available_gb() -> Optional[Decimal]:
    with open("/proc/meminfo") as f:
        for line in f:
            if not line.startswith("MemAvailable:"):
                continue
            return (Decimal(line.split()[1]) * 1024) / 1_000_000_000
    return None


def modify_wireless(blocks: list[Block]) -> None:
    try:
        item = next(x for x in blocks if x.get("name") == "wireless")
    except StopIteration:
        return
    item["full_text"] = item["full_text"].replace("[100%]", "[99%]")


def add_cpu_temperature(blocks: list[Block]) -> None:
    try:
        temp = max(get_cpu_temps())
    except ValueError:
        return
    color = color_normal
    if temp >= 75:
        color = color_bad
    elif temp >= 65:
        color = color_degraded
    blocks.insert(0, {
        "name": "cpu_temperature",
        "full_text": "{:02} °C".format(round(temp)),
        "color": color,
    })


def add_memory(blocks: list[Block]) -> None:
    available = get_mem_available_gb()
    if available is None:
        return
    color = color_normal
    if available < 4:
        color = color_bad
    elif available < 10:
        color = color_degraded
    blocks.insert(0, {
        "name": "memory",
        "full_text": "{:.1f} GB".format(available),
        "color": color,
    })


def process_json(blocks: list[Block]) -> None:
    for item in blocks:
        color = item.get("color")
        if color is not None:
            item["color"] = color_map.get(color)
    modify_wireless(blocks)
    add_cpu_temperature(blocks)
    add_memory(blocks)


def add_timer(blocks: list[Block], timer_blocks: list[Block]) -> None:
    if timer_blocks:
        blocks[:0] = timer_blocks


TIMER_FIFO_PATH = os.path.join(os.path.dirname(__file__), ".timer_fifo")
TIMER_ENABLED = os.getenv("MONITOR_PRIORITY") == "1"


def open_fifo_as_fd() -> int:
    return os.open(TIMER_FIFO_PATH, os.O_RDONLY | os.O_NONBLOCK)


def open_fifo(poll: select.poll) -> BinaryIO:
    try:
        fd = open_fifo_as_fd()
    except FileNotFoundError:
        os.mkfifo(TIMER_FIFO_PATH)
        fd = open_fifo_as_fd()
    fifo = os.fdopen(fd, "rb", buffering=0)
    poll.register(fifo, select.POLLIN)
    return fifo


def reopen_fifo(fifo: BinaryIO, poll: select.poll) -> BinaryIO:
    fifo.close()
    return open_fifo(poll)


def main() -> None:
    poll = select.poll()
    fifo = None
    if TIMER_ENABLED:
        fifo = open_fifo(poll)
    stdin = sys.stdin.buffer
    assert isinstance(stdin, io.BufferedIOBase)
    poll.register(stdin, select.POLLIN)

    stdin_buffer = bytearray()
    fifo_buffer = bytearray()

    while stdin_buffer.count(b"\n") < 2:
        data = stdin.read1()
        if not data:
            raise EOFError
        stdin_buffer += data
    *lines, rest = stdin_buffer.split(b"\n", 2)
    del stdin_buffer[:len(stdin_buffer) - len(rest)]
    for line in lines:
        print(line.decode())

    timer: list[Block] = []
    first_output = True
    pending_update = False
    status_blocks = []

    while True:
        *lines, rest = stdin_buffer.split(b"\n")
        del stdin_buffer[:len(stdin_buffer) - len(rest)]
        if lines:
            line = lines[-1]
            status_blocks = json.loads(line.lstrip(b","))
            process_json(status_blocks)
            pending_update = True

        if pending_update:
            blocks = status_blocks.copy()
            add_timer(blocks, timer)
            if not first_output:
                print(",", end="")
            json.dump(blocks, sys.stdout)
            print()
            pending_update = False
            first_output = False

        for fd, events in poll.poll():
            if events & select.POLLNVAL:
                raise ValueError(f"fd {fd}: POLLNVAL")
            if events & select.POLLERR:
                raise ValueError(f"fd {fd}: POLLERR")

            if fd == stdin.fileno() and events & select.POLLIN:
                data = stdin.read1()
                if not data:
                    return
                stdin_buffer += data
            if fd == stdin.fileno() and events & select.POLLHUP:
                return

            if fifo is None:
                continue
            fifo_closed = False
            if fd == fifo.fileno() and events & select.POLLIN:
                data = fifo.read()
                fifo_closed |= not data
                fifo_buffer += data
            fifo_closed |= (
                fd == fifo.fileno() and bool(events & select.POLLHUP)
            )
            if fifo_closed:
                timer = []
                pending_update = True
                fifo = reopen_fifo(fifo, poll)

        *lines, rest = fifo_buffer.split(b"\n")
        del fifo_buffer[:len(fifo_buffer) - len(rest)]
        if lines:
            timer = json.loads(lines[-1])
            pending_update = True


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass
