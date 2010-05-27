#!/bin/env python
import os
from os.path import abspath, join, exists, islink
import sys
import fnmatch
import shutil

def need_to_backup(src_dir, dest_dir):
    src_dir = abspath(src_dir)
    dest_dir = abspath(dest_dir)
    if not exists(dest_dir):
        return False
    for path, dirs, files in os.walk(src_dir):
        for f in [f for f in files if not ignorable(f)]:
            src = abspath(join(path, f))
            path_suffix = src[len(src_dir) + 1 :]
            dest = join(dest_dir, path_suffix)
            if exists(dest) and (not islink(dest) or (islink(dest) and 
                                src != os.readlink(dest))):
                return True
    return False


def ignorable(f, ignorables = ["*.*~", "*.swp", "*.pyc", "*.pyo", "*.pyd", "Makefile*"]):
    for i in ignorables: 
        if fnmatch.fnmatch(f, i): return True
    return False
    
def link_tree(src_dir, dest_dir):
    src_dir = abspath(src_dir)
    dest_dir = abspath(dest_dir)
    if need_to_backup(src_dir, dest_dir):
        print "Moving %s to %s" %(dest_dir, dest_dir + ".bak")
        shutil.move(dest_dir, dest_dir + ".bak")
    if not exists(dest_dir):
        os.makedirs(dest_dir)
    for path, dirs, files in os.walk(src_dir):
        for d in dirs:
            path_suffix = abspath(join (path, d) )[len(src_dir) + 1:]
            dest = join(dest_dir, path_suffix)
            if not exists(dest):
                os.makedirs(dest)
        for f in [f for f in files if not ignorable(f)]:
            src = abspath(join(path, f))
            path_suffix = src[len(src_dir) + 1 :]
            dest = join(dest_dir, path_suffix)
            if not exists(dest):
                os.symlink(src, dest)

if __name__ == "__main__":
    args = sys.argv[1:]
    if len(args) != 2:
        print "%s <src_dir> <dest_dir>" % sys.argv[0]
        sys.exit(1)
    link_tree(*args)
