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
import os

class Channel(object):
    def __init__(self, type, alias, name=None,
                 manualupdate=False, removable=False):
        self._type = type
        self._alias = alias
        self._name = name
        self._manualupdate = manualupdate
        self._removable = removable
        self._digest = object()

    def getType(self):
        return self._type

    def getAlias(self):
        return self._alias

    def getName(self):
        return self._name

    def hasManualUpdate(self):
        return self._removable or self._manualupdate

    def isRemovable(self):
        return self._removable

    def getFetchSteps(self):
        return 0

    def getDigest(self):
        """
        Having the same channel digest means that information in
        the channel haven't changed at all, thus reprocessing
        information contained in it is optional.
        """
        return self._digest

    def getCacheCompareURLs(self):
        """
        URLs returned by this method are used to check if a
        repository is currently available by comparing fetched
        information with cached information.
        """
        return []

    def fetch(self, fetcher, progress):
        """
        Fetch metafiles and set loader. This method implements a
        scheme that allows one to use a single logic to fetch remote
        files and also to load local cached information, depending
        on the caching mode of the fetcher.
        """
        return True

    def __str__(self):
        return self._name or self._alias


class PackageChannel(Channel):
    def __init__(self, type, alias, name=None,
                 manualupdate=False, removable=False, priority=0):
        super(PackageChannel, self).__init__(type, alias, name,
                                             manualupdate, removable)
        self._loaders = []
        self._priority = priority

    def getLoaders(self):
        return self._loaders

    def addLoaders(self, cache):
        for loader in self._loaders:
            cache.addLoader(loader)

    def removeLoaders(self):
        for loader in self._loaders:
            cache = loader.getCache()
            cache.removeLoader(loader)
        del self._loaders[:]
        self._digest = object()

    def getPriority(self):
        return self._priority

class FileChannel(PackageChannel):
    def __init__(self, filename, name=None, priority=0):
        self._filename = filename = os.path.abspath(filename)
        if name is None:
            name = os.path.basename(filename)
        if not os.path.isfile(filename):
            raise Error, _("File not found: %s") % filename
        super(FileChannel, self).__init__("file", filename, name,
                                          manualupdate=True, priority=priority)

    def getFileName(self):
        return self._filename

class MirrorsChannel(Channel):
    def __init__(self, type, alias, name=None,
                 manualupdate=False, removable=False):
        super(MirrorsChannel, self).__init__(type, alias, name,
                                             manualupdate, removable)
        self._mirrors = {}

    def getMirrors(self):
        return self._mirrors

# (key, label, needed, type, description)
DEFAULTFIELDS = [("alias", _("Alias"), str, None,
                  _("Unique identification for the channel.")),
                 ("type", _("Type"), str, None,
                  _("Channel type")),
                 ("name", _("Name"), str, "",
                  _("Channel name")),
                 ("manual", _("Manual updates"), bool, False,
                  _("If set to a true value, the given channel "
                    "will only be updated when manually selected.")),
                 ("disabled", _("Disabled"), bool, False,
                  _("If set to a true value, the given channel "
                    "won't be used.")),
                 ("removable", _("Removable"), bool, False,
                  _("If set to a true value, the given channel will "
                    "be considered as being available in a removable "
                    "media (cdrom, etc)."))]

KINDFIELDS = {"package":
              [("priority", _("Priority"), int, 0,
                _("Default priority assigned to all packages "
                  "available in this channel (0 if not set). If "
                  "the exact same package is available in more "
                  "than one channel, the highest priority is used."))]}

def createChannel(alias, data):
    data = parseChannelData(data)
    type = data.get("type", "").replace('-', '_').lower()
    try:
        smart = __import__("smart.channels."+type)
        channels = getattr(smart, "channels")
        channel = getattr(channels, type)
    except (ImportError, AttributeError):
        from smart.const import DEBUG
        if sysconf.get("log-level") == DEBUG:
            import traceback
            traceback.print_exc()
        raise Error, _("Unable to create channel of type '%s'") % type
    data = data.copy()
    info = getChannelInfo(data.get("type"))
    for key, label, ftype, default, descr in info.fields:
        if key == "alias":
            continue
        if key not in data:
            data[key] = default
    return channel.create(alias, data)

def createChannelDescription(alias, data):
    ctype = data.get("type")
    if not ctype:
        raise Error, _("Channel has no type")
    info = getChannelInfo(ctype)
    if not info:
        raise Error, _("Unknown channel type: %s") % ctype
    lines = ["[%s]" % alias]
    for key, label, ftype, default, descr in info.fields:
        if key == "alias":
            continue
        value = data.get(key)
        if type(value) is str:
            value = value.strip()
        if not value or value == default:
            if default is None:
                raise Error, _("%s (%s) is a needed field for '%s' channels") \
                             % (label, key, ctype)
            continue
        if type(value) is bool:
            value = value and "yes" or "no"
        elif type(value) is not str:
            value = str(value)
        lines.append("%s = %s" % (key, value))
    return "\n".join(lines)

def parseChannelData(data):
    ctype = data.get("type")
    if not ctype:
        raise Error, _("Channel has no type")
    info = getChannelInfo(ctype)
    if not info:
        raise Error, _("Unknown channel type: %s") % ctype
    newdata = {}
    for key, label, ftype, default, descr in info.fields:
        if key == "alias":
            continue
        value = data.get(key)
        if type(value) is str:
            value = value.strip()
        if not value or value == default:
            if default is None:
                raise Error, _("%s (%s) is a needed field for '%s' channels") \
                             % (label, key, ctype)
            continue
        if type(value) is str:
            if ftype is bool:
                value = value.lower()
                if value in ("y", "yes", "true", "1",
                             _("y"), _("yes"), _("true")):
                    value = True
                elif value in ("n", "no", "false", "0",
                               _("n"), _("no"), _("false")):
                    value = False
                else:
                    raise Error, _("Invalid value for '%s' (%s) field: %s") % \
                                 (label, key, `value`)
            elif ftype is not str:
                try:
                    value = ftype(value)
                except ValueError:
                    raise Error, _("Invalid value for '%s' (%s) field: %s") % \
                                 (label, key, `value`)
        elif type(value) is not ftype:
            raise Error, _("Invalid value for '%s' (%s) field: %s") % \
                         (label, key, `value`)
        newdata[key] = value
    return newdata

def parseChannelsDescription(data):
    channels = {}
    current = None
    alias = None
    for line in data.splitlines():
        line = line.strip()
        if not line:
            continue
        if len(line) > 2 and line[0] == "[" and line[-1] == "]":
            if current and "type" not in current:
                raise Error, _("Channel '%s' has no type") % alias
            alias = line[1:-1].strip()
            current = {}
            channels[alias] = current
        elif current is not None and not line[0] == "#" and "=" in line:
            key, value = line.split("=")
            current[key.strip().lower()] = value.strip()
    for alias in channels:
        channels[alias] = parseChannelData(channels[alias])
    return channels

def getChannelInfo(type):
    try:
        infoname = type.replace('-', '_').lower()+"_info"
        smart = __import__("smart.channels."+infoname)
        channels = getattr(smart, "channels")
        info = getattr(channels, infoname)
    except (ImportError, AttributeError):
        from smart.const import DEBUG
        if sysconf.get("log-level") == DEBUG:
            import traceback
            traceback.print_exc()
        raise Error, _("Invalid channel type '%s'") % type
    if not hasattr(info, "_fixed"):
        info._fixed = True
        fields = []
        fields.extend(DEFAULTFIELDS)
        fields.extend(KINDFIELDS.get(info.kind, []))
        if hasattr(info, "fields"):
            fields.extend(info.fields)
        info.fields = fields
    return info

def getAllChannelInfos():
    from smart import channels
    filenames = os.listdir(os.path.dirname(channels.__file__))
    infos = {}
    for filename in filenames:
        if filename.endswith("_info.py"):
            type = filename[:-8].replace("_", "-")
            infos[type] = getChannelInfo(type)
    return infos

def detectLocalChannels(path):
    from smart.media import MediaSet
    mediaset = MediaSet()
    infos = getAllChannelInfos()
    channels = []
    maxdepth = sysconf.get("detectlocalchannels-maxdepth", 5)
    roots = [(path, 0)]
    while roots:
        root, depth = roots.pop(0)
        media = mediaset.findMountPoint(root, subpath=True)
        if media:
            media.mount()
        if not os.path.isdir(root):
            continue
        channelsfile = os.path.join(root, ".channels")
        if os.path.isfile(channelsfile):
            file = open(channelsfile)
            descriptions = parseChannelsDescription(file.read())
            file.close()
            for alias in descriptions:
                channel = descriptions[alias]
                channel["alias"] = alias
                channels.append(channel)
            continue
        for type in infos:
            info = infos[type]
            if hasattr(info, "detectLocalChannels"):
                for channel in info.detectLocalChannels(root, media):
                    channel["type"] = type
                    if media and media.isRemovable():
                        channel["removable"] = True
                    channels.append(channel)
        if depth < maxdepth:
            for entry in os.listdir(root):
                entrypath = os.path.join(root, entry)
                if os.path.isdir(entrypath):
                    roots.append((entrypath, depth+1))
    return channels
