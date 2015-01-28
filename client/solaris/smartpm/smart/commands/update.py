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
from smart.const import NEVER
from smart import *
import string
import time
import re

USAGE=_("smart update [options] [channelalias] ...")

DESCRIPTION=_("""
This command will update the known information about the
given channels. If no channels are given, all channels
which are not disabled or setup for manual updates will
be updated.
""")

EXAMPLES=_("""
smart update
smart update mychannel
smart update mychannel1 mychannel2
""")

def parse_options(argv):
    parser = OptionParser(usage=USAGE,
                          description=DESCRIPTION,
                          examples=EXAMPLES)
    parser.add_option("--after", metavar="MIN", type="int",
                      help=_("only update if the last successful update "
                             "happened before the given delay"))
    opts, args = parser.parse_args(argv)
    opts.args = args
    return opts

def main(ctrl, opts):

    sysconf.assertWritable()

    if opts.after is not None:
        lastupdate = sysconf.get("last-update", 0)
        if lastupdate >= time.time()-(opts.after*60):
            return 1

    ctrl.rebuildSysConfChannels()
    if opts.args:
        channels = []
        for arg in opts.args:
            for channel in ctrl.getChannels():
                if channel.getAlias() == arg:
                    channels.append(channel)
                    break
            else:
                raise Error, _("Argument '%s' is not a channel alias.") % arg
    else:
        channels = None
    # First, load current cache to keep track of new packages.
    ctrl.reloadChannels()
    failed = not ctrl.reloadChannels(channels, caching=NEVER)
    cache = ctrl.getCache()
    newpackages = pkgconf.filterByFlag("new", cache.getPackages())
    if not newpackages:
        iface.showStatus(_("Channels have no new packages."))
    else:
        if len(newpackages) <= 10:
            newpackages.sort()
            info = ":\n"
            for pkg in newpackages:
                info += "    %s\n" % pkg
        else:
            info = "."
        iface.showStatus(_("Channels have %d new packages%s")
                         % (len(newpackages), info))
    return int(failed)
