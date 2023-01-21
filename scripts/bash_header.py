# Benjamin Michael Taylor (bentaylorhk)
# 2023

import argparse
import os
import random
import shutil


def main():
    # Single required argument
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '-d', '--dir-path',
        help='Path to the directory of ascii art .txt files',
        required=True
    )
    args = parser.parse_args()

    # Getting the txt files
    txt_filenames = []
    for filename in os.listdir(args.dir_path):
        if filename.endswith('.txt'):
            txt_filenames.append(filename)

    # Getting a random file
    txt_filename = os.path.join(args.dir_path, random.choice(txt_filenames))

    # Getting the termial width
    shell_width = shutil.get_terminal_size(None)

    # Printing each line centered
    with open(txt_filename, 'r') as file:
        print()
        # read().splitlines() is used instead of .readlines() to avoid '\n'
        for line in file.read().splitlines():
            if shell_width is not None:
                line = line.center(shell_width.columns)
            print(line)
        print()


if __name__ == '__main__':
    main()
