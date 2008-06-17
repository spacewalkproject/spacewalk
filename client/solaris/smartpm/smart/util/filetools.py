#
# Copyright (c) 2004 Conectiva, Inc.
#
# Written by Gustavo Niemeyer <niemeyer@conectiva.com>
#
# This file is part of Smart Package Manager.
#
# Smart Package Manager is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published
# by the Free Software Foundation; either version 2 of the License, or (at
# your option) any later version.
#
# Smart Package Manager is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Smart Package Manager; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
from smart.const import BLOCKSIZE
import resource
import fcntl
import md5
import os

def getFileDigest(path, digest=None):
    if not digest:
        digest = md5.md5()
    file = open(path)
    while True:
        data = file.read(BLOCKSIZE)
        if not data:
            break
        digest.update(data)
    file.close()
    return digest.digest()

def compareFiles(path1, path2):
    if not os.path.isfile(path1) or not os.path.isfile(path2):
        return False
    if os.path.getsize(path1) != os.path.getsize(path2):
        return False
    path1sum = md5.md5()
    path2sum = md5.md5()
    for path, sum in [(path1, path1sum), (path2, path2sum)]:
        file = open(path)
        while True:
            data = file.read(BLOCKSIZE)
            if not data:
                break
            sum.update(data)
        file.close()
    if path1sum.digest() != path2sum.digest():
        return False
    return True

def setCloseOnExec(fd):
    try:
        flags = fcntl.fcntl(fd, fcntl.F_GETFL, 0)
        flags |= fcntl.FD_CLOEXEC
        fcntl.fcntl(fd, fcntl.F_SETFL, flags)
    except IOError:
        pass

def setCloseOnExecAll():
    for fd in range(3,resource.getrlimit(resource.RLIMIT_NOFILE)[1]):
        try:
            flags = fcntl.fcntl(fd, fcntl.F_GETFL, 0)
            flags |= fcntl.FD_CLOEXEC
            fcntl.fcntl(fd, fcntl.F_SETFL, flags)
        except IOError:
            pass
