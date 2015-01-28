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
from smart import *
import cPickle
import sys, os
import copy
import re

NOTHING = object()

class SysConfig(object):
    """System configuration class.

    It has three different kinds of opition maps, regarding the
    persistence and priority that maps are queried.

    hard - Options are persistent.
    soft - Options are not persistent, and have a higher priority
           than persistent options.
    weak - Options are not persistent, and have a lower priority
           than persistent options.
    """


    def __init__(self, root=()):
        self._hardmap = {}
        self._softmap = {}
        self._weakmap = {}
        self._readonly = False
        self._modified = False
        self._config = self

    def __getstate__(self):
        return self._hardmap

    def __setstate__(self, state):
        self._hardmap.clear()
        self._hardmap.update(state)

    def getReadOnly(self):
        return self._readonly

    def setReadOnly(self, flag):
        self._readonly = flag

    def getModified(self):
        return self._modified

    def resetModified(self):
        self._modified = False

    def assertWritable(self):
        if self._readonly:
            raise Error, _("Configuration is in readonly mode.")

    def load(self, filepath):
        filepath = os.path.expanduser(filepath)
        if not os.path.isfile(filepath):
            raise Error, _("File not found: %s") % filepath
        if os.path.getsize(filepath) == 0:
            return
        file = open(filepath)
        self._hardmap.clear()
        try:
            self._hardmap.update(cPickle.load(file))
        except:
            if os.path.isfile(filepath+".old"):
                file.close()
                file = open(filepath+".old")
                self._hardmap.update(cPickle.load(file))
        file.close()

    def save(self, filepath):
        filepath = os.path.expanduser(filepath)
        if os.path.isfile(filepath):
            os.rename(filepath, filepath+".old")
        dirname = os.path.dirname(filepath)
        if not os.path.isdir(dirname):
            os.makedirs(dirname)
        file = open(filepath, "w")
        cPickle.dump(self._hardmap, file, 2)
        file.close()

    def _traverse(self, obj, path, default=NOTHING, setvalue=NOTHING):
        queue = list(path)
        marker = NOTHING
        newobj = obj
        while queue:
            obj = newobj
            elem = queue.pop(0)
            if type(obj) is dict:
                newobj = obj.get(elem, marker)
            elif type(obj) in (tuple, list):
                if type(elem) is int:
                    try:
                        newobj = obj[elem]
                    except IndexError:
                        newobj = marker
                elif elem in obj:
                    newobj = elem
                else:
                    newobj = marker
            else:
                if queue:
                    path = path[:-len(queue)]
                raise Error, "Can't traverse %s (%s): %s" % \
                             (type(obj), pathTupleToString(path), str(obj))
            if newobj is marker:
                break
        if newobj is not marker:
            if setvalue is not marker:
                newobj = obj[elem] = setvalue
        else:
            if setvalue is marker:
                newobj = default
            else:
                while True:
                    if len(queue) > 0:
                        if type(queue[0]) is int:
                            newvalue = []
                        else:
                            newvalue = {}
                    else:
                        newvalue = setvalue
                    if type(obj) is dict:
                        newobj = obj[elem] = newvalue
                    elif type(obj) is list and type(elem) is int:
                        lenobj = len(obj)
                        if lenobj <= elem:
                            obj.append(None)
                            elem = lenobj
                        elif elem < 0 and abs(elem) > lenobj:
                            obj.insert(0, None)
                            elem = 0
                        newobj = obj[elem] = newvalue
                    else:
                        raise Error, "Can't traverse %s with %s" % \
                                     (type(obj), type(elem))
                    if not queue:
                        break
                    obj = newobj
                    elem = queue.pop(0)
        return newobj

    def _getvalue(self, path, soft=False, hard=False, weak=False):
        if type(path) is str:
            path = pathStringToTuple(path)
        marker = NOTHING
        if soft:
            value = self._traverse(self._softmap, path, marker)
        elif hard:
            value = self._traverse(self._hardmap, path, marker)
        elif weak:
            value = self._traverse(self._weakmap, path, marker)
        else:
            value = self._traverse(self._softmap, path, marker)
            if value is marker:
                value = self._traverse(self._hardmap, path, marker)
                if value is marker:
                    value = self._traverse(self._weakmap, path, marker)
        return value

    def has(self, path, value=NOTHING, soft=False, hard=False, weak=False):
        obj = self._getvalue(path, soft, hard, weak)
        marker = NOTHING
        if obj is marker:
            return False
        elif value is marker:
            return True
        elif type(obj) in (dict, list):
            return value in obj
        else:
            raise Error, "Can't check %s for containment" % type(obj)

    def keys(self, path, soft=False, hard=False, weak=False):
        value = self._getvalue(path, soft, hard, weak)
        if value is NOTHING:
            return []
        if type(value) is dict:
            return value.keys()
        elif type(value) is list:
            return range(len(value))
        else:
            raise Error, "Can't return keys for %s" % type(value)

    def get(self, path, default=None, soft=False, hard=False, weak=False):
        value = self._getvalue(path, soft, hard, weak)
        if value is NOTHING:
            return default
        if type(value) in (dict, list):
            return copy.deepcopy(value)
        return value

    def set(self, path, value, soft=False, weak=False):
        assert path
        if type(path) is str:
            path = pathStringToTuple(path)
        if soft:
            map = self._softmap
        elif weak:
            map = self._weakmap
        else:
            self.assertWritable()
            self._modified = True
            map = self._hardmap
        self._traverse(map, path, setvalue=value)

    def add(self, path, value, unique=False, soft=False, weak=False):
        assert path
        if type(path) is str:
            path = pathStringToTuple(path)
        if soft:
            map = self._softmap
        elif weak:
            map = self._weakmap
        else:
            self.assertWritable()
            self._modified = True
            map = self._hardmap
        if unique:
            current = self._traverse(map, path)
            if type(current) is list and value in current:
                return
        path = path+(sys.maxint,)
        self._traverse(map, path, setvalue=value)

    def remove(self, path, value=NOTHING, soft=False, weak=False):
        assert path
        if type(path) is str:
            path = pathStringToTuple(path)
        if soft:
            map = self._softmap
        elif weak:
            map = self._weakmap
        else:
            self.assertWritable()
            self._modified = True
            map = self._hardmap
        marker = NOTHING
        while path:
            if value is marker:
                obj = self._traverse(map, path[:-1])
                elem = path[-1]
            else:
                obj = self._traverse(map, path)
                elem = value
            result = False
            if obj is marker:
                pass
            elif type(obj) is dict:
                if elem in obj:
                    del obj[elem]
                    result = True
            elif type(obj) is list:
                if value is marker and type(elem) is int:
                    try:
                        del obj[elem]
                        result = True
                    except IndexError:
                        pass
                elif elem in obj:
                    obj[:] = [x for x in obj if x != elem]
                    result = True
            else:
                raise Error, "Can't remove %s from %s" % \
                             (`elem`, type(obj))
            if not obj:
                if value is not marker:
                    value = marker
                else:
                    path = path[:-1]
            else:
                break
        return result

    def move(self, oldpath, newpath, soft=False, weak=False):
        if type(oldpath) is str:
            oldpath = pathStringToTuple(oldpath)
        if type(newpath) is str:
            newpath = pathStringToTuple(newpath)
        result = False
        marker = NOTHING
        value = self._getvalue(oldpath, soft, not (soft or weak), weak)
        if value is not marker:
            self.remove(oldpath, soft=soft, weak=weak)
            self.set(newpath, value, weak, soft)
            result = True
        return result


SPLITPATH = re.compile(r"(\[-?\d+\])|(?<!\\)\.").split

def pathStringToTuple(path):
    if "." not in path and "[" not in path:
        return (path,)
    result = []
    tokens = SPLITPATH(path)
    for token in tokens:
        if token:
            if token[0] == "[" and token[-1] == "]":
                try:
                    result.append(int(token[1:-1]))
                except ValueError:
                    raise Error, "Invalid path index: %s" % token
            else:
                result.append(token.replace(r"\.", "."))
    return tuple(result)

def pathTupleToString(path):
    result = []
    for elem in path:
        if type(elem) is int:
            result[-1] += "[%d]" % elem
        else:
            result.append(str(elem).replace(".", "\."))
    return ".".join(result)
