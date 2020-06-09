#!/usr/bin/python3
import matplotlib.pyplot as plt
import numpy as np
import sys
from math import *
from bisect import bisect_left 


def numfmt(s):
    marks = " KMGTP"
    m = 0
    f = False
    if s is float:
       f = True
    while s >= 1024 and m < len(marks):
        if f:
            s /= 1024.0
        else:
            s //=1024
        m += 1
    if f:
        return f"{s:.2f}{marks[m]}"
    else:
        return f"{s}{marks[m]}"

def inbin(s, bins):
    return bisect_left(bins, s)

if __name__ == '__main__':

    if len(sys.argv) < 2:
        print('Usage: filesizehistogram.py input')
        print('       can use "-" as input filename, indicate input is taken from stdin.')
        print('       otherwise input file should be a result of "find -printf \'%s %p\'"')
        sys.exit(1)

    filename = sys.argv[1]
    if filename == '-':
       filename = '/dev/stdin'
    data=np.array([int(x.split(' ')[0]) for x in open(filename)])
    mindatalog2 = 5 # cut from 32
    maxdatalog2 = min(ceil(log2(data.max())), 31) # cut at 1G and above
    # bins [0, 1, 32, 64, 128, 256, ... , 1G, 2G] , last bin is open range
    bins=[0,1,] + [2**x for x in range(mindatalog2, maxdatalog2 + 1)]
    
    median = float(np.median(data))
    mean = float(data.mean())
    bmedian = inbin(median, bins) - 1
    bmean = inbin(mean, bins) - 1

    hist, bin_edges = np.histogram(data,bins)
    fig,ax = plt.subplots()
    ax.bar(range(len(hist)),hist,width=0.8) 
    ax.set_xticks([i for i,j in enumerate(hist)])
    ax.set_xticklabels(['{} - {}:\n{}'.format(numfmt(bins[i]), numfmt(bins[i+1]), hist[i]) for i in range(0, len(hist)-1)] +
                       ["{} - :\n{}".format(numfmt(bins[len(hist)-1]), hist[-1])])
    ax.xaxis.set_tick_params(rotation=30)

    ax.axvline(bmean, color='k', linestyle='dashed', linewidth=1)
    ax.axvline(bmedian, color='r', linestyle='dashed', linewidth=1)
    min_ylim, max_ylim = plt.ylim()
    min_xlim, max_xlim = plt.xlim()
    ax.text(bmean+0.5, max_ylim*0.8, 'Mean: {}'.format(numfmt(mean)))
    ax.text(bmedian+0.5, max_ylim*0.9, 'Median: {}'.format(numfmt(median)))
    ax.text(max_xlim*0.9, max_ylim*0.9, 'Files: {}'.format(len(data)))
    ax.text(max_xlim*0.9, max_ylim*0.8, 'Total: {}'.format(numfmt(float(data.sum()))))
 
    #for i in range(len(hist)):
    #    ax.text(i-0.5, hist[i], str(hist[i]))

    plt.show()
