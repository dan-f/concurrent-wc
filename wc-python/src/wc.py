#!/usr/bin/env python

import sys
import os
from concurrent import futures

def line_count(filename):
    with open(filename, 'r') as f:
        lines = f.readlines()
        line_count = len(lines)
        # Because readlines() returns a line even if the only
        # text in the file is not terminated by a newline
        if line_count == 1:
            if '\n' not in lines[0]:
                line_count = 0
        return filename, line_count

def print_count(count, label):
    formatted_count = str(count).rjust(10)
    print "{} {}".format(formatted_count, label)

def main():
    if len(sys.argv) < 2:
        dirname = '.'
        paths = [f for f in os.listdir(dirname)]
    else:
        dirname = os.path.abspath(sys.argv[1])
        paths = [os.path.join(dirname, f) for f in os.listdir(dirname)]
    filenames = [p for p in paths if os.path.isfile(p)]
    counts = {}
    # with futures.ThreadPoolExecutor(max_workers=len(filenames)) as executor:
    with futures.ProcessPoolExecutor(max_workers=len(filenames)) as executor:
        all_futures = [executor.submit(line_count, f) for f in filenames]
        for future in futures.as_completed(all_futures):
            filename, count = future.result()
            counts[filename] = count
    ranked = sorted(counts, key=lambda k:-counts[k])
    for filename in ranked:
        print_count(counts[filename], filename)
    print_count(sum(counts.values()), "[TOTAL]")

if __name__ == "__main__":
    main()
