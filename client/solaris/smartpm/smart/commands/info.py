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
from smart.util.strtools import sizeToStr
from smart.option import OptionParser
from smart.cache import Package
from smart import *
import re

USAGE=_("smart info [options] [package] ...")

DESCRIPTION=_("""
This command will show information about the given packages.
""")

EXAMPLES=_("""
smart info pkgname
smart info pkgname-1.0
smart info pkgname --urls --paths
""")

def parse_options(argv):
    parser = OptionParser(usage=USAGE,
                          description=DESCRIPTION,
                          examples=EXAMPLES)
    parser.add_option("--urls", action="store_true",
                      help=_("show URLs"))
    parser.add_option("--paths", action="store_true",
                      help=_("show path list"))
    opts, args = parser.parse_args(argv)
    opts.args = args
    return opts

def main(ctrl, opts, reloadchannels=True):

    if reloadchannels:
        ctrl.reloadChannels()

    cache = ctrl.getCache()

    if opts.args:
        pkgs = {}
        for arg in opts.args:
            ratio, results, suggestions = ctrl.search(arg, addprovides=False)

            if not results:
                if suggestions:
                    dct = {}
                    for r, obj in suggestions:
                        if isinstance(obj, Package):
                            dct[obj] = True
                        else:
                            dct.update(dict.fromkeys(obj.packages, True))
                    raise Error, _("'%s' matches no packages. "
                                   "Suggestions:\n%s") % \
                                 (arg, "\n".join(["    "+str(x) for x in dct]))
                else:
                    raise Error, _("'%s' matches no packages") % arg

            dct = {}
            for obj in results:
                if isinstance(obj, Package):
                    dct[obj] = True
                else:
                    dct.update(dict.fromkeys(obj.packages, True))
            pkgs.update(dct)
        pkgs = pkgs.keys()
    else:
        pkgs = cache.getPackages()

    for pkg in pkgs:
        channels = {}
        infos = []
        for loader in pkg.loaders:
            channel = loader.getChannel()
            info = loader.getInfo(pkg)
            infos.append(info)
            urls = info.getURLs()
            map = channels.setdefault(str(channel), {})
            if urls:
                map.setdefault("urls", []).extend(urls)

        infos.sort()
        info = infos[0]

        print _("Name:"), pkg.name
        print _("Version:"), pkg.version
        print _("Priority:"), pkg.getPriority()
        print _("Group:"), info.getGroup()
        print _("Installed Size:"), sizeToStr(info.getInstalledSize())
        print _("Reference URLs:"), " ".join(info.getReferenceURLs())


        flags = pkgconf.testAllFlags(pkg)
        if flags:
            flags.sort()
            flags = "%s" % ", ".join(flags)
        else:
            flags = ""
        print _("Flags:"), flags

        print _("Channels:"),
        channelnames = channels.keys()
        channelnames.sort()
        print "; ".join(channelnames)

        print _("Summary:"), info.getSummary()
        print _("Description:")
        for line in info.getDescription().splitlines():
            line = line.strip()
            if not line:
                line = "."
            print "", line

        if opts.urls:
            print _("URLs:")
            seen = {}
            for loader in pkg.loaders:
                if loader not in seen:
                    seen[loader] = True
                    info = loader.getInfo(pkg)
                    first = True
                    for url in info.getURLs():
                        if first:
                            print "", loader.getChannel()
                            first = False
                        size = info.getSize(url)
                        if size:
                            print "   ", url, "(%s)" % sizeToStr(size)
                        else:
                            print "   ", url

        if opts.paths:
            print _("Paths:")
            for entry in info.getPathList():
                print "", entry
        print
