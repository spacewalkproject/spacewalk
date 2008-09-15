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
from smart.channel import *
from smart import *
import os

CHANNELSDIR = "/etc/smart/channels/"

def syncChannels(channelsdir=CHANNELSDIR, force=None):

    if force is None:
        force = sysconf.get("force-channelsync", False)

    if os.path.isdir(channelsdir):

        seenalias = {}

        for entry in os.listdir(channelsdir):
            if not entry.endswith(".channel"):
                continue

            filepath = os.path.join(channelsdir, entry)
            if not os.path.isfile(filepath):
                continue

            file = open(filepath)
            data = file.read()
            file.close()

            try:
                descriptions = parseChannelsDescription(data)
            except Error, e:
                iface.error(_("While using %s: %s") % (filepath, e))
                continue

            for alias in descriptions:

                if alias in seenalias:
                    continue
                seenalias[alias] = True

                olddescr = sysconf.get(("channelsync", alias))
                newdescr = descriptions[alias]
                chndescr = sysconf.get(("channels", alias))

                if not olddescr and chndescr:
                    olddescr = chndescr

                if chndescr:
                    name = chndescr.get("name")
                else:
                    name = None
                if not name:
                    name = newdescr.get("name")
                    if not name:
                        name = alias
                    else:
                        name += " (%s)" % alias
                else:
                    name += " (%s)" % alias

                if not olddescr:
                    if (force or
                        iface.askYesNo(_("New channel '%s' detected.\n"
                                         "Include it?") % name, True)):
                        try:
                            createChannel(alias, newdescr)
                        except Error, e:
                            iface.error(_("While using %s: %s") %
                                        (filepath, e))
                        else:
                            sysconf.set(("channels", alias), newdescr)
                            sysconf.set(("channelsync", alias), newdescr)
                    else:
                        sysconf.set(("channelsync", alias), newdescr)

                elif not chndescr:
                    continue

                elif not newdescr.get("type"):
                    iface.error(_("Channel in %s has no type.") % fielpath)

                elif newdescr.get("type") != chndescr.get("type"):
                    if (force or
                        iface.askYesNo(_("Change in channel '%s' detected.\n"
                                         "Do you want to replace it?") % name,
                                       True)):
                        try:
                            createChannel(alias, newdescr)
                        except Error, e:
                            iface.error(_("While using %s: %s") %
                                        (filepath, e))
                        else:
                            sysconf.set(("channels", alias), newdescr)
                            sysconf.set(("channelsync", alias), newdescr)
                    else:
                        sysconf.set(("channelsync", alias), newdescr)

                elif newdescr != olddescr:

                    info = getChannelInfo(chndescr["type"])
                    def getLabel(key, info=info):
                        for _key, label, ftype, default, descr in info.fields:
                            if _key == key:
                                return label
                        return key

                    def toStr(value):
                        if type(value) is bool:
                            return value and _("Yes") or _("No")
                        elif value is None:
                            return _("None")
                        return str(value)

                    try:
                        pardescr = parseChannelData(newdescr)
                    except Error, e:
                        iface.error(_("While using %s: %s") % (filepath, e))
                        continue

                    changed = False
                    for key in newdescr:
                        oldvalue = olddescr.get(key)
                        newvalue = newdescr.get(key)
                        parvalue = pardescr.get(key)
                        chnvalue = chndescr.get(key)
                        if newvalue == oldvalue or parvalue == chnvalue:
                            continue
                        if (force or
                            iface.askYesNo(_("Change in field '%(label)s' of "
                                             "channel '%(name)s' detected.\n"
                                             "Old value: %(curvalue)s\n"
                                             "New value: %(newvalue)s\n"
                                             "Replace current value?") %
                                             {"label": getLabel(key),
                                              "name": name,
                                              "curvalue": toStr(chnvalue),
                                              "newvalue": toStr(parvalue)},
                                           True)):
                            chndescr[key] = parvalue
                            changed = True

                    if changed:
                        try:
                            createChannel(alias, chndescr)
                        except Error, e:
                            iface.error(unicode(e))
                        else:
                            sysconf.set(("channels", alias), chndescr)

                    sysconf.set(("channelsync", alias), newdescr)

        if not sysconf.has("channelsync"):
            return

        for alias in sysconf.keys("channelsync"):
            if alias not in seenalias:
                sysconf.remove(("channelsync", alias))
                if not sysconf.has(("channels", alias)):
                    continue
                name = sysconf.get(("channels", alias, "name"))
                if not name:
                    name = alias
                else:
                    name += " (%s)" % alias
                if (force or
                    iface.askYesNo(_("Removing channel '%s' was suggested.\n"
                                     "Do you want to remove it?") % name,
                                   True)):
                    sysconf.remove(("channels", alias))

if not sysconf.getReadOnly():
    syncChannels()

