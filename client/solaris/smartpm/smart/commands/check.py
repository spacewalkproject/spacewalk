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
from smart.transaction import checkPackages
from smart.option import OptionParser
from smart.cache import Package
from smart import *
import string
import re

USAGE=_("smart check [options] [package] ...")

DESCRIPTION=_("""
This command will check relations of the given installed
packages. If no packages are given, all installed packages
will be checked. Use the 'fix' command to fix broken
relations.
""")

EXAMPLES=_("""
smart check
smart check pkgname
smart check '*kgna*'
smart check pkgname-1.0
smart check pkgname-1.0-1
smart check pkgname1 pkgname2
""")

def parse_options(argv):
    parser = OptionParser(usage=USAGE,
                          description=DESCRIPTION,
                          examples=EXAMPLES)
    parser.add_option("--all", action="store_true",
                      help=_("check uninstalled packages as well"))
    parser.add_option("--uninstalled", action="store_true",
                      help=_("check only uninstalled packages"))
    opts, args = parser.parse_args(argv)
    opts.args = args
    return opts

def main(ctrl, opts):

    ctrl.reloadChannels()
    cache = ctrl.getCache()

    if opts.args:
        pkgs = {}
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

    return not checkPackages(cache, pkgs, report=True,
                             all=opts.all, uninstalled=opts.uninstalled)
