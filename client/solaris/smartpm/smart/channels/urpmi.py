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
from smart.backends.rpm.synthesis import URPMISynthesisLoader
from smart.backends.rpm.header import URPMILoader
from smart.util.filetools import getFileDigest
from smart.const import SUCCEEDED, FAILED, ALWAYS, NEVER
from smart.channel import PackageChannel
from smart import *
import posixpath
import re
import os

class URPMIChannel(PackageChannel):

    def __init__(self, baseurl, hdlurl, *args):
        super(URPMIChannel, self).__init__(*args)
        self._baseurl = baseurl
        if hdlurl:
            self._hdlurl = hdlurl
        else:
            self._hdlurl = posixpath.join(self._baseurl, "hdlist.cz")
        self._compareurl = self._hdlurl

    def getCacheCompareURLs(self):
        return [self._compareurl]

    def getFetchSteps(self):
        return 3

    def fetch(self, fetcher, progress):

        fetcher.reset()

        self._compareurl = self._hdlurl

        hdlbaseurl, basename = os.path.split(self._hdlurl)
        md5url = posixpath.join(hdlbaseurl, "MD5SUM")
        item = fetcher.enqueue(md5url)
        fetcher.run(progress=progress)
        hdlmd5 = None
        failed = item.getFailedReason()
        if not failed:
            self._compareurl = md5url
            digest = getFileDigest(item.getTargetPath())
            if digest == self._digest:
                progress.add(2)
                return True

            basename = posixpath.basename(self._hdlurl)
            for line in open(item.getTargetPath()):
                md5, name = line.split()
                if name == basename:
                    hdlmd5 = md5
                    break

        fetcher.reset()
        hdlitem = fetcher.enqueue(self._hdlurl, md5=hdlmd5, uncomp=True)

        if self._hdlurl.endswith("/list"):
            listitem = None
        else:
            m = re.compile(r"/(?:synthesis\.)?hdlist(.*)\.") \
                  .search(self._hdlurl)
            suffix = m and m.group(1) or ""
            listurl = posixpath.join(hdlbaseurl, "list%s" % suffix)
            listitem = fetcher.enqueue(listurl, uncomp=True)

        fetcher.run(progress=progress)

        if hdlitem.getStatus() == FAILED:
            failed = hdlitem.getFailedReason()
            if fetcher.getCaching() is NEVER:
                lines = [_("Failed acquiring information for '%s':") % self,
                         u"%s: %s" % (hdlitem.getURL(), failed)]
                raise Error, "\n".join(lines)
            return False
        else:
            localpath = hdlitem.getTargetPath()
            digestpath = None
            if listitem and listitem.getStatus() == SUCCEEDED:
                if self._compareurl == self._hdlurl:
                    self._compareurl = listurl
                    digestpath = localpath
                listpath = listitem.getTargetPath()
            else:
                listpath = None
                if self._compareurl == self._hdlurl:
                    digestpath = localpath
            if digestpath:
                digest = getFileDigest(digestpath)
                if digest == self._digest:
                    return True
            self.removeLoaders()
            if localpath.endswith(".cz"):
                if (not os.path.isfile(localpath[:-3]) or
                    fetcher.getCaching() != ALWAYS):
                    linkpath = fetcher.getLocalPath(hdlitem)
                    linkpath = linkpath[:-2]+"gz"
                    if not os.access(os.path.dirname(linkpath), os.W_OK):
                        dirname = os.path.join(sysconf.get("user-data-dir"),
                                               "channels")
                        basename = os.path.basename(linkpath)
                        if not os.path.isdir(dirname):
                            os.makedirs(dirname)
                        linkpath = os.path.join(dirname, basename)
                    if os.path.isfile(linkpath):
                        os.unlink(linkpath)
                    os.symlink(localpath, linkpath)
                    localpath = linkpath
                    uncompressor = fetcher.getUncompressor()
                    uncomphandler = uncompressor.getHandler(linkpath)
                    try:
                        uncomphandler.uncompress(linkpath)
                    except Error, e:
                        # cz file has trailing information which breaks
                        # current gzip module logic.
                        if "Not a gzipped file" not in e[0]:
                            os.unlink(linkpath)
                            raise
                    os.unlink(linkpath)
                localpath = localpath[:-3]

            if open(localpath).read(4) == "\x8e\xad\xe8\x01":
                loader = URPMILoader(localpath, self._baseurl, listpath)
            else:
                loader = URPMISynthesisLoader(localpath, self._baseurl, listpath)

            loader.setChannel(self)
            self._loaders.append(loader)

        self._digest = digest

        return True

def create(alias, data):
    return URPMIChannel(data["baseurl"],
                        data["hdlurl"],
                        data["type"],
                        alias,
                        data["name"],
                        data["manual"],
                        data["removable"],
                        data["priority"])
