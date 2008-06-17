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
from smart.commands import query
from smart import *

HELP=_("""
Usage: smart search expression ...

This command allows searching for the given expressions
in the name, summary, and description of known packages.

Options:
  -h, --help  Show this help message and exit

Examples:
  smart search ldap
  smart search kernel module
  smart search rpm 'package manager'
  smart search pkgname
  smart search 'pkgn*e'
""")

def parse_options(argv):
    opts = query.parse_options(argv, help=HELP)
    opts.name = opts.args
    opts.summary = opts.args
    opts.description = opts.args
    for arg in argv:
        if ":/" in arg:
            opts.url.append(arg)
        elif "/" in arg:
            opts.path.append(arg)
    opts.show_summary = True
    opts.hide_version = True
    opts.args = []
    return opts

main = query.main
