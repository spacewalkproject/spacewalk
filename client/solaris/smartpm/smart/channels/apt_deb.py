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
from smart.backends.deb.loader import DebTagFileLoader
from smart.util.filetools import getFileDigest
from smart.backends.deb.base import DEBARCH
from smart.channel import PackageChannel
from smart.const import SUCCEEDED, NEVER
from smart import *
import posixpath
import commands
import md5
import os

class APTDEBChannel(PackageChannel):

    def __init__(self, baseurl, distro, comps, fingerprint, *args):
        super(APTDEBChannel, self).__init__(*args)

        self._baseurl = baseurl
        self._distro = distro
        self._comps = comps
        if fingerprint:
            self._fingerprint = "".join([x for x in fingerprint
                                         if not x.isspace()])
        else:
            self._fingerprint = None

    def _getURL(self, filename="", component=None, subpath=False):
        if subpath:
            distrourl = ""
        else:
            distrourl = posixpath.join(self._baseurl, "dists", self._distro)
        if component:
            return posixpath.join(distrourl, component,
                                  "binary-"+DEBARCH, filename)
        else:
            return posixpath.join(distrourl, filename)

    def getCacheCompareURLs(self):
        return [self._getURL("Release")]

    def getFetchSteps(self):
        # Release files are not being used
        #return len(self._comps)*2+2
        return len(self._comps)+2

    def fetch(self, fetcher, progress):

        fetcher.reset()

        # Fetch release file
        item = fetcher.enqueue(self._getURL("Release"))
        gpgitem = fetcher.enqueue(self._getURL("Release.gpg"))
        fetcher.run(progress=progress)
        failed = item.getFailedReason()
        if failed:
            progress.add(self.getFetchSteps()-2)
            progress.show()
            if fetcher.getCaching() is NEVER:
                lines = [_("Failed acquiring information for '%s':") % self,
                         u"%s: %s" % (item.getURL(), failed)]
                raise Error, "\n".join(lines)
            return False

        digest = getFileDigest(item.getTargetPath())
        if digest == self._digest:
            progress.add(self.getFetchSteps()-2)
            progress.show()
            return True
        self.removeLoaders()

        # Parse release file
        md5sum = {}
        insidemd5sum = False
        for line in open(item.getTargetPath()):
            if not insidemd5sum:
                if line.startswith("MD5Sum:"):
                    insidemd5sum = True
            elif not line.startswith(" "):
                insidemd5sum = False
            else:
                try:
                    md5, size, path = line.split()
                except ValueError:
                    pass
                else:
                    md5sum[path] = (md5, int(size))

        if self._fingerprint:
            try:
                failed = gpgitem.getFailedReason()
                if failed:
                    raise Error, _("Channel '%s' has fingerprint but download "
                                   "of Release.gpg failed: %s")%(self, failed)

                status, output = commands.getstatusoutput(
                    "gpg --batch --no-secmem-warning --status-fd 1 "
                    "--verify %s %s" % (gpgitem.getTargetPath(),
                                        item.getTargetPath()))

                badsig = False
                goodsig = False
                validsig = None
                for line in output.splitlines():
                    if line.startswith("[GNUPG:]"):
                        tokens = line[8:].split()
                        first = tokens[0]
                        if first == "VALIDSIG":
                            validsig = tokens[1]
                        elif first == "GOODSIG":
                            goodsig = True
                        elif first == "BADSIG":
                            badsig = True
                if badsig:
                    raise Error, _("Channel '%s' has bad signature") % self
                if not goodsig or validsig != self._fingerprint:
                    raise Error, _("Channel '%s' signed with unknown key") \
                                 % self
            except Error, e:
                progress.add(self.getFetchSteps()-2)
                progress.show()
                if fetcher.getCaching() is NEVER:
                    raise
                else:
                    return False

        # Fetch component package lists and release files
        fetcher.reset()
        pkgitems = []
        #relitems = []
        for comp in self._comps:
            packages = self._getURL("Packages", comp, subpath=True)
            url = self._getURL("Packages", comp)
            if packages+".bz2" in md5sum:
                upackages = packages
                packages += ".bz2"
                url += ".bz2"
            elif packages+".gz" in md5sum:
                upackages = packages
                packages += ".gz"
                url += ".gz"
            elif packages not in md5sum:
                iface.warning(_("Component '%s' is not in Release file "
                                "for channel '%s'") % (comp, self))
                continue
            else:
                upackages = None
            info = {"component": comp, "uncomp": True}
            info["md5"], info["size"] = md5sum[packages]
            if upackages:
                info["uncomp_md5"], info["uncomp_size"] = md5sum[upackages]
            pkgitems.append(fetcher.enqueue(url, **info))

            #release = self._getURL("Release", comp, subpath=True)
            #if release in md5sum:
            #    url = self._getURL("Release", comp)
            #    info = {"component": comp}
            #    info["md5"], info["size"] = md5sum[release]
            #    relitems.append(fetcher.enqueue(url, **info))
            #else:
            #    progress.add(1)
            #    progress.show()
            #    relitems.append(None)

        fetcher.run(progress=progress)

        errorlines = []
        for i in range(len(pkgitems)):
            pkgitem = pkgitems[i]
            #relitem = relitems[i]
            if pkgitem.getStatus() == SUCCEEDED:
                # Release files for components are not being used.
                #if relitem and relitem.getStatus() == SUCCEEDED:
                #    try:
                #        for line in open(relitem.getTargetPath()):
                #            if line.startswith("..."):
                #                pass
                #    except (IOError, ValueError):
                #        pass
                localpath = pkgitem.getTargetPath()
                loader = DebTagFileLoader(localpath, self._baseurl)
                loader.setChannel(self)
                self._loaders.append(loader)
            else:
                errorlines.append(u"%s: %s" % (pkgitem.getURL(),
                                               pkgitem.getFailedReason()))

        if errorlines:
            if fetcher.getCaching() is NEVER:
                errorlines.insert(0, _("Failed acquiring information for '%s':")
                                     % self)
                raise Error, "\n".join(errorlines)
            return False

        self._digest = digest

        return True

def create(alias, data):
    return APTDEBChannel(data["baseurl"],
                         data["distribution"],
                         data["components"].split(),
                         data["fingerprint"],
                         data["type"],
                         alias,
                         data["name"],
                         data["manual"],
                         data["removable"],
                         data["priority"])
