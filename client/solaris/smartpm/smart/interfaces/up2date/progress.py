#
# Copyright (c) 2004 Conectiva, Inc.
# Copyright (c) 2005 Red Hat, Inc.
#
# From code written by Gustavo Niemeyer <niemeyer@conectiva.com>
# Modified by Joel Martin <jmartin@redhat.com>
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
from smart.interface import getScreenWidth
from smart.util.strtools import ShortURL
from smart.progress import Progress
import posixpath
import time
import sys

class Up2dateProgress(Progress):

    def __init__(self):
        Progress.__init__(self)
        self._lasttopic = None
        self._lastsubkey = None
        self._lastsubkeystart = 0
        self._fetchermode = False
        self._seentopics = {}
        self._addline = False
        self.setScreenWidth(getScreenWidth())

    def setScreenWidth(self, width):
        self._screenwidth = width
        self._topicwidth = int(width*0.4)
        self._hashwidth = int(width-self._topicwidth-1)
        self._topicmask = "%%-%d.%ds" % (self._topicwidth, self._topicwidth)
        self._topicmaskn = "%%4d:%%-%d.%ds" % (self._topicwidth-5,
                                               self._topicwidth-5)
        self._shorturl = ShortURL(width-4)

    def setFetcherMode(self, flag):
        self._fetchermode = flag

    def stop(self):
        Progress.stop(self)
        self._shorturl.reset()
        print

    def expose(self, topic, percent, subkey, subtopic, subpercent, data, done):
        out = sys.stderr
        if self.getHasSub():
            if topic != self._lasttopic:
                self._lasttopic = topic
                out.write(" "*(self._screenwidth-1)+"\r")
                if self._addline:
                    print
                else:
                    self._addline = True
                print topic
            if not subkey:
                return
            if not done:
                now = time.time()
                if subkey == self._lastsubkey:
                    if (self._lastsubkeystart+2 < now and
                        self.getSubCount() > 1):
                        return
                else:
                    if (self._lastsubkeystart+2 > now and
                        self.getSubCount() > 1):
                        return
                    self._lastsubkey = subkey
                    self._lastsubkeystart = now
            elif subkey == self._lastsubkey:
                    self._lastsubkeystart = 0
            current = subpercent
            topic = subtopic
            if self._fetchermode:
                if topic not in self._seentopics:
                    self._seentopics[topic] = True
                    out.write(" "*(self._screenwidth-1)+"\r")
                    print "->", self._shorturl.get(topic)
                topic = posixpath.basename(topic)
        else:
            current = percent
        n = data.get("item-number")
        if n:
            if len(topic) > self._topicwidth-6:
                topic = topic[:self._topicwidth-8]+".."
            out.write(self._topicmaskn % (n, topic))
        else:
            if len(topic) > self._topicwidth-1:
                topic = topic[:self._topicwidth-3]+".."
            out.write(self._topicmask % topic)

        if not done:
            speed = data.get("speed")
            if speed:
                suffix = "(%s - %d%%)\r" % (speed, current)
            else:
                suffix = "(%3d%%)\r" % current
        elif subpercent is None:
            suffix = "[%3d%%]\n" % current
        else:
            suffix = "[%3d%%]\n" % percent

        hashwidth = self._hashwidth-len(suffix)

        hashes = int(hashwidth*current/100)
        out.write("#"*hashes)
        out.write(" "*(hashwidth-hashes+1))

        out.write(suffix)
        out.flush()

def test():
    prog = Up2dateProgress()
    data = {"item-number": 0}
    total, subtotal = 100, 100
    prog.setHasSub(True)
    prog.start()
    prog.setTopic("Installing packages...")
    for n in range(1,total+1):
        data["item-number"] = n
        prog.set(n, total)
        prog.setSubTopic(n, "package-name%d" % n)
        for i in range(0,subtotal+1):
            prog.setSub(n, i, subtotal, subdata=data)
            prog.show()
            time.sleep(0.01)
    prog.stop()

if __name__ == "__main__":
    test()
