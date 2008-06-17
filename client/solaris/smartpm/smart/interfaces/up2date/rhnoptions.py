#
# Copyright (c) 2004 Conectiva, Inc.
# Copyright (c) 2005 Red Hat, Inc.
#
# From code written by Gustavo Niemeyer <niemeyer@conectiva.com>
# Modified by Peter Vetere <pvetere@redhat.com>
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

__rhn_options = {}

def hasOption(option):
    return __rhn_options.has_key(option)

def getOption(option):
    return __rhn_options[option]

def setOption(option, value):
    __rhn_options[option] = value

