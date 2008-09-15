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

name = _("URPMI Repository")

description = _("""
Repository created for Mandrake's URPMI package manager.
""")

fields = [("baseurl", _("Base URL"), str, None,
           _("Base URL where packages are found under.")),
          ("hdlurl", _("Header List URL"), str, "",
           _("URL for header list (hdlist or synthesis). If it's hdlist.cz "
             "inside the given base URL, may be left empty."))]
