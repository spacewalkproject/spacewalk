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
from smart.transaction import Transaction, PolicyInstall, sortUpgrades
from smart.transaction import INSTALL, REINSTALL
from smart.option import OptionParser, append_all
from smart.cache import Package
from smart import *
import string
import re
import os

USAGE=_("smart download [options] package ...")

DESCRIPTION=_("""
This command allows downloading one or more given packages.
""")

EXAMPLES=_("""
smart download pkgname
smart download '*kgna*'
smart download pkgname-1.0
smart download pkgname-1.0-1
smart download pkgname1 pkgname2
smart download pkgname --urls 2> pkgname-url.txt
smart download --from-urls pkgname-url.txt
smart download --from-urls http://some.url/some/path/somefile
""")

def parse_options(argv):
    parser = OptionParser(usage=USAGE,
                          description=DESCRIPTION,
                          examples=EXAMPLES)
    parser.defaults["from_urls"] = []
    parser.defaults["target"] = os.getcwd()
    parser.add_option("--target", action="store", metavar="DIR",
                      help=_("packages will be saved in given directory"))
    parser.add_option("--urls", action="store_true",
                      help=_("dump needed urls and don't download packages"))
    parser.add_option("--from-urls", action="callback", callback=append_all,
                      help=_("download files from the given urls and/or from "
                             "the given files with lists of urls"))
    opts, args = parser.parse_args(argv)
    opts.args = args
    if not os.path.isdir(opts.target):
        raise Error, _("Directory not found:"), opts.target
    return opts

def main(ctrl, opts):

    packages = []
    if opts.args:
        ctrl.reloadChannels()
        cache = ctrl.getCache()
        packages = {}
        for arg in opts.args:

            ratio, results, suggestions = ctrl.search(arg)

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

            pkgs = []

            for obj in results:
                if isinstance(obj, Package):
                    pkgs.append(obj)

            if not pkgs:
                installed = False
                names = {}
                for obj in results:
                    for pkg in obj.packages:
                        if pkg.installed:
                            iface.warning(_("%s (for %s) is already installed")
                                          % (pkg, arg))
                            installed = True
                            break
                        else:
                            pkgs.append(pkg)
                            names[pkg.name] = True
                    else:
                        continue
                    break
                if installed:
                    continue
                if len(names) > 1:
                    raise Error, _("There are multiple matches for '%s':\n%s") % \
                                  (arg, "\n".join(["    "+str(x) for x in pkgs]))

            if len(pkgs) > 1:
                sortUpgrades(pkgs)

            names = {}
            for pkg in pkgs:
                names.setdefault(pkg.name, []).append(pkg)
            for name in names:
                packages[names[name][0]] = True

        packages = packages.keys()

        if opts.urls:
            ctrl.dumpURLs(packages)
        else:
            ctrl.downloadPackages(packages, targetdir=opts.target)
    elif opts.from_urls:
        urls = []
        for arg in opts.from_urls:
            if ":/" in arg:
                urls.append(arg)
            elif os.path.isfile(arg):
                urls.extend([x.strip() for x in open(arg)])
            else:
                raise Error, _("Argument is not a file nor url: %s") % arg
        ctrl.downloadURLs(urls, _("URLs"), targetdir=opts.target)
