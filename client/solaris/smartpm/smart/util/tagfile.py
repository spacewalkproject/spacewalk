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

class TagFile(dict):

    def __init__(self, file):
        if type(file) is str:
            self._filename = file
            self._file = open(file)
        else:
            self._filename = None
            self._file = file
        self._offset = 0

    def __getstate__(self):
        if not self._filename:
            raise TypeError, "Can't pickle TagFile instance " \
                             "constructed with file object"
        return self._filename

    def __setstate__(self, state):
        self._filename = state
        self._file = open(state)
        self._offset = 0

    def setOffset(self, offset):
        self._offset = offset
        self._file.seek(offset)

    def getOffset(self):
        return self._offset

    def advanceSection(self):
        try:
            self.clear()
            key = None
            for line in self._file:
                self._offset += len(line)
                if not line:
                    break
                if line[-1] == "\n":
                    line = line[:-1]
                if not line:
                    if key:
                        break
                    continue
                if line[0].isspace():
                    if key:
                        line = line[1:].rstrip()
                        if line == ".":
                            line = ""
                        self[key] += "\n"+line
                else:
                    toks = line.split(":", 1)
                    if len(toks) == 2:
                        key = toks[0].strip().lower()
                        self[key] = toks[1].strip()
                    else:
                        key = None
        except StopIteration:
            pass
        return bool(self)

from ctagfile import *
