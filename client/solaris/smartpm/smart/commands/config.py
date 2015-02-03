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
import pprint
import string
import re

USAGE=_("smart config [options]")

DESCRIPTION=_("""
This command allows changing the internal configuration
representation arbitrarily. This is supposed to be used
by advanced users only, and is generally not needed.
""")

EXAMPLES=_("""
smart config --set someoption.suboption=10
smart config --remove someoption
smart config --show someoption
smart config --show
""")

def parse_options(argv):
    parser = OptionParser(usage=USAGE,
                          description=DESCRIPTION,
                          examples=EXAMPLES)
    parser.defaults["set"] = []
    parser.defaults["remove"] = []
    parser.defaults["show"] = None
    parser.add_option("--set", action="callback", callback=append_all,
                      help=_("set given key=value options"))
    parser.add_option("--show", action="callback", callback=append_all,
                      help=_("show given options"))
    parser.add_option("--remove", action="callback", callback=append_all,
                      help=_("remove given options"))
    parser.add_option("--force", action="store_true",
                      help=_("ignore problems"))
    opts, args = parser.parse_args(argv)
    opts.args = args
    return opts

SETRE = re.compile(r"^(\S+?)(\+?=)(.*)$")
DELRE = re.compile(r"^(\S+?)(?:=(.*))?$")

def main(ctrl, opts):

    globals = {}
    globals["__builtins__"] = {}
    globals["True"] = True
    globals["true"] = True
    globals["yes"] = True
    globals["False"] = False
    globals["false"] = False
    globals["no"] = False

    if opts.set:
        for opt in opts.set:
            m = SETRE.match(opt)
            if not m:
                raise Error, _("Invalid --set argument: %s") % opt
            path, assign, value = m.groups()
            try:
                value = int(value)
            except ValueError:
                try:
                    value = eval(value, globals)
                except:
                    pass
            if assign == "+=":
                sysconf.add(path, value, unique=True)
            else:
                sysconf.set(path, value)

    if opts.remove:
        for opt in opts.remove:
            m = DELRE.match(opt)
            if not m:
                raise Error, _("Invalid --remove argument: %s") % opt
            path, value = m.groups()
            if value:
                try:
                    value = int(value)
                except ValueError:
                    try:
                        value = eval(value, globals)
                    except:
                        pass
                removed = sysconf.remove(path, value)
            else:
                removed = sysconf.remove(path)
            if not removed:
                iface.warning(_("Option '%s' not found.") % path)

    if opts.show is not None:
        if opts.show:
            marker = object()
            for opt in opts.show:
                value = sysconf.get(opt, marker)
                if value is marker:
                    iface.warning(_("Option '%s' not found.") % opt)
                else:
                    pprint.pprint(value)
        else:
            pprint.pprint(sysconf.get((), hard=True))
