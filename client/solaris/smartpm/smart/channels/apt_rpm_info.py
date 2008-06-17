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
from smart import _

kind = "package"

name = _("APT-RPM Repository")

description = _("""
Repositories created for APT-RPM.
""")

fields = [("baseurl", _("Base URL"), str, None,
           _("Base URL of APT-RPM repository, where base/ is located.")),
          ("components", _("Components"), str, None,
           _("Space separated list of components.")),
          ("fingerprint", _("Fingerprint"), str, "",
           _("GPG fingerprint of key signing the channel."))]

def detectLocalChannels(path, media):
    import os
    channels = []
    if os.path.isfile(os.path.join(path, "base/release")):
        components = {}
        for entry in os.listdir(os.path.join(path, "base")):
            if entry.startswith("pkglist."):
                entry = entry[8:]
                if entry.endswith(".bz2"):
                    entry = entry[:-4]
                elif entry.endswith(".gz"):
                    entry = entry[:-3]
                components[entry] = True
        for component in components.keys():
            if not os.path.isdir(os.path.join(path, "RPMS."+component)):
                del components[component]
        if components:
            if media:
                baseurl = "localmedia://"
                baseurl += path[len(media.getMountPoint()):]
            else:
                baseurl = "file://"
                baseurl += path
            components = " ".join(components.keys())
            channel = {"baseurl": baseurl, "components": components}
            if media:
                infofile = os.path.join(media.getMountPoint(), ".disk/info")
                if os.path.isfile(infofile):
                    file = open(infofile)
                    channel["name"] = file.read().strip()
                    file.close()
            channels.append(channel)
    return channels

