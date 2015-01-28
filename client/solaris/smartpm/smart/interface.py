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
from smart.interfaces.images import __file__ as _images__file__
from smart.const import *
from smart import *
import sys, os
import termios
import struct
import fcntl

class Interface(object):

    def __init__(self, ctrl):
        self._ctrl = ctrl
        self._passwdcache = {}

    def getControl(self):
        return self._ctrl

    def run(self, command=None, argv=None):
        result = None
        if command:
            try:
                smart = __import__("smart.commands."+command)
                commands = getattr(smart, "commands")
                _command = getattr(commands, command)
            except (ImportError, AttributeError):
                if sysconf.get("log-level") == DEBUG:
                    import traceback
                    traceback.print_exc()
                raise Error, _("Invalid command '%s'") % command
            opts = _command.parse_options(argv or [])
            result = _command.main(self._ctrl, opts)
        return result

    def showStatus(self, msg):
        pass

    def hideStatus(self):
        pass

    def getProgress(self, obj, hassub=False):
        return None

    def getSubProgress(self):
        return None

    def askYesNo(self, question, default=False):
        return True

    def askContCancel(self, question, default=False):
        return True

    def askOkCancel(self, question, default=False):
        return True

    def askInput(self, prompt, message=None, widthchars=None, echo=True):
        return ""

    def askPassword(self, location, caching=OPTIONAL):
        passwd = None
        if caching is not NEVER and location in self._passwdcache:
            passwd = self._passwdcache[location]
        elif caching is not ALWAYS:
            passwd = self.askInput(_("Password"),
                                   _("A password is needed for '%s'.")
                                   % location, echo=False, widthchars=16)
            self._passwdcache[location] = passwd
        return passwd

    def setPassword(self, location, passwd):
        if passwd is None:
            if location in self._passwdcache:
                del self._passwdcache[location]
        else:
            self._passwdcache[location] = passwd

    def confirmChangeSet(self, changeset):
        return True

    def confirmChange(self, oldchangeset, newchangeset):
        return True

    def insertRemovableChannels(self, channels):
        raise Error, "insertRemovableChannels() not implemented"

    def error(self, msg):
        if sysconf.get("log-level", INFO) >= ERROR:
            self.message(ERROR, msg)

    def warning(self, msg):
        if sysconf.get("log-level", INFO) >= WARNING:
            self.message(WARNING, msg)

    def info(self, msg):
        if sysconf.get("log-level", INFO) >= INFO:
            self.message(INFO, msg)

    def debug(self, msg):
        if sysconf.get("log-level", INFO) >= DEBUG:
            self.message(DEBUG, msg)

    def message(self, level, msg):
        prefix = {ERROR: _("error"), WARNING: _("warning"),
                  DEBUG: _("debug")}.get(level)
        if sys.stderr.isatty():
            sys.stderr.write(" "*(getScreenWidth()-1)+"\r")
        if prefix:
            for line in msg.split("\n"):
                sys.stderr.write("%s: %s\n" % (prefix, line))
        else:
            sys.stderr.write("%s\n" % msg.rstrip())

def getScreenWidth():
    s = struct.pack('HHHH', 0, 0, 0, 0)
    try:
        x = fcntl.ioctl(1, termios.TIOCGWINSZ, s)
    except IOError:
        return 80
    return struct.unpack('HHHH', x)[1]

def createInterface(name, ctrl, command=None, argv=None):
    try:
        xname = name.replace('-', '_').lower()
        smart = __import__("smart.interfaces."+xname)
        interfaces = getattr(smart, "interfaces")
        interface = getattr(interfaces, xname)
    except (ImportError, AttributeError):
        if sysconf.get("log-level") == DEBUG:
            import traceback
            traceback.print_exc()
        raise Error, _("Interface '%s' not available") % name
    return interface.create(ctrl, command, argv)

def getImagePath(name, _dirname=os.path.dirname(_images__file__)):
    return os.path.join(_dirname, name+".png")
