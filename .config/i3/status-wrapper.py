#!/usr/bin/env python3
from decimal import Decimal
import json
import os
import re
import subprocess
import sys

color_normal = "#ffffff"
color_good = "#60ff80"
color_degraded = "#ffd060"
color_bad = "#ff5050"

if os.getenv("MONOCHROME"):
    #color_normal = "#000000"
    #color_good = color_normal
    #color_degraded = color_normal
    #color_bad = color_normal

    color_good = "#8fffa5"
    color_degraded = "#fcda88"
    color_bad = "#ff9a9a"

color_map = {
    "#000001": color_good,
    "#000002": color_degraded,
    "#000003": color_bad,
}


def get_cpu_temps():
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


def get_mem_available_gb():
    with open("/proc/meminfo") as f:
        for line in f:
            if not line.startswith("MemAvailable:"):
                continue
            return (Decimal(line.split()[1]) * 1024) / 1_000_000_000


def modify_wireless(obj):
    try:
        item = next(x for x in obj if x.get("name") == "wireless")
    except StopIteration:
        return
    item["full_text"] = item["full_text"].replace("[100%]", "[99%]")


def add_cpu_temperature(obj):
    try:
        temp = max(get_cpu_temps())
    except ValueError:
        return
    color = color_normal
    if temp >= 75:
        color = color_bad
    elif temp >= 65:
        color = color_degraded
    obj.insert(0, {
        "name": "cpu_temperature",
        "full_text": "{:02} °C".format(round(temp)),
        "color": color,
    })


def add_memory(obj):
    available = get_mem_available_gb()
    color = color_normal
    if available < 4:
        color = color_bad
    elif available < 10:
        color = color_degraded
    obj.insert(0, {
        "name": "memory",
        "full_text": "{:.1f} GB".format(available),
        "color": color,
    })


def process_json(obj):
    for item in obj:
        if "color" in item:
            item["color"] = color_map.get(item["color"])
    modify_wireless(obj)
    add_cpu_temperature(obj)
    add_memory(obj)


def main():
    print(input())  # Version header
    print(input())  # Start of array
    while True:
        line, prefix = input(), ""
        if line.startswith(","):
            line, prefix = line[1:], ","
        obj = json.loads(line)
        process_json(obj)
        print(prefix, end="")
        json.dump(obj, sys.stdout)
        print()


if __name__ == "__main__":
    main()
