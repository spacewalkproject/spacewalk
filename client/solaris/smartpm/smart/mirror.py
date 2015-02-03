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
import random
import time

HISTORYPERMIRROR = 20
HISTORYCUTDELAY = 60
GRANULARITY = 100

class MirrorSystem(object):

    def __init__(self):
        self._mirrors = {}
        self._history = []
        self._penality = {}
        self._changed = False
        self._historychanged = False
        self._lastcuttime = 0

    def getMirrors(self):
        return self._mirrors

    def setMirrors(self, mirrors):
        self._changed = True
        self._mirrors = mirrors

    def getHistory(self):
        return self._history

    def setHistory(self, history):
        self._changed = True
        self._history = history
        self._historychanged = False

    def getHistoryChanged(self):
        return self._historychanged

    def addInfo(self, mirror, **info):
        if mirror:
            self._changed = True
            self._history.insert(0, (mirror, info))
            self._historychanged = True
            now = time.time()
            if now-self._lastcuttime > HISTORYCUTDELAY:
                self._lastcuttime = now
                count = 0
                for origin in self._mirrors:
                    count += 1+len(self._mirrors[origin])
                del self._history[count*HISTORYPERMIRROR:]

    def get(self, url):
        elements = {}
        for origin in self._mirrors:
            if url.startswith(origin):
                elements[origin] = MirrorElement(self, origin, origin)
                for mirror in self._mirrors[origin]:
                    elements[mirror] = MirrorElement(self, origin, mirror)
        if elements:
            elements = elements.values()
        else:
            elements = [MirrorElement(self, "", "")]
        return MirrorItem(self, url, elements)

    def getPenalities(self):
        self.updatePenality()
        return self._penality

    def updatePenality(self):
        if not self._changed:
            return
        self._changed = False
        self._penality.clear()
        data = {}
        for mirror, info in self._history:
            if mirror not in data:
                mirrordata = data.setdefault(mirror, {"size": 0, "time": 0,
                                                      "failed": 0})
            else:
                mirrordata = data[mirror]
            mirrordata["size"] += info.get("size", 0)
            mirrordata["time"] += info.get("time", 0)
            mirrordata["failed"] += info.get("failed", 0)
        maxpenality = 1
        justerrors = []
        for mirror in data:
            mirrordata = data[mirror]
            if mirrordata["size"]:
                penality = (mirrordata["time"]*1000000)/mirrordata["size"]
                penality += mirrordata["failed"]*(penality*0.1)
                # Integer division by granularity ensures that mirrors
                # which are close enough will be considered equal to
                # distribute load.
                penality /= GRANULARITY
                self._penality[mirror] = penality
                if penality > maxpenality:
                    maxpenality = penality
            elif mirrordata["failed"]:
                justerrors.append(mirror)
        if justerrors:
            for mirror in justerrors:
                self._penality[mirror] = maxpenality

class MirrorElement(object):

    def __init__(self, system, origin, mirror):
        self._system = system
        self.origin = origin
        self.mirror = mirror

        if origin and mirror and origin[-1] == "/" and mirror[-1] != "/":
            self.mirror += "/"

    def __cmp__(self, other):
        # Give priority to local files.
        rc = -cmp(self.mirror.startswith("file://"),
                  other.mirror.startswith("file://"))
        if rc == 0:
            # Otherwise, check penality.
            pen = self._system._penality
            rc = cmp(pen.get(self.mirror, 0), pen.get(other.mirror, 0))
        return rc

class MirrorItem(object):

    def __init__(self, system, url, elements):
        self._system = system
        self._url = url
        self._elements = elements
        self._current = None

    def addInfo(self, **info):
        if self._current:
            self._system.addInfo(self._current.mirror, **info)

    def getNext(self):
        if self._elements:
            self._system.updatePenality()
            random.shuffle(self._elements)
            self._elements.sort()
            #for i, item in enumerate(self._elements):
            #    penality = self._system.getPenalities().get(item.mirror, 0)
            #    print "%d. %s (%d)" % (i, item.mirror, penality)
            self._current = elem = self._elements.pop(0)
            return elem.mirror+self._url[len(elem.origin):]
        else:
            self._current = None
            return None
