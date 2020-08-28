#!/usr/bin/python3
import argparse
#import matplotlib.pyplot as plt
import numpy as np
import sys
import os
from math import *
from bisect import bisect_left
from pprint import pprint, pformat
from yaml import dump as yamldump
from collections import OrderedDict


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

def filter_params(params):
    params = params.copy()
    del params['self']
    del params['__class__']
    return params

class BaseFS:
    reports = set()
    parameters = set()

    def __init__(self, **params):
        self.__dict__.update(params)
        type(self).parameters.update(params.keys())

    def to_dict(self):
        result = {}
        for e in type(self).reports:
            if e in self.__dict__:
                result[e] = f'{numfmt(self.__dict__[e])}'
            else:
                r = getattr(type(self), e)(self)
                result[e] = f'{numfmt(r)}'
        return result

    def __repr__(self):
        parameter = []
        for e in type(self).parameters:
            if e in self.__dict__:
                parameter += (f'{e}={numfmt(self.__dict__[e])}',)
            else:
                r = getattr(type(self), e)(self)
                parameter += (f'{e}={numfmt(r)}',)
        fspara =  ", ".join(parameter)
        
        return f'{type(self).__name__}({fspara})'

class Stats (BaseFS):
    reports = set(['total_size', 'files'])
    parameters = set()

    def __init__(self):
        self.total_size = 0
        self.files = 0

    def fallocate(self, size):
        self.total_size += size
        self.files += 1

class Fat32 (BaseFS):
    reports = set(['clusters', 'fat_entries', 'total_size', 'fat_clusters', 'total_clusters'])
    parameters = set()
    
    def __init__(self, cluster_size=s32k, fat_copies=2):
        self.clusters = 0
        self.fat_entries = 0
        super().__init__(**filter_params(locals()))
    
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
        super().__init__(cluster_size=cluster_size, fat_copies=fat_copies)
    
class UnixFS(BaseFS):
    parameters = set()
    reports = set(['blocks', 'total_size', 'total_blocks', 'inlined_files'])

    def __init__(self, inode_size=128, block_size=s4k, inline_size=60, bmap=12, indirect_bmap=s1k):
        self.blocks = 0
        self.inodes = 0
        self.inlined_files = 0
        super().__init__(**filter_params(locals()))

    def alloc_indirects(self, blocks):
        indirects = 0
        if(blocks < bmap):
            return 0
        blocks -= bmap
        

    def fallocate(self, size):
        if(size < self.inline_size):
            use_blocks = 0
            self.inlined_files += 1
        else:
            use_blocks = ceil(size / self.block_size)
        self.inodes += 1
        self.blocks += use_blocks

    def total_blocks(self):
        return self.blocks + ceil(self.inodes * self.inode_size / self.block_size)
    
    def total_size(self):
        return self.total_blocks() * self.block_size



if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        prog = "fsestimate",
        description = """
            can use "-" as input filename, indicate input is taken from stdin.
            otherwise input file should be a result of "find -printf \'%s %p\\n\'"
            """
    )
    # parser.add_argument('-o', '--output', help="output filename, will recognize common extensions by matplot")
    parser.add_argument('input', nargs='+',  help="input filenames")
    args = parser.parse_args()

    filenames = [x if x != '-' else '/dev/stdin' for x in args.input]
    data=np.array([int(x.split(' ')[0]) for fn in filenames for x in open(fn)])

    fs = [Stats(), Fat32(), ExFat(), UnixFS()]
    fat32 = Fat32()
    for i in data:
        for f in fs:
            f.fallocate(i)
    pdict = OrderedDict()
    for f in fs:
       pdict[f'{f}'] = f.to_dict()
    #pprint(pdict, indent=4, width=os.get_terminal_size().columns)
    print(yamldump(pdict, width=os.get_terminal_size().columns))
