#!/usr/bin/env python3

"""Run me from the root repo directory"""

import os
import re
import sys
from subprocess import check_output

BENCHMARKS_DIR = "./benchmarks"
BIN_DIR = "./bin"


def run_single_benchmark(wc_bin, directory):
    result = check_output([os.path.join(BIN_DIR, wc_bin), directory])
    tuchus = result.decode().split('\n')[-2]
    parsed = re.match(r'^Took\s+(\d+)ms$', tuchus)[1]
    return int(parsed)


def run_benchmark(wc_bin, directory):
    all_runs = sorted([run_single_benchmark(wc_bin, directory) for _ in range(5)])
    return all_runs[len(all_runs) // 2]


def benchmark_directory(directory):
    ret = {}
    for wc in os.listdir(BIN_DIR):
        if wc.startswith('wc'):
            ret[wc] = run_benchmark(wc, directory)
    return ret


def main():
    print(benchmark_directory(sys.argv[1]))


if __name__ == "__main__":
    main()

