#!/usr/bin/python3
import argparse
import matplotlib.pyplot as plt
import numpy as np
import sys
from math import *
from bisect import bisect_left


def numfmt(s):
    marks = "KMGTP"
    m = 0
    f = type(s) is float
    while s >= 1024 and m < len(marks):
        if f:
            s /= 1024.0
        else:
            s //=1024
        m += 1
    if f:
        return f"{s:.2f}{marks[m-1:m]}"
    else:
        return f"{s}{marks[m-1:m]}"

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        prog = "filesizehistogram",
        description = """
            can use "-" as input filename, indicate input is taken from stdin.
            otherwise input file should be a result of "find -printf \'%s %p\\n\'"
            """
    )
    parser.add_argument('-o', '--output', help="output filename, will recognize common extensions by matplot")
    parser.add_argument('input', nargs='+',  help="input filenames")
    args = parser.parse_args()

    filenames = [x if x != '-' else '/dev/stdin' for x in args.input]
    data=np.array([int(x.split(' ')[0]) for fn in filenames for x in open(fn)])
    mindatalog2 = 5 # cut from 32
    maxdatalog2 = min(ceil(log2(data.max())), 31) # cut at 1G and above
    # bins [0, 1, 32, 64, 128, 256, ... , 1G, 2G] , last bin is open range
    bins=[0,1,] + [2**x for x in range(mindatalog2, maxdatalog2 + 1)]

    median = float(np.median(data))
    mean = float(data.mean())
    bmedian = bisect_left(bins, median) - 1
    bmean = bisect_left(bins, mean) - 1
    files = len(data)
    total = data.sum()

    hist, bin_edges = np.histogram(data,bins)
    fig,ax = plt.subplots(figsize=(20,8))
    ax.bar(range(len(hist)), hist, width=0.9)
    ax.set_xticks([i for i in range(len(hist))])
    tickbar = "┊\n"
    ax.set_xticklabels([f'{tickbar*(i%3)}{numfmt(bins[i])}~{numfmt(bins[i+1])}' for i in range(len(hist)-1)] +
                       [f"{numfmt(bins[len(hist)-1])}~"])

    ax.axvline(bmean, color='k', linestyle='dashed', linewidth=1)
    ax.axvline(bmedian, color='r', linestyle='dashed', linewidth=2)
    min_ylim, max_ylim = plt.ylim()
    min_xlim, max_xlim = plt.xlim()
    ax.text(bmean + 0.5   , max_ylim * 0.9, f'Mean: {numfmt(mean)}')
    ax.text(bmedian + 0.5 , max_ylim * 0.9, f'Median: {numfmt(median)}', color='r')
    ax.text(max_xlim * 0.8, max_ylim * 0.9, f'Files: {files}')
    ax.text(max_xlim * 0.9, max_ylim * 0.9, f'Total: {numfmt(float(total))}')

    for i in range(len(hist)):
        ax.text(i - 0.5, hist[i] + files / 400, f"{hist[i]:5}") # label on top of every bar, uplefted a little

    if args.output:
        plt.savefig(args.output)
    else:
        plt.show()
