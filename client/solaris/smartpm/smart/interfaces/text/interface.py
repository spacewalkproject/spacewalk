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
from smart.interfaces.text.progress import TextProgress
from smart.interface import Interface, getScreenWidth
from smart.util.strtools import sizeToStr, printColumns
from smart.const import OPTIONAL, ALWAYS
from smart.fetcher import Fetcher
from smart.report import Report
from smart import *
import getpass
import sys
import os

class TextInterface(Interface):

    def __init__(self, ctrl):
        Interface.__init__(self, ctrl)
        self._progress = TextProgress()
        self._activestatus = False

    def getProgress(self, obj, hassub=False):
        self._progress.setHasSub(hassub)
        self._progress.setFetcherMode(isinstance(obj, Fetcher))
        return self._progress

    def getSubProgress(self, obj):
        return self._progress

    def showStatus(self, msg):
        if self._activestatus:
            print
        else:
            self._activestatus = True
        sys.stdout.write(msg)
        sys.stdout.flush()

    def hideStatus(self):
        if self._activestatus:
            self._activestatus = False
            print

    def askYesNo(self, question, default=False):
        self.hideStatus()
        mask = default and _("%s (Y/n): ") or _("%s (y/N): ")
        res = raw_input(mask % question).strip().lower()
        print
        if res:
            return (_("yes").startswith(res) and not
                    _("no").startswith(res))
        return default

    def askContCancel(self, question, default=False):
        self.hideStatus()
        if default:
            mask = _("%s (Continue/cancel): ")
        else:
            mask = _("%s (continue/Cancel): ")
        res = raw_input(mask % question).strip().lower()
        print
        if res:
            return (_("continue").startswith(res) and not
                    _("cancel").startswith(res))
        return default

    def askOkCancel(self, question, default=False):
        self.hideStatus()
        mask = default and _("%s (Ok/cancel): ") or _("%s (ok/Cancel): ")
        res = raw_input(mask % question).strip().lower()
        print
        if res:
            return (_("ok").startswith(res) and not
                    _("cancel").startswith(res))
        return default

    def confirmChangeSet(self, changeset):
        return self.showChangeSet(changeset, confirm=True)

    def askInput(self, prompt, message=None, widthchars=None, echo=True):
        print
        if message:
            print message
        prompt += ": "
        try:
            if echo:
                res = raw_input(prompt)
            else:
                res = getpass.getpass(prompt)
        except KeyboardInterrupt:
            res = ""
        print
        return res

    def askPassword(self, location, caching=OPTIONAL):
        self._progress.lock()
        passwd = Interface.askPassword(self, location, caching)
        self._progress.unlock()
        return passwd

    def insertRemovableChannels(self, channels):
        self.hideStatus()
        print
        print _("Insert one or more of the following removable channels:")
        print
        for channel in channels:
            print "   ", str(channel)
        print
        return self.askOkCancel(_("Continue?"), True)

    # Non-standard interface methods:

    def showChangeSet(self, changeset, keep=None, confirm=False):
        self.hideStatus()
        report = Report(changeset)
        report.compute()

        screenwidth = getScreenWidth()

        hideversion = sysconf.get("text-hide-version", len(changeset) > 40)
        if hideversion:
            def cvt(lst):
                return [x.name for x in lst]
        else:
            def cvt(lst):
                return lst

        print
        if keep:
            keep = cvt(keep)
            keep.sort()
            print _("Kept packages (%d):") % len(keep)
            printColumns(keep, indent=2, width=screenwidth)
            print
        pkgs = report.upgrading.keys()
        if pkgs:
            pkgs = cvt(pkgs)
            pkgs.sort()
            print _("Upgrading packages (%d):") % len(pkgs)
            printColumns(pkgs, indent=2, width=screenwidth)
            print
        pkgs = report.downgrading.keys()
        if pkgs:
            pkgs = cvt(pkgs)
            pkgs.sort()
            print _("Downgrading packages (%d):") % len(pkgs)
            printColumns(pkgs, indent=2, width=screenwidth)
            print
        pkgs = report.installing.keys()
        if pkgs:
            pkgs = cvt(pkgs)
            pkgs.sort()
            print _("Installed packages (%d):") % len(pkgs)
            printColumns(pkgs, indent=2, width=screenwidth)
            print
        pkgs = report.removed.keys()
        if pkgs:
            pkgs = cvt(pkgs)
            pkgs.sort()
            print _("Removed packages (%d):") % len(pkgs)
            printColumns(pkgs, indent=2, width=screenwidth)
            print
        dsize = report.getDownloadSize()
        size = report.getInstallSize() - report.getRemoveSize()
        if dsize:
            sys.stdout.write(_("%s of package files are needed. ") %
                             sizeToStr(dsize))
        if size > 0:
            sys.stdout.write(_("%s will be used.") % sizeToStr(size))
        elif size < 0:
            size *= -1
            sys.stdout.write(_("%s will be freed.") % sizeToStr(size))
        if dsize or size:
            sys.stdout.write("\n\n")
        if confirm:
            return self.askYesNo(_("Confirm changes?"), True)
        return True
