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
from smart import *

if sysconf.has("deb-dir"):

    from smart.channels.deb_dir import DebDirChannel

    def createDebDirChannel():
        channel = DebDirChannel(sysconf.get("deb-dir"),
                                "deb-dir",
                                "deb-dir-option",
                                _("Dynamic DEB Directory"),
                                True, False, 0) 
        return [channel]
    
    hooks.register("rebuild-dynamic-channels", createDebDirChannel)

