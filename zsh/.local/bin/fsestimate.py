#!/usr/bin/python3
import argparse
import matplotlib.pyplot as plt
import numpy as np
import sys
import os
from math import ceil, floor
from bisect import bisect_left
from pprint import pprint, pformat
from yaml import dump as yamldump
from collections import OrderedDict

HUMAN_NUMFMT = True

def numfmt(s):
    if not HUMAN_NUMFMT:
        return s
    s = float(s)
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
s8k = s1k * 8
s16k = s1k * 16
s32k = s1k * 32
s64k = s1k * 64
s128k = s1k * 128
s1m = s1k * s1k
s128m = s1m * 128
s1g = s1m * s1k

def filter_params(params):
    params = params.copy()
    if 'self' in params: del params['self']
    if '__class__' in params: del params['__class__']
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
        self.totalsize = 0
        self.files = 0

    def fallocate(self, size):
        self.totalsize += size
        self.files += 1
    
    def total_size(self):
        return self.totalsize

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
    reports = set(['blocks', 'total_size', 'total_blocks', 'inlined_files', 'indirect_blocks', 'inode_blocks', 'bitmap_blocks'])

    def __init__(self, inode_size=128, block_size=512, inline_size=13*4, inode_bmap=10, indirect_bmap=512//4, inode_ratio=s4k, bg_size=s128m):
        self.blocks = 0
        self.indirect_blocks = 0
        self.inodes = 0
        self.inlined_files = 0
        super().__init__(**filter_params(locals()))

    def alloc_indirects(self, blocks):
        indirects = 0
        if(blocks < self.inode_bmap):
            return 0
        blocks -= self.inode_bmap # first inode_bmap blocks in inode
        level = 0
        while blocks > 0:
            next_level = ceil(blocks / self.indirect_bmap)
            indirects += next_level
            blocks = next_level - 1 # 1 indirect block in inode, others need next level indirect blocks
            level += 1
        return indirects

    def fallocate(self, size):
        if(size < self.inline_size):
            use_blocks = 0
            self.inlined_files += 1
        else:
            use_blocks = ceil(size / self.block_size)
        self.inodes += 1
        self.indirect_blocks += self.alloc_indirects(use_blocks)
        self.blocks += use_blocks

    def inode_blocks(self):
        return ceil(self.blocks // self.inode_ratio)
    
    def bitmap_blocks(self):
        # 2 bitmap block per bg
        return 2 * ceil(self.blocks * self.block_size / self.bg_size)

    def total_blocks(self):
        return self.blocks + self.indirect_blocks + self.inode_blocks() + self.bitmap_blocks()
    
    def total_size(self):
        return self.total_blocks() * self.block_size

class FFS(UnixFS):
    parameters = set()
    reports = set(['blocks', 'total_size', 'total_blocks', 'inlined_files', 'indirect_blocks', 'inode_blocks', 'fragments', 'bitmap_blocks'])

    def __init__(self, inode_size=128, block_size=s32k, fragment_size=s4k, inline_size=0, inode_bmap=10, indirect_bmap=s32k//4, bg_size=s1g, inode_ratio=s8k):
        self.fragments = 0
        self.blocks = 0
        self.indirect_blocks = 0
        self.inodes = 0
        self.inlined_files = 0
        self.fragments = 0
        BaseFS.__init__(self, **filter_params(locals()))
    
    def fallocate(self, size):
        use_blocks = floor(size / self.block_size)
        remain = size - use_blocks * self.block_size
        use_fragments = ceil(remain / self.fragment_size)
        if use_fragments == self.block_size // self.fragment_size:
            use_blocks += 1
            use_fragments = 0
        self.fragments += use_fragments
        self.inodes += 1
        self.indirect_blocks += self.alloc_indirects(use_blocks)
        self.blocks += use_blocks
    
    def fragment_blocks(self):
        return ceil(self.fragments / (self.block_size // self.fragment_size))
    
    def total_blocks(self):
        return self.blocks + self.indirect_blocks + self.inode_blocks() + self.fragment_blocks() + self.bitmap_blocks()

class F2FS(UnixFS):
    def __init__(self, inode_size=s4k, block_size=s4k, inline_size=3400, inode_bmap=923, indirect_bmap=1018, inode_ratio=1):
        super().__init__(**filter_params(locals()))
    
    def inode_blocks(self):
        return self.inodes

class Ext2FS(UnixFS):
    def __init__(self, inode_size=128, block_size=s4k, inline_size=0, inode_bmap=12, indirect_bmap=s1k, inode_ratio=s16k):
        super().__init__(**filter_params(locals()))

class Ext4FS(Ext2FS):
    def __init__(self, inode_size=256, block_size=s4k, inline_size=15*4+90, inode_bmap=4, indirect_bmap=s4k//12, bg_size=s1g, inode_ratio=s32k):
        UnixFS.__init__(self, **filter_params(locals()))

    def bitmap_blocks(self):
        # 16 bitmap block per flex_bg
        return 16 * ceil(self.blocks * self.block_size / self.bg_size)
    
    def alloc_indirects(self, blocks):
        # for ext4 single extent header is 12 bytes and each extent entry is 12 bytes
        # using fg_flex we can put roughly 1G of contiguous address in 1 extent entry
        extents = blocks * self.block_size // self.bg_size 
        extents -= self.inode_bmap # first 4 extents can be put into inode bmap space
        indirects = 0
        if extents > 0:
            indirects = ceil(extents * 12 / self.block_size)
        return indirects


def compare_fat_cluster_size(data):
    fs = [Fat32(cluster_size=512),
          Fat32(cluster_size=s1k),
          Fat32(cluster_size=s4k),
          Fat32(cluster_size=s8k),
          Fat32(cluster_size=s16k),
          Fat32(cluster_size=s32k),
          Fat32(cluster_size=s64k),
          Fat32(cluster_size=s128k)]

    for i in data:
        for f in fs:
            f.fallocate(i)

    fig, ax = plt.subplots(figsize=(10,4))
    ax.bar(range(len(fs)), [x.total_size() for x in fs])
    tickbar = ""
    ax.set_xticks([i for i in range(len(fs))])
    ax.set_xticklabels([tickbar*(i%2) + numfmt(x.cluster_size) for i,x in enumerate(fs)])
    for i, x in enumerate(fs):
        ax.text(i-0.25, x.total_size() * 1.01 , f"{numfmt(x.total_size())}")
    plt.show()

def output_fs_estimate(data):
    fs = [Stats(), Fat32(), ExFat(), UnixFS(), Ext2FS(), F2FS(), FFS(), Ext4FS()]
    for i in data:
        for f in fs:
            f.fallocate(i)
    pdict = OrderedDict()
    for f in fs:
       pdict[f'{f}'] = f.to_dict()
    #pprint(pdict, indent=4, width=os.get_terminal_size().columns)
    print(yamldump(pdict, width=os.get_terminal_size().columns))

def output_fat_estimate(data):
    fs = [Fat32(cluster_size=512),
        Fat32(cluster_size=s1k),
        Fat32(cluster_size=s4k),
        Fat32(cluster_size=s8k),
        Fat32(cluster_size=s16k),
        Fat32(cluster_size=s32k),
        Fat32(cluster_size=s64k),
        Fat32(cluster_size=s128k)]
    for i in data:
        for f in fs:
            f.fallocate(i)
    table_header = fs[0].reports
    table = [[numfmt(x.cluster_size)] + [x.to_dict()[y] for y in table_header] for x in fs]
    from tabulate import tabulate
    print(tabulate(table, stralign="left", tablefmt="grid", headers=(["cluster_size"] + [x for x in table_header])))


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
    data = [int(x.split(' ')[0]) for fn in filenames for x in open(fn)]

    # compare_fat_cluster_size(data)
    # output_fat_estimate(data)
    output_fs_estimate(data)
