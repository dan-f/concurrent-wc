#!/usr/bin/env python3

from argparse import ArgumentParser
import math
import os
from random import randrange


benchmarks_dir = "./benchmarks"


def file_chunks(num_bytes: int):
    chunk_size = 4096
    while num_bytes > 0:
        if num_bytes >= chunk_size:
            num_bytes -= chunk_size
            yield chunk_size
        else:
            yield num_bytes
            num_bytes = 0


def create_benchmark(num_files: int, file_size_bytes: int):
    benchmark_dir = os.path.join(
        benchmarks_dir, "files_{num_files}_size_{file_size_bytes}".format(num_files=num_files, file_size_bytes=file_size_bytes)
    )
    print("Creating benchmark: {}".format(benchmark_dir))
    os.mkdir(benchmark_dir)

    for i in range(num_files):
        fname = os.path.join(benchmark_dir, "file_{}".format(i))
        with open(fname, "w") as f:
            for chunk_size in file_chunks(file_size_bytes):
                f.write(''.join(chr(randrange(256)) for _ in range(chunk_size)))


def create_benchmarks():
    step = 4
    max_num_files = 120
    num_files_incr = int(max_num_files / step)
    max_file_size = 1024 * 1000  # in bytes
    file_size_incr = int(max_file_size / step)

    for num_files in range(num_files_incr, max_num_files + num_files_incr, num_files_incr):
        for file_size_bytes in range(file_size_incr, max_file_size + file_size_incr, file_size_incr):
            create_benchmark(num_files, file_size_bytes)


def main():
    parser = ArgumentParser(description="Creates files for benchmarking")
    parser.add_argument("-f", "--force", action="store_true")
    args = parser.parse_args()

    print("This script will create a lot of data for testing."
          " It will create a directory at '{benchmarks_dir}".format(
              benchmarks_dir=benchmarks_dir) +
          " of several hundred megabytes.")

    can_proceed = input("Proceed? [Y/n] ").lower() == 'y'

    if not can_proceed:
        print("OK - not proceeding")
        exit(1)

    if not os.path.exists(benchmarks_dir):
        os.mkdir(benchmarks_dir)
    elif args.force:
        os.rmdir(benchmarks_dir)
        os.mkdir(benchmarks_dir)
    else:
        print("'{benchmarks_dir}' already exists; exiting. Run with '--force' to rebuild the '{benchmarks_dir}' dir.".format(
            benchmarks_dir=benchmarks_dir))
        exit(1)

    create_benchmarks()


if __name__ == "__main__":
    main()
