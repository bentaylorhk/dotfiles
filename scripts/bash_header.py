# Benjamin Michael Taylor (bentaylorhk)
# 2023

import argparse
import os
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

    # Getting the termial width
    shell_width = shutil.get_terminal_size()

    # Printing each line centered
    with open(txt_filename, 'r') as file:
        print()
        # read().splitlines() is used instead of .readlines() to avoid '\n'
        for line in file.read().splitlines():
            print(line.center(shell_width.columns))
        print()
        if args.hostname is not None:
            print()
            print(f'Hostname - {args.hostname}'.center(shell_width.columns))
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
