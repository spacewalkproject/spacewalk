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
from smart.backends.rpm.header import RPMPackageListLoader
from smart.util.filetools import getFileDigest
from smart.channel import PackageChannel
from smart.const import SUCCEEDED, FAILED, NEVER
from smart import *
import posixpath
import tempfile
import commands
import os

class APTRPMChannel(PackageChannel):

    def __init__(self, baseurl, comps, fingerprint, *args):
        super(APTRPMChannel, self).__init__(*args)
        self._baseurl = baseurl
        self._comps = comps
        if fingerprint:
            self._fingerprint = "".join([x for x in fingerprint
                                         if not x.isspace()])
        else:
            self._fingerprint = None

    def getCacheCompareURLs(self):
        return [posixpath.join(self._baseurl, "base/release")]

    def getFetchSteps(self):
        return len(self._comps)*2+1

    def fetch(self, fetcher, progress):

        fetcher.reset()

        # Fetch release file
        item = fetcher.enqueue(posixpath.join(self._baseurl, "base/release"))
        fetcher.run(progress=progress)
        failed = item.getFailedReason()
        if failed:
            progress.add(self.getFetchSteps()-1)
            progress.show()
            if fetcher.getCaching() is NEVER:
                lines = [_("Failed acquiring information for '%s':") % self,
                         "%s: %s" % (item.getURL(), failed)]
                raise Error, "\n".join(lines)
            return False

        digest = getFileDigest(item.getTargetPath())
        if digest == self._digest:
            progress.add(self.getFetchSteps()-1)
            progress.show()
            return True
        self.removeLoaders()

        # Parse release file
        md5sum = {}
        insidemd5sum = False
        hassignature = False
        for line in open(item.getTargetPath()):
            if line.startswith("-----BEGIN"):
                hassignature = True
                break
            elif not insidemd5sum:
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
            rfd, rname = tempfile.mkstemp()
            sfd, sname = tempfile.mkstemp()
            rfile = os.fdopen(rfd, "w")
            sfile = os.fdopen(sfd, "w")
            try:
                if not hassignature:
                    raise Error, _("Channel '%s' has fingerprint but is not "
                                   "signed") % self

                file = rfile
                for line in open(item.getTargetPath()):
                    if line.startswith("-----BEGIN"):
                        file = sfile
                    file.write(line)
                rfile.close()
                sfile.close()

                status, output = commands.getstatusoutput(
                    "gpg --batch --no-secmem-warning --status-fd 1 "
                    "--verify %s %s" % (sname, rname))

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
                    raise Error, _("Channel '%s' signed with unknown key")%self
            except Error, e:
                progress.add(self.getFetchSteps()-1)
                progress.show()
                rfile.close()
                sfile.close()
                os.unlink(rname)
                os.unlink(sname)
                if fetcher.getCaching() is NEVER:
                    raise
                else:
                    return False
            else:
                os.unlink(rname)
                os.unlink(sname)

        # Fetch component package lists and release files
        fetcher.reset()
        pkgitems = []
        relitems = []
        for comp in self._comps:
            pkglist = "base/pkglist."+comp
            url = posixpath.join(self._baseurl, pkglist)
            if pkglist+".bz2" in md5sum:
                upkglist = pkglist
                pkglist += ".bz2"
                url += ".bz2"
            elif pkglist+".gz" in md5sum:
                upkglist = pkglist
                pkglist += ".gz"
                url += ".gz"
            elif pkglist not in md5sum:
                iface.warning(_("Component '%s' is not in release file "
                                "for channel '%s'") % (comp, self))
                continue
            else:
                upkglist = None
            info = {"component": comp, "uncomp": True}
            info["md5"], info["size"] = md5sum[pkglist]
            if upkglist:
                info["uncomp_md5"], info["uncomp_size"] = md5sum[upkglist]
            pkgitems.append(fetcher.enqueue(url, **info))

            release = "base/release."+comp
            if release in md5sum:
                url = posixpath.join(self._baseurl, release)
                info = {"component": comp}
                info["md5"], info["size"] = md5sum[release]
                relitems.append(fetcher.enqueue(url, **info))
            else:
                progress.add(1)
                progress.show()
                relitems.append(None)

        fetcher.run(progress=progress)

        errorlines = []
        for i in range(len(pkgitems)):
            pkgitem = pkgitems[i]
            relitem = relitems[i]
            if pkgitem.getStatus() == SUCCEEDED:
                count = None
                if relitem and relitem.getStatus() == SUCCEEDED:
                    try:
                        for line in open(relitem.getTargetPath()):
                            if line.startswith("PackageCount:"):
                                count = int(line[13:])
                                break
                    except (IOError, ValueError):
                        pass
                localpath = pkgitem.getTargetPath()
                loader = RPMPackageListLoader(localpath, self._baseurl, count)
                loader.setChannel(self)
                self._loaders.append(loader)
            else:
                errorlines.append(u"%s: %s" % (pkgitem.getURL(),
                                               pkgitem.getFailedReason()))
        if errorlines:
            if fetcher.getCaching() is NEVER:
                errorlines.insert(0, _("Failed acquiring information for "
                                       "'%s':") % self)
                raise Error, "\n".join(errorlines)
            return False

        self._digest = digest

        return True

def create(alias, data):
    return APTRPMChannel(data["baseurl"],
                         data["components"].split(),
                         data["fingerprint"],
                         data["type"],
                         alias,
                         data["name"],
                         data["manual"],
                         data["removable"],
                         data["priority"])

# vim:ts=4:sw=4:et
