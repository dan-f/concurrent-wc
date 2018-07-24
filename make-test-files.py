#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import math
import os
import random
import sys


def main():
    tmp_dirname = "./tmp"

    try:
        num_files, num_bytes = sys.argv[1:3]
        user_specified = True
    except ValueError:
        num_files, num_bytes = 100, 2 ** 22
        user_specified = False

    print("This script intends to create a lot of data for testing."
          " It will create a '{tmp_dirname}' directory of {num_bytes} bytes across {num_files} files.\n".format(
              tmp_dirname=tmp_dirname, num_bytes=num_bytes, num_files=num_files))

    if user_specified:
        print("You can control the number of files and number of total bytes"
              " by invoking './make-test-files.py <num_files> <num_bytes>\n")

    consent = input("Proceed? [Y/n] ")

    if consent != "Y":
        exit(1)

    if os.path.exists(tmp_dirname):
        print("A '{}' directory already exists. Exiting.".format(tmp_dirname))
        exit(1)
    else:
        os.mkdir(tmp_dirname)

    chunk = " " * 7 + "\n"
    lenchunk = len(chunk)
    print("Writing files to '{}'...".format(tmp_dirname))
    for i in range(num_files):
        fname = os.path.join(tmp_dirname, "file_{}".format(i))
        with open(fname, "w") as f:
            for _ in range(math.floor(num_bytes / lenchunk)):
                f.write(chunk)
    print("Done!")


if __name__ == '__main__':
    main()
