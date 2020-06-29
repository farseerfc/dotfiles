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


class Fat32:
    
    def __init__(self, cluster_size=4096):
        self.clusters = 0
        self.clustersize = cluster_size
        self.fat_entries = 0
        self.report_entries = ['clusters', 'fat_entries', 'total_size'] 
    
    def fallocate(self, size):
        use_clusters = ceil(size / 4096)
        self.clusters += use_clusters
        self.fat_entries += 1

    def total_size(self):
        return self.clusters * self.clustersize

    def __str__(self):
        result = []
        for e in self.report_entries:
            if e in self.__dict__:
                result += (f'{e}: {numfmt(self.__dict__[e])}',)
            else:
                r = getattr(type(self), e)(self)
                result += (f'{e}: {numfmt(r)}',)
                
        return "\t".join(result)
    

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

    fat32 = Fat32()
    for i in data:
        fat32.fallocate(i)
    print(fat32)
