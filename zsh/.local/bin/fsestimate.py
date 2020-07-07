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

s1k = 1024
s4k = s1k * 4
s32k = s1k * 32
s128k = s1k * 128

class BaseFS:
    reports = []
    parameters = []

    def __str__(self):
        parameter = []
        for e in type(self).parameters:
            if e in self.__dict__:
                parameter += (f'{e}={numfmt(self.__dict__[e])}',)
            else:
                r = getattr(type(self), e)(self)
                parameter += (f'{e}={numfmt(r)}',)
        fspara =  ",\t".join(parameter)
        
        result = []
        for e in type(self).reports:
            if e in self.__dict__:
                result += (f'{e}: {numfmt(self.__dict__[e])}',)
            else:
                r = getattr(type(self), e)(self)
                result += (f'{e}: {numfmt(r)}',)
                
        report = "\t".join(result)
        return f'{type(self).__name__}({fspara}):\t{report}'

class Stats (BaseFS):
    reports = ['total_size', 'files']

    def __init__(self):
        self.total_size = 0
        self.files = 0

    def fallocate(self, size):
        self.total_size += size
        self.files += 1

class Fat32 (BaseFS):
    reports = ['clusters', 'fat_entries', 'total_size', 'fat_clusters', 'total_clusters']
    parameters = ['cluster_size', 'fat_copies']
    
    def __init__(self, cluster_size=s32k, fat_copies=2):
        self.clusters = 0
        self.cluster_size = cluster_size
        self.fat_entries = 0
        self.fat_copies = fat_copies
    
    def fat_clusters(self):
        return ceil(self.fat_entries * 4 / self.cluster_size)
    
    def total_clusters(self):
        return self.fat_clusters() * self.fat_copies + self.clusters
    
    def fallocate(self, size):
        use_clusters = ceil(size / self.cluster_size)
        self.clusters += use_clusters
        self.fat_entries += use_clusters

    def total_size(self):
        return self.total_clusters() * self.cluster_size

class ExFat(Fat32):
    def __init__(self, cluster_size=s128k, fat_copies=1):
        Fat32.__init__(self, cluster_size=cluster_size, fat_copies=fat_copies)
    

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

    fs = [Stats(), Fat32(), ExFat()]
    fat32 = Fat32()
    for i in data:
        for f in fs:
            f.fallocate(i)
    print("\n".join(str(x) for x in fs))
