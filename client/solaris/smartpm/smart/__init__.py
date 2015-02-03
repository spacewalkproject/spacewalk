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
from gettext import translation
from smart.hook import Hooks
import locale
import sys
import os

__all__ = ["sysconf", "pkgconf", "iface", "hooks", "Error", "_"]

class Error(Exception):
    def __init__(self, msg=None):
        if not msg:
            Exception.__init__(self, _("Unknown error"))
        else:
            Exception.__init__(self, msg)
    def __unicode__(self):
        return self.args[0]

try:
    import __main__
    try:
        localedir = os.path.join(os.path.dirname(__main__.__file__), "locale")
    except AttributeError:
        localedir = os.path.join(os.path.dirname(os.path.dirname(__file__)),
                                 "locale")
    if not os.path.isdir(localedir):
        localedir = None
    _ = translation("smart", localedir).ugettext
except IOError, e:
    _ = lambda s: unicode(s)
else:
    import codecs
    try:
        encoding = locale.getpreferredencoding()
        sys.stdout = codecs.getwriter(encoding)(sys.stdout)
        sys.stderr = codecs.getwriter(encoding)(sys.stderr)
        del encoding
    except LookupError:
        pass

class Proxy:
    def __init__(self, object=None):
        self.object = object
    def __getattr__(self, attr):
        return getattr(self.object, attr)
    def __repr__(self):
        return "<Proxy for '%s'>" % repr(self.object)

sysconf = Proxy()
pkgconf = Proxy()
iface = Proxy()
hooks = Hooks()

def init(command=None, argv=None,
         datadir=None, configfile=None,
         gui=False, shell=False, interface=None,
         forcelocks=False, loglevel=None):
    from smart.const import DEBUG, INFO, WARNING, ERROR, DISTROFILE
    from smart.const import DATADIR, USERDATADIR
    from smart.interface import Interface, createInterface
    from smart.sysconfig import SysConfig
    from smart.pkgconfig import PkgConfig
    from smart.interface import Interface
    from smart.control import Control

    iface.object = Interface(None)
    sysconf.object = SysConfig()
    pkgconf.object = PkgConfig(sysconf.object)
    sysconf.set("log-level", INFO, weak=True)
    sysconf.set("data-dir", DATADIR, weak=True)
    if loglevel:
        level = {"error": ERROR, "warning": WARNING,
                 "debug": DEBUG, "info": INFO}.get(loglevel)
        if level is None:
            raise Error, _("Unknown log level")
        sysconf.set("log-level", level, soft=True)
    if datadir:
        sysconf.set("data-dir", os.path.expanduser(datadir), soft=True)
    sysconf.set("user-data-dir", os.path.expanduser(USERDATADIR), soft=True)
    ctrl = Control(configfile, forcelocks)
    if gui:
        ifacename = sysconf.get("default-gui", "gtk")
    elif shell:
        ifacename = sysconf.get("default-shell", "text")
        if command:
            raise Error, _("Can't use commands with shell interfaces")
    elif interface:
        ifacename = interface
    else:
        ifacename = "text"
    iface.object = createInterface(ifacename, ctrl, command, argv)

    # Run distribution script, if available.
    if os.path.isfile(DISTROFILE):
        execfile(DISTROFILE, {"ctrl": ctrl, "iface": iface,
                              "sysconf": sysconf, "pkgconf": pkgconf,
                              "hooks": hooks})

    return ctrl

def initPlugins():
    # Import every plugin, and let they do whatever they want. Backends
    # are also considered plugins for that matter.
    from smart.const import PLUGINSDIR
    from smart import plugins
    from smart import backends
    pluginsdir = os.path.dirname(plugins.__file__)
    entries = os.listdir(pluginsdir)
    if os.path.isdir(PLUGINSDIR):
        entries.extend(os.listdir(PLUGINSDIR))
    for entry in os.listdir(pluginsdir):
        if entry != "__init__.py" and entry.endswith(".py"):
            __import__("smart.plugins."+entry[:-3])
        else:
            entrypath = os.path.join(pluginsdir, entry)
            if os.path.isdir(entrypath):
                initpath = os.path.join(entrypath, "__init__.py")
                if os.path.isfile(initpath):
                    __import__("smart.plugins."+entry)
    backendsdir = os.path.dirname(backends.__file__)
    for entry in os.listdir(backendsdir):
        entrypath = os.path.join(backendsdir, entry)
        if os.path.isdir(entrypath):
            initpath = os.path.join(entrypath, "__init__.py")
            if os.path.isfile(initpath):
                __import__("smart.backends."+entry)
