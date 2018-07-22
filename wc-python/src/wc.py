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
    # Fun fact: you can replace 'Process' with 'Thread' below and python will
    # use threads without any fuss (the API is the same). I've found that
    # for small directories and files, threads are faster, but once the number
    # and size of files gets large enough, processes become faster. Running
    # this program on the root repo directory (4 small files) takes ~0.127s 
    # with threads and ~0.205s with processes. However, on my ~/Downloads
    # directory (198 files and 14m lines), threads take around 7 seconds and 
    # processes take about 3. Threads are quicker to start up, and so are
    # better for small tasks, but processes catch up when they can take full
    # full advantage of multiple cores.
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
