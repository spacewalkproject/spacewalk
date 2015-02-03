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
from smart.option import OptionParser, append_all
from smart import *
import string
import re

USAGE=_("smart flag [options]")

DESCRIPTION=_("""
This command allows one to set, remove, and show package flags.
Package flags are used to tune the behavior of some algorithms
when dealing with the given packages.

Currently known flags are:

  lock          - Flagged packages will not be removed, if they
                  are currently installed, nor installed, if they
                  are currently available.
  new           - Flagged packages were considered new packages
                  in the repository when the last update was done.
                  This flag is automatically manipulated by the
                  system.
  multi-version - Flagged packages may have more than one version
                  installed in the system at the same time
                  (backend dependent).
""")

EXAMPLES=_("""
smart flag --show
smart flag --show new
smart flag --set lock pkgname
smart flag --remove lock pkgname
smart flag --set lock 'pkgname >= 1.0'
smart flag --remove lock 'pkgname >= 1.0'
""")

def parse_options(argv):
    parser = OptionParser(usage=USAGE,
                          description=DESCRIPTION,
                          examples=EXAMPLES)
    parser.defaults["set"] = []
    parser.defaults["remove"] = []
    parser.defaults["show"] = None
    parser.add_option("--set", action="callback", callback=append_all,
                      help=_("set flags given in pairs of flag name/target, "
                             "where targets may use just the package "
                             "name, or the package name, relation, and "
                             "version, such as: lock 'python > 1.0'"))
    parser.add_option("--remove", action="callback", callback=append_all,
                      help=_("remove flags given in pairs of flag name/target, "
                             "where targets may use just the package "
                             "name, or the package name, relation, and "
                             "version, such as: lock 'python > 1.0'"))
    parser.add_option("--show", action="callback", callback=append_all,
                      help=_("show packages with the flags given as arguments "
                             "or all flags if no argument was given"))
    parser.add_option("--force", action="store_true",
                      help=_("ignore problems"))
    opts, args = parser.parse_args(argv)
    opts.args = args
    return opts

TARGETRE = re.compile(r"^\s*(?P<name>\S+?)\s*"
                      r"((?P<rel>[<>=]+)\s*"
                      r"(?P<version>\S+))?\s*$")

def main(ctrl, opts):

    for args in (opts.set, opts.remove):
        if len(args) % 2 != 0:
            raise Error, _("Invalid arguments")
        for i in range(0, len(args), 2):
            flag, target = args[i:i+2]
            m = TARGETRE.match(target)
            if not m:
                raise Error, _("Invalid target: %s") % arg
            if args is opts.set:
                pkgconf.setFlag(flag, m.group("name"),
                                m.group("rel"), m.group("version"))
            else:
                pkgconf.clearFlag(flag, m.group("name"),
                                  m.group("rel"), m.group("version"))

    if opts.show is not None:
        showflags = opts.show or pkgconf.getFlagNames()
        showflags.sort()
        for flag in showflags:
            flag = flag.strip()
            print flag
            names = pkgconf.getFlagTargets(flag)
            nameslst = names.keys()
            nameslst.sort()
            for name in nameslst:
                for relation, version in names[name]:
                    if relation and version:
                        print "   ", name, relation, version
                    else:
                        print "   ", name
            print
