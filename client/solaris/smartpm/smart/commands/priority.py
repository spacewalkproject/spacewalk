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
from smart.option import OptionParser
from smart import *
import string
import re

USAGE=_("smart priority [options]")

DESCRIPTION=_("""
This command allows changing the priority of given packages.
Packages with higher priorities are considered a better option
even when package versions state otherwise. Using priorities
one may avoid unwanted upgrades, force downgrades, select
packages in given channels as preferential, and other kinds
of interesting setups. When a package has no explicit priority,
the channel priority is used. The channel priority may be
changed using the 'channel' command, and defaults to 0 when
not set.

Notice that negatives priorities must be preceded by '--' in
the command line, otherwise they'll be interpreted as command
line options.
""")

EXAMPLES=_("""
smart priority --set pkgname 100
smart priority --set pkgname mychannel -- -200
smart priority --remove pkgname
smart priority --remove pkgname mychannel
smart priority --show
smart priority --show pkgname
""")

def parse_options(argv):
    parser = OptionParser(usage=USAGE,
                          description=DESCRIPTION,
                          examples=EXAMPLES)
    parser.add_option("--set", action="store_true",
                      help=_("set priority"))
    parser.add_option("--remove", action="store_true",
                      help=_("unset priority"))
    parser.add_option("--show", action="store_true",
                      help=_("show priorities"))
    parser.add_option("--force", action="store_true",
                      help=_("ignore problems"))
    opts, args = parser.parse_args(argv)
    opts.args = args
    return opts

def main(ctrl, opts):

    if opts.set:
        if len(opts.args) == 2:
            name, priority = opts.args
            alias = None
        elif len(opts.args) == 3:
            name, alias, priority = opts.args
        else:
            raise Error, _("Invalid arguments")
        try:
            priority = int(priority)
        except ValueError:
            raise Error, _("Invalid priority")
        pkgconf.setPriority(name, alias, priority)

    elif opts.remove:
        if len(opts.args) == 1:
            name = opts.args[0]
            alias = None
        elif len(opts.args) == 2:
            name, alias = opts.args
        else:
            raise Error, _("Invalid arguments")
        if not pkgconf.removePriority(name, alias):
            iface.warning(_("Priority not found"))

    elif opts.show:
        header = (_("Package"), _("Channel"), _("Priority"))
        print "%-30s %-20s %s" % header
        print "-"*(52+len(header[-1]))
        priorities = sysconf.get("package-priorities", {})
        showpriorities = opts.args or priorities.keys()
        showpriorities.sort()
        for name in showpriorities:
            pkgpriorities = priorities.get(name)
            aliases = pkgpriorities.keys()
            aliases.sort()
            for alias in aliases:
                priority = pkgpriorities[alias]
                print "%-30s %-20s %d" % (name, alias or "*", priority)
        print
