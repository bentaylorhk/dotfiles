# Benjamin Michael Taylor (bentaylorhk)
# 2023

import argparse
from datetime import datetime
import os
import platform
import random
import shutil
import time


def format_uptime(seconds):
    days, rem = divmod(max(int(seconds), 0), 86400)
    hours, rem = divmod(rem, 3600)
    minutes = rem // 60
    if days:
        return f'{days}d {hours}h {minutes}m'
    if hours:
        return f'{hours}h {minutes}m'
    return f'{minutes}m'


def read_cpu_times():
    with open('/proc/stat', 'r') as file:
        fields = file.readline().split()
    if not fields or fields[0] != 'cpu':
        raise RuntimeError('Could not read aggregate CPU counters from /proc/stat')
    values = [int(value) for value in fields[1:]]
    idle = values[3] + (values[4] if len(values) > 4 else 0)
    return sum(values), idle


def cpu_usage_percent():
    total_before, idle_before = read_cpu_times()
    time.sleep(0.1)
    total_after, idle_after = read_cpu_times()
    total_delta = total_after - total_before
    idle_delta = idle_after - idle_before
    if total_delta <= 0:
        return None
    return round(100 * (total_delta - idle_delta) / total_delta)


def system_status(hostname=None):
    with open('/proc/uptime', 'r') as file:
        uptime_seconds = float(file.readline().split()[0])

    memory = {}
    with open('/proc/meminfo', 'r') as file:
        for line in file:
            key, value, *_ = line.split()
            if key in {'MemTotal:', 'MemAvailable:'}:
                memory[key] = int(value)
    memory_total = memory['MemTotal:']
    memory_used = memory_total - memory['MemAvailable:']
    memory_total_gib = memory_total / 1024**2
    memory_used_gib = memory_used / 1024**2
    memory_percent = round(100 * memory_used / memory_total)

    disk = shutil.disk_usage('/')
    disk_used_gib = disk.used / 1024**3
    disk_total_gib = disk.total / 1024**3
    disk_percent = round(100 * disk.used / disk.total)

    cpu_percent = cpu_usage_percent()
    cpu_text = f'{cpu_percent}%' if cpu_percent is not None else 'n/a'
    return [
        f'Hostname - {hostname or platform.node()}',
        f'Time - {datetime.now().astimezone().strftime("%Y-%m-%d %H:%M:%S %Z")}',
        f'Uptime - {format_uptime(uptime_seconds)}',
        f'CPU - {cpu_text}',
        f'Memory - {memory_used_gib:.1f}/{memory_total_gib:.1f} GiB ({memory_percent}%)',
        f'Root disk - {disk_used_gib:.1f}/{disk_total_gib:.1f} GiB ({disk_percent}%)',
    ]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '-d', '--dir-path',
        help='Path to the directory of ascii art .txt files',
        required=True
    )
    parser.add_argument('--hostname')
    parser.add_argument('--ark-status')
    parser.add_argument('--ark-since-monotonic-us', type=int)
    args = parser.parse_args()
    if (args.hostname is None) != (args.ark_status is None):
        parser.error('--hostname and --ark-status must be provided together')

    # Getting the txt files
    txt_filenames = []
    for filename in os.listdir(args.dir_path):
        if filename.endswith('.txt'):
            txt_filenames.append(filename)
    if not txt_filenames:
        parser.error(f'No .txt headers found in {args.dir_path}')

    # Getting a random file
    txt_filename = os.path.join(args.dir_path, random.choice(txt_filenames))

    # Getting the terminal width
    shell_width = shutil.get_terminal_size()

    # Printing each line centered
    with open(txt_filename, 'r') as file:
        print()
        # read().splitlines() is used instead of .readlines() to avoid '\n'
        for line in file.read().splitlines():
            print(line.center(shell_width.columns))
        print()
        for line in system_status(args.hostname):
            if line.startswith('Time - ') or line.startswith('CPU - '):
                print()
            print(line.center(shell_width.columns))
        if args.hostname is not None:
            print()
            # Colour only the status, after centring so escape codes don't skew padding
            status_line = f'Ark Server - {args.ark_status}'.center(shell_width.columns)
            colour = '\033[32m' if args.ark_status == 'active' else '\033[31m'
            head, _, tail = status_line.rpartition(args.ark_status)
            print(f'{head}{colour}{args.ark_status}\033[0m{tail}')
            if args.ark_status == 'active' and args.ark_since_monotonic_us:
                # Monotonic time is immune to wall-clock adjustments
                uptime = time.monotonic() - args.ark_since_monotonic_us / 1e6
                print(f'Uptime - {format_uptime(uptime)}'.center(shell_width.columns))
            print()


if __name__ == '__main__':
    main()
