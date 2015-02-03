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
from smart.transaction import ChangeSet, ChangeSetSplitter, INSTALL, REMOVE
from smart.util.filetools import compareFiles, setCloseOnExecAll
from smart.util.objdigest import getObjectDigest
from smart.util.pathlocks import PathLocks
from smart.util.strtools import strToBool
from smart.searcher import Searcher
from smart.media import MediaSet
from smart.progress import Progress
from smart.fetcher import Fetcher
from smart.channel import *
from smart.cache import *
from smart.const import *
from smart import *
import cPickle
import sys, os
import copy
import time
import md5

class Control(object):

    def __init__(self, confpath=None, forcelocks=False):
        self._confpath = None
        self._channels = {} # alias -> Channel()
        self._sysconfchannels = {} # alias -> data dict
        self._dynamicchannels = {} # alias -> Channel()
        self._pathlocks = PathLocks(forcelocks)
        self._cache = Cache()

        self.loadSysConf(confpath)

        self._fetcher = Fetcher()
        self._mediaset = self._fetcher.getMediaSet()
        self._achanset = AvailableChannelSet(self._fetcher)
        self._cachechanged = False

    def getChannels(self):
        return self._channels.values()

    def removeChannel(self, alias):
        channel = self._channels[alias]
        if isinstance(channel, PackageChannel):
            channel.removeLoaders()
        del self._channels[alias]
        if alias in self._sysconfchannels:
            del self._sysconfchannels[alias]
        if alias in self._dynamicchannels:
            del self._dynamicchannels[alias]

    def getFileChannels(self):
        return [x for x in self._channels.values()
                if isinstance(x, FileChannel)]

    def addFileChannel(self, filename):
        if not self._sysconfchannels:
            # Give a chance for backends to register
            # themselves on FileChannel hooks.
            self.rebuildSysConfChannels()
        found = False
        for channel in hooks.call("create-file-channel", filename):
            if channel:
                if channel.getAlias() in self._channels:
                    raise Error, _("There's another channel with alias '%s'") \
                                 % channel.getAlias()
                self._channels[channel.getAlias()] = channel
                found = True
        if not found:
            raise Error, _("Unable to create channel for file: %s") % filename

    def removeFileChannel(self, filename):
        filename = os.path.abspath(filename)
        for channel in self._channels.values():
            if (isinstance(channel, FileChannel) and
                channel.getFileName() == filename):
                channel.removeLoaders()
                break
        else:
            raise Error, _("Channel not found for '%s'") % filename

    def askForRemovableChannels(self, channels):
        removable = [(str(x), x) for x in channels if x.isRemovable()]
        if not removable:
            return True
        removable.sort()
        removable = [x for name, x in removable]
        self._mediaset.umountAll()
        if not iface.insertRemovableChannels(removable):
            return False
        self._mediaset.mountAll()
        return True

    def getCache(self):
        return self._cache

    def getFetcher(self):
        return self._fetcher

    def getMediaSet(self):
        return self._mediaset

    def restoreMediaState(self):
        self._mediaset.restoreState()

    __stateversion__ = 2

    def loadSysConf(self, confpath=None):
        loaded = False
        datadir = sysconf.get("data-dir")
        if confpath:
            confpath = os.path.expanduser(confpath)
            if not os.path.isfile(confpath):
                raise Error, _("Configuration file not found: %s") % confpath
            sysconf.load(confpath)
            loaded = True
        else:
            confpath = os.path.join(datadir, CONFFILE)
            if os.path.isfile(confpath):
                sysconf.load(confpath)
                loaded = True
        self._confpath = confpath

        if os.path.isdir(datadir):
            writable = os.access(datadir, os.W_OK)
        else:
            try:
                os.makedirs(datadir)
                writable = True
            except OSError:
                raise Error, _("No configuration found!")

        if writable and not self._pathlocks.lock(datadir, exclusive=True):
            writable = False

        sysconf.setReadOnly(not writable)

    def saveSysConf(self, confpath=None):
        msys = self._fetcher.getMirrorSystem()
        if msys.getHistoryChanged() and not sysconf.getReadOnly():
            sysconf.set("mirrors-history", msys.getHistory())
        if confpath:
            confpath = os.path.expanduser(confpath)
        else:
            if sysconf.getReadOnly():
                return

            if self._cachechanged:
                iface.showStatus(_("Saving cache..."))
                cachepath = os.path.join(sysconf.get("data-dir"), "cache")
                cachefile = open(cachepath+".new", "w")
                state = (self.__stateversion__,
                         self._cache,
                         self._channels,
                         self._sysconfchannels)
                cPickle.dump(state, cachefile, 2)
                cachefile.close()
                os.rename(cachepath+".new", cachepath)
                iface.hideStatus()

            if not sysconf.getModified():
                return

            sysconf.resetModified()
            confpath = self._confpath

        sysconf.save(confpath)

    def reloadMirrors(self):
        mirrors = sysconf.get("mirrors", {})
        for channel in self._channels.values():
            if isinstance(channel, MirrorsChannel):
                cmirrors = channel.getMirrors()
                if cmirrors:
                    for origin in cmirrors:
                        set = dict.fromkeys(cmirrors[origin])
                        set.update(dict.fromkeys(mirrors.get(origin, [])))
                        mirrors[origin] = set.keys()
        msys = self._fetcher.getMirrorSystem()
        msys.setMirrors(mirrors)
        if not msys.getHistory():
            msys.setHistory(sysconf.get("mirrors-history", []))

    def rebuildSysConfChannels(self):

        channels = sysconf.get("channels", ())

        forcechannels = sysconf.get("force-channels", "")
        if forcechannels:
            forcechannels = forcechannels.split(",")

        def isEnabled(alias, data):
            if forcechannels:
                return alias in forcechannels
            return not data.get("disabled")

        if channels and not self._channels:
            cachepath = os.path.join(sysconf.get("data-dir"), "cache")
            if os.path.isfile(cachepath):
                iface.showStatus(_("Loading cache..."))
                cachefile = open(cachepath)
                try:
                    state = cPickle.load(cachefile)
                    if state[0] != self.__stateversion__:
                        raise StateVersionError
                except:
                    if sysconf.get("log-level") == DEBUG:
                        import traceback
                        traceback.print_exc()
                    if os.access(os.path.dirname(cachepath), os.W_OK):
                        os.unlink(cachepath)
                else:
                    (__stateversion__,
                     self._cache,
                     self._channels,
                     self._sysconfchannels) = state
                    for alias in self._channels.keys():
                        if (alias not in channels or
                            not isEnabled(alias, channels[alias])):
                            self.removeChannel(alias)
                cachefile.close()
                iface.hideStatus()

        for alias in channels:
            data = channels[alias]
            if not isEnabled(alias, data):
                continue

            if alias in self._sysconfchannels.keys():
                if self._sysconfchannels[alias] == data:
                    continue
                else:
                    channel = self._channels[alias]
                    if isinstance(channel, PackageChannel):
                        channel.removeLoaders()
                    del self._channels[alias]
                    del self._sysconfchannels[alias]

            channel = createChannel(alias, data)
            self._sysconfchannels[alias] = data
            self._channels[alias] = channel

        for alias in self._sysconfchannels.keys():
            if alias not in channels or channels[alias].get("disabled"):
                self.removeChannel(alias)

    def rebuildDynamicChannels(self):
        for alias in self._dynamicchannels.keys():
            self.removeChannel(alias)
        newchannels = {}
        for channels in hooks.call("rebuild-dynamic-channels"):
            if channels:
                for channel in channels:
                    alias = channel.getAlias()
                    if alias in self._channels:
                        raise Error, _("There's another channel with "
                                       "alias '%s'") % alias
                    newchannels[alias] = channel
        self._channels.update(newchannels)
        self._dynamicchannels.update(newchannels)

    def reloadChannels(self, channels=None, caching=ALWAYS):

        if channels is None:
            manual = False
            self.rebuildSysConfChannels()
            self.rebuildDynamicChannels()
            channels = self._channels.values()
            hooks.call("reload-channels", channels)
        else:
            manual = True

        # Get channels directory and check the necessary locks.
        channelsdir = os.path.join(sysconf.get("data-dir"), "channels/")
        userchannelsdir = os.path.join(sysconf.get("user-data-dir"),
                                       "channels/")
        if not os.path.isdir(channelsdir):
            try:
                os.makedirs(channelsdir)
            except OSError:
                raise Error, _("Unable to create channel directory.")
        if caching is ALWAYS:
            if sysconf.getReadOnly() and os.access(channelsdir, os.W_OK):
                iface.warning(_("Configuration is in readonly mode!"))
            if not self._pathlocks.lock(channelsdir):
                raise Error, _("Channel information is locked for writing.")
        elif sysconf.getReadOnly():
            raise Error, _("Can't update channels in readonly mode.")
        elif not self._pathlocks.lock(channelsdir, exclusive=True):
            raise Error, _("Can't update channels with active readers.")
        self._fetcher.setLocalDir(channelsdir, mangle=True)

        # Prepare progress. If we're reading from the cache, we don't want
        # too much information being shown. Otherwise, ask for a full-blown
        # progress for the interface, and build information of currently
        # available packages to compare later.
        if caching is ALWAYS:
            progress = Progress()
        else:
            progress = iface.getProgress(self._fetcher, True)
            oldpkgs = {}
            for pkg in self._cache.getPackages():
                oldpkgs[(pkg.name, pkg.version)] = True
        progress.start()
        steps = 0
        for channel in channels:
            steps += channel.getFetchSteps()
        progress.set(0, steps)

        # Rebuild mirror information.
        self.reloadMirrors()

        self._fetcher.setForceMountedCopy(True)

        self._cache.reset()

        # Do the real work.
        result = True
        for channel in channels:
            digest = channel.getDigest()
            if not manual and channel.hasManualUpdate():
                self._fetcher.setCaching(ALWAYS)
            else:
                self._fetcher.setCaching(caching)
                if channel.getFetchSteps() > 0:
                    progress.setTopic(_("Fetching information for '%s'...") %
                                  (channel.getName() or channel.getAlias()))
                    progress.show()
            self._fetcher.setForceCopy(channel.isRemovable())
            self._fetcher.setLocalPathPrefix(channel.getAlias()+"%%")
            try:
                if not channel.fetch(self._fetcher, progress):
                    iface.debug(_("Failed fetching channel '%s'") % channel)
                    result = False
            except Error, e:
                iface.error(unicode(e))
                iface.debug(_("Failed fetching channel '%s'") % channel)
                result = False
            if (channel.getDigest() != digest and
                isinstance(channel, PackageChannel)):
                channel.addLoaders(self._cache)
                if channel.getAlias() in self._sysconfchannels:
                    self._cachechanged = True
        if result and caching is not ALWAYS:
            sysconf.set("last-update", time.time())
        self._fetcher.setForceMountedCopy(False)
        self._fetcher.setForceCopy(False)
        self._fetcher.setLocalPathPrefix(None)

        # Finish progress.
        progress.setStopped()
        progress.show()
        progress.stop()

        # Build cache with the new information.
        self._cache.load()

        # Compare new packages with what we had available, and mark
        # new packages.
        if caching is not ALWAYS:
            pkgconf.clearFlag("new")
            for pkg in self._cache.getPackages():
                if (pkg.name, pkg.version) not in oldpkgs:
                    pkgconf.setFlag("new", pkg.name, "=", pkg.version)

        # Remove unused files from channels directory.
        for dir in (channelsdir, userchannelsdir):
            if os.access(dir, os.W_OK):
                aliases = self._channels.copy()
                aliases.update(dict.fromkeys(sysconf.get("channels", ())))
                for entry in os.listdir(dir):
                    sep = entry.find("%%")
                    if sep == -1 or entry[:sep] not in aliases:
                        os.unlink(os.path.join(dir, entry))

        # Change back to a shared lock.
        self._pathlocks.lock(channelsdir)
        return result

    def dumpTransactionURLs(self, trans, output=None):
        changeset = trans.getChangeSet()
        self.dumpURLs([x for x in changeset if changeset[x] is INSTALL])

    def dumpURLs(self, packages, output=None):
        if output is None:
            output = sys.stderr
        urls = []
        for pkg in packages:
            loaders = [x for x in pkg.loaders if not x.getInstalled()]
            if not loaders:
                raise Error, _("Package %s is not available for downloading") \
                             % pkg
            info = loaders[0].getInfo(pkg)
            urls.extend(info.getURLs())
        for url in urls:
            print >>output, url

    def downloadURLs(self, urllst, what=None, caching=NEVER, targetdir=None):
        fetcher = self._fetcher
        fetcher.reset()
        self.reloadMirrors()
        if targetdir is None:
            localdir = os.path.join(sysconf.get("data-dir"), "tmp/")
            if not os.path.isdir(localdir):
                os.makedirs(localdir)
            fetcher.setLocalDir(localdir, mangle=True)
        else:
            fetcher.setLocalDir(targetdir, mangle=False)
        fetcher.setCaching(caching)
        for url in urllst:
            fetcher.enqueue(url)
        fetcher.run(what=what)
        return fetcher.getSucceededSet(), fetcher.getFailedSet()

    def downloadTransaction(self, trans, caching=OPTIONAL, confirm=True):
        return self.downloadChangeSet(trans.getChangeSet(), caching,
                                      confirm=confirm)

    def downloadChangeSet(self, changeset, caching=OPTIONAL, targetdir=None,
                          confirm=True):
        if confirm and not iface.confirmChangeSet(changeset):
            return False
        return self.downloadPackages([x for x in changeset
                                      if changeset[x] is INSTALL],
                                     caching, targetdir)

    def downloadPackages(self, packages, caching=OPTIONAL, targetdir=None):
        channels = getChannelsWithPackages(packages)
        fetched = 0
        while True:
            if not self.askForRemovableChannels(channels):
                return False
            self._achanset.setChannels(channels)
            fetchpkgs = []
            for channel in channels:
                if self._achanset.isAvailable(channel):
                    fetchpkgs.extend(channels[channel])
            self.fetchPackages(fetchpkgs, caching, targetdir)
            fetched += len(fetchpkgs)
            if fetched == len(packages):
                break
        return True

    def commitTransaction(self, trans, caching=OPTIONAL, confirm=True):
        return self.commitChangeSet(trans.getChangeSet(), caching, confirm)

    def commitChangeSet(self, changeset, caching=OPTIONAL, confirm=True):
        if confirm and not iface.confirmChangeSet(changeset):
            return False

        setCloseOnExecAll()

        pmpkgs = {}
        for pkg in changeset:
            pmclass = pkg.packagemanager
            if pmclass not in pmpkgs:
                pmpkgs[pmclass] = [pkg]
            else:
                pmpkgs[pmclass].append(pkg)

        channels = getChannelsWithPackages([x for x in changeset
                                            if changeset[x] is INSTALL])
        datadir = sysconf.get("data-dir")
        splitter = ChangeSetSplitter(changeset)
        donecs = ChangeSet(self._cache)
        copypkgpaths = {}
        while True:
            if not self.askForRemovableChannels(channels):
                return False
            self._achanset.setChannels(channels)
            splitter.resetLocked()
            splitter.setLockedSet(dict.fromkeys(donecs, True))
            cs = changeset.copy()
            for channel in channels:
                if not self._achanset.isAvailable(channel):
                    for pkg in channels[channel]:
                        if pkg not in donecs and pkg not in copypkgpaths:
                            splitter.exclude(cs, pkg)
            cs = cs.difference(donecs)
            donecs.update(cs)

            if cs:

                pkgpaths = self.fetchPackages([pkg for pkg in cs
                                               if pkg not in copypkgpaths
                                                  and cs[pkg] is INSTALL],
                                              caching)
                for pkg in cs:
                    if pkg in copypkgpaths:
                        pkgpaths[pkg] = copypkgpaths[pkg]
                        del copypkgpaths[pkg]

                for pmclass in pmpkgs:
                    pmcs = ChangeSet(self._cache)
                    for pkg in pmpkgs[pmclass]:
                        if pkg in cs:
                            pmcs[pkg] = cs[pkg]
                    if sysconf.get("commit", True):
                        pmclass().commit(pmcs, pkgpaths)

                if sysconf.get("remove-packages", True):
                    for pkg in pkgpaths:
                        for path in pkgpaths[pkg]:
                            if path.startswith(os.path.join(datadir,
                                                            "packages")):
                                os.unlink(path)

            if donecs == changeset:
                break

            copypkgs = []
            for channel in channels.keys():
                if self._achanset.isAvailable(channel):
                    pkgs = [pkg for pkg in channels[channel] if pkg not in cs]
                    if not pkgs:
                        del channels[channel]
                    elif channel.isRemovable():
                        copypkgs.extend(pkgs)
                        del channels[channel]
                    else:
                        channels[channel] = pkgs

            self._fetcher.setForceCopy(True)
            copypkgpaths.update(self.fetchPackages(copypkgs, caching))
            self._fetcher.setForceCopy(False)

        self._mediaset.restoreState()

        return True

    def commitTransactionStepped(self, trans, caching=OPTIONAL, confirm=True):
        return self.commitChangeSetStepped(trans.getChangeSet(),
                                           caching, confirm)

    def commitChangeSetStepped(self, changeset, caching=OPTIONAL,
                               confirm=True):
        if confirm and not iface.confirmChangeSet(changeset):
            return False

        # Order by number of required packages inside the transaction.
        pkglst = []
        for pkg in changeset:
            n = 0
            for req in pkg.requires:
                for prv in req.providedby:
                    for prvpkg in prv.packages:
                        if changeset.get(prvpkg) is INSTALL:
                            n += 1
            pkglst.append((n, pkg))

        pkglst.sort()

        splitter = ChangeSetSplitter(changeset)
        unioncs = ChangeSet(self._cache)
        for n, pkg in pkglst:
            if pkg in unioncs:
                continue
            cs = ChangeSet(self._cache, unioncs)
            splitter.include(unioncs, pkg)
            cs = unioncs.difference(cs)
            self.commitChangeSet(cs)

        return True

    def fetchPackages(self, packages, caching=OPTIONAL, targetdir=None):
        fetcher = self._fetcher
        fetcher.reset()
        fetcher.setCaching(caching)
        self.reloadMirrors()
        if targetdir is None:
            localdir = os.path.join(sysconf.get("data-dir"), "packages/")
            if not os.path.isdir(localdir):
                os.makedirs(localdir)
            fetcher.setLocalDir(localdir, mangle=False)
        else:
            fetcher.setLocalDir(targetdir, mangle=False)
        pkgitems = {}
        for pkg in packages:
            for loader in pkg.loaders:
                if loader.getInstalled():
                    continue
                channel = loader.getChannel()
                if self._achanset.isAvailable(channel):
                    break
            else:
                raise Error, _("No channel available for package %s") % pkg
            info = loader.getInfo(pkg)
            urls = info.getURLs()
            pkgitems[pkg] = []
            for url in urls:
                media = self._achanset.getMedia(channel)
                pkgitems[pkg].append(fetcher.enqueue(url, media=media,
                                                     md5=info.getMD5(url),
                                                     sha=info.getSHA(url),
                                                     size=info.getSize(url),
                                                     validate=info.validate))
        if targetdir:
            fetcher.setForceCopy(True)
        fetcher.run(what=_("packages"))
        fetcher.setForceCopy(False)
        failed = fetcher.getFailedSet()
        if failed:
            raise Error, _("Failed to download packages:\n") + \
                         "\n".join([u"    %s: %s" % (url, failed[url])
                                    for url in failed])
        pkgpaths = {}
        for pkg in packages:
            pkgpaths[pkg] = [item.getTargetPath() for item in pkgitems[pkg]]
        return pkgpaths

    def search(self, s, cutoff=1.00, suggestioncutoff=0.70,
               globcutoff=1.00, globsuggestioncutoff=0.95,
               addprovides=True):
        ratio = 0
        results = []
        suggestions = []

        objects = []

        # If we find packages with exactly the given
        # name or name-version, use them.
        for pkg in self._cache.getPackages(s):
            if pkg.name == s or "%s-%s" % (pkg.name, pkg.version) == s:
                objects.append((1.0, pkg))

        if not objects:
            if "*" in s:
                cutoff = globcutoff
                suggestioncutoff = globsuggestioncutoff
            searcher = Searcher()
            searcher.addAuto(s, suggestioncutoff)
            if addprovides:
                searcher.addProvides(s, suggestioncutoff)
            self._cache.search(searcher)
            objects = searcher.getResults()

        if objects:
            bestratio = objects[0][0]
            if bestratio < cutoff:
                suggestions = objects
            else:
                for i in range(len(objects)):
                    ratio, obj = objects[i]
                    if ratio == bestratio:
                        results.append(obj)
                    else:
                        suggestions = objects[i:]
                        break
                if results:
                    ratio = bestratio
        return ratio, results, suggestions

class AvailableChannelSet(object):

    def __init__(self, fetcher, channels=None, progress=None):
        self._channels = channels or []
        self._fetcher = fetcher
        self._progress = progress or Progress()
        self._available = {}
        self._media = {}
        if self._channels:
            self.compute()

    def setChannels(self, channels):
        self._channels = channels
        self.compute()

    def isAvailable(self, channel):
        return channel in self._available

    def getMedia(self, channel):
        return self._media.get(channel)

    def compute(self):

        self._available.clear()
        self._media.clear()

        fetcher = self._fetcher
        progress = self._progress
        mediaset = fetcher.getMediaSet()

        steps = 0
        for channel in self._channels:
            steps += len(channel.getCacheCompareURLs())

        progress.start()
        progress.set(0, steps*2)

        for channel in self._channels:

            if not channel.isRemovable():
                self._available[channel] = True
                progress.add(2)
                continue

            urls = channel.getCacheCompareURLs()
            if not urls:
                self._available[channel] = False
                progress.add(2)
                continue

            datadir = sysconf.get("data-dir")
            tmpdir = os.path.join(datadir, "tmp/")
            if not os.path.isdir(tmpdir):
                os.makedirs(tmpdir)
            channelsdir = os.path.join(datadir, "channels/")
            if not os.path.isdir(channelsdir):
                self._available[channel] = False
                progress.add(2)
                continue

            media = None
            available = False
            for url in urls:

                # Fetch cached item.
                fetcher.reset()
                fetcher.setLocalDir(channelsdir, mangle=True)
                fetcher.setCaching(ALWAYS)
                fetcher.setForceCopy(True)
                fetcher.setLocalPathPrefix(channel.getAlias()+"%%")
                channelsitem = fetcher.enqueue(url)
                fetcher.run("channels", progress=progress)
                fetcher.setForceCopy(False)
                fetcher.setLocalPathPrefix(None)
                if channelsitem.getStatus() is FAILED:
                    progress.add(1)
                    break

                if url.startswith("localmedia:/"):
                    progress.add(1)
                    channelspath = channelsitem.getTargetPath()
                    media = mediaset.findFile(url, comparepath=channelspath)
                    if not media:
                        break
                else:
                    # Fetch temporary item.
                    fetcher.reset()
                    fetcher.setLocalDir(tmpdir, mangle=True)
                    fetcher.setCaching(NEVER)
                    tmpitem = fetcher.enqueue(url)
                    fetcher.run("tmp", progress=progress)
                    if tmpitem.getStatus() is FAILED:
                        break

                    # Compare items.
                    channelspath = channelsitem.getTargetPath()
                    tmppath = tmpitem.getTargetPath()

                    if not compareFiles(channelspath, tmppath):
                        if tmppath.startswith(datadir):
                            os.unlink(tmppath)
                        break
            else:
                self._available[channel] = True
                if media:
                    self._media[channel] = media

        progress.stop()

class ChannelSorter(object):
    def __init__(self, channel):
        self.channel = channel
    def __cmp__(self, other):
        rc = -cmp(isinstance(self.channel, FileChannel),
                  isinstance(other.channel, FileChannel))
        if rc == 0:
            rc = cmp(self.channel.isRemovable(), other.channel.isRemovable())
            if rc and sysconf.get("prefer-removable"):
                rc *= -1
        return rc

def getChannelsWithPackages(packages):
    channels = {}
    for pkg in packages:
        sorters = [ChannelSorter(x.getChannel()) for x in pkg.loaders
                   if not x.getInstalled()]
        if not sorters:
            raise Error, _("%s is not available for downloading") % pkg
        sorters.sort()
        channel = sorters[0].channel
        try:
            channels[channel].append(pkg)
        except KeyError:
            channels[channel] = [pkg]
    return channels
