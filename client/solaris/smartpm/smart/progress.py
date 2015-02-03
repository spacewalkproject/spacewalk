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
import thread
import time
import sys

INTERVAL = 0.1

class Progress(object):

    def __init__(self):
        self.__topic = ""
        self.__progress = (0, 0, {}) # (current, total, data)
        self.__lastshown = None
        self.__done = False
        self.__subtopic = {}
        self.__subprogress = {} # (subcurrent, subtotal, fragment, subdata)
        self.__sublastshown = {}
        self.__subdone = {}
        self.__lasttime = 0
        self.__lock = thread.allocate_lock()
        self.__hassub = False

    def lock(self):
        self.__lock.acquire()

    def unlock(self):
        self.__lock.release()

    def start(self):
        pass

    def stop(self):
        self.__topic = ""
        self.__progress = (0, 0, {})
        self.__lastshown = None
        self.__done = False
        self.__subtopic.clear()
        self.__subprogress.clear()
        self.__sublastshown.clear()
        self.__subdone.clear()
        self.__lasttime = 0
        self.__hassub = False

    def setHasSub(self, flag):
        self.__hassub = flag

    def getHasSub(self):
        return self.__hassub

    def getSubCount(self):
        return len(self.__subprogress)

    def show(self):
        now = time.time()
        if self.__lasttime > now-INTERVAL:
            return
        self.__lock.acquire()
        self.__lasttime = now
        current, total, data = self.__progress
        subexpose = []
        for subkey in self.__subprogress.keys():
            sub = self.__subprogress[subkey]
            subcurrent, subtotal, fragment, subdata = sub
            subpercent = int(100*float(subcurrent)/(subtotal or 1))
            if fragment:
                current += int(fragment*float(subpercent)/100)
            subtopic = self.__subtopic.get(subkey)
            if (subkey not in self.__subdone and
                sub == self.__sublastshown.get(subkey)):
                continue
            self.__sublastshown[subkey] = sub
            subdone = False
            if subpercent == 100:
                self.__subdone[subkey] = True
                subdone = True
                if fragment:
                    _current, _total, _data = self.__progress
                    self.__progress = (_current+fragment, _total, _data)
                    if _current == _total:
                        self.__lasttime = 0
            elif subkey in self.__subdone:
                subdone = subkey in self.__subdone
            subexpose.append((subkey, subtopic, subpercent, subdata, subdone))
        topic = self.__topic
        percent = int(100*float(current)/(total or 1))
        if subexpose:
            for info in subexpose:
                self.expose(topic, percent, *info)
                if info[-1]:
                    subkey = info[0]
                    del self.__subprogress[subkey]
                    del self.__sublastshown[subkey]
                    del self.__subtopic[subkey]
            if percent == 100 and len(self.__subprogress) == 0:
                self.__done = True
            self.expose(topic, percent, None, None, None, data, self.__done)
        elif (topic, percent) != self.__lastshown:
            if percent == 100 and len(self.__subprogress) == 0:
                self.__done = True
            self.expose(topic, percent, None, None, None, data, self.__done)
        self.__lock.release()

    def expose(self, topic, percent, subkey, subtopic, subpercent, data, done):
        pass

    def setTopic(self, topic):
        self.__topic = topic

    def get(self):
        return self.__progress

    def set(self, current, total, data={}):
        self.__lock.acquire()
        if self.__done:
            self.__lock.release()
            return
        if current > total:
            current = total
        self.__progress = (current, total, data)
        if current == total:
            self.__lasttime = 0
        self.__lock.release()

    def add(self, value):
        self.__lock.acquire()
        if self.__done:
            self.__lock.release()
            return
        current, total, data = self.__progress
        current += value
        if current > total:
            current = total
        self.__progress = (current, total, data)
        if current == total:
            self.__lasttime = 0
        self.__lock.release()

    def addTotal(self, value):
        self.__lock.acquire()
        if self.__done:
            self.__lock.release()
            return
        current, total, data = self.__progress
        self.__progress = (current, total+value, data)
        self.__lock.release()

    def setSubTopic(self, subkey, subtopic):
        self.__lock.acquire()
        if subkey not in self.__subtopic:
            self.__lasttime = 0
        self.__subtopic[subkey] = subtopic
        self.__lock.release()

    def getSub(self, subkey):
        return self.__subprogress.get(subkey)

    def getSubData(self, subkey, _none=[None]):
        return self.__subprogress.get(subkey, _none)[-1]

    def setSub(self, subkey, subcurrent, subtotal, fragment=0, subdata={}):
        self.__lock.acquire()
        if self.__done or subkey in self.__subdone:
            self.__lock.release()
            return
        if subkey not in self.__subtopic:
            self.__subtopic[subkey] = ""
            self.__lasttime = 0
        if subcurrent > subtotal:
            subcurrent = subtotal
        if subcurrent == subtotal:
            self.__lasttime = 0
        self.__subprogress[subkey] = (subcurrent, subtotal, fragment, subdata)
        self.__lock.release()

    def addSub(self, subkey, value):
        self.__lock.acquire()
        if self.__done or subkey in self.__subdone:
            self.__lock.release()
            return
        subcurrent, subtotal, fragment, subdata = self.__subprogress[subkey]
        subcurrent += value
        if subcurrent > subtotal:
            subcurrent = subtotal
        self.__subprogress[subkey] = (subcurrent, subtotal, fragment, subdata)
        if subcurrent == subtotal:
            self.__lasttime = 0
        self.__lock.release()

    def addSubTotal(self, subkey, value):
        self.__lock.acquire()
        if self.__done or subkey in self.__subdone:
            self.__lock.release()
            return
        subcurrent, subtotal, fragment, subdata = self.__subprogress[subkey]
        self.__subprogress[subkey] = (subcurrent, subtotal+value,
                                     fragment, subdata)
        self.__lock.release()

    def setDone(self):
        self.__lock.acquire()
        current, total, data = self.__progress
        self.__progress = (total, total, data)
        self.__lasttime = 0
        self.__lock.release()

    def setSubDone(self, subkey):
        self.__lock.acquire()
        if subkey in self.__subdone:
            self.__lock.release()
            return
        subcurrent, subtotal, fragment, subdata = self.__subprogress[subkey]
        if subcurrent != subtotal:
            self.__subprogress[subkey] = (subtotal, subtotal, fragment, subdata)
        self.__lasttime = 0
        self.__lock.release()

    def setStopped(self):
        self.__lock.acquire()
        self.__done = True
        self.__lasttime = 0
        self.__lock.release()

    def setSubStopped(self, subkey):
        self.__lock.acquire()
        self.__subdone[subkey] = True
        self.__lasttime = 0
        self.__lock.release()

    def resetSub(self, subkey):
        self.__lock.acquire()
        if subkey in self.__subdone:
            del self.__subdone[subkey]
        if subkey in self.__subprogress:
            (subcurrent, subtotal, fragment, subdata) = \
                self.__subprogress[subkey]
            self.__subprogress[subkey] = (0, subtotal, fragment, {})
        self.__lasttime = 0
        self.__lock.release()
