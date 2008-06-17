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
from smart import Error, _
import pexpect
import time
import sys

class SSH:
    def __init__(self, username, host, password=None, getpassword=None):
        self.username = username
        self.host = host
        self.password = password
        self.getpassword = getpassword

    def _exec(self, command, **kwargs):
        p = pexpect.spawn(command, timeout=1)
        p.setecho(False)
        outlist = []
        while True:
            i = p.expect([pexpect.EOF, pexpect.TIMEOUT,
                          r"assword:", r"passphrase for key '.*':",
                          r"\(yes/no\)?"])
            if i == 0:
                outlist.append(p.before)
                break
            elif i == 1:
                outlist.append(p.before)
            elif i == 2 or i == 3:
                if self.password:
                    password = self.password
                elif self.getpassword:
                    password = self.getpassword()
                else:
                    raise Error, _("SSH asked for password, "
                                   "but no password is available")
                p.sendline(password)
                outlist = []
            elif i == 4:
                p.sendline("yes")
                outlist = []
        while p.isalive():
            try:
                time.sleep(1)
            except (pexpect.TIMEOUT, pexpect.EOF):
                # Continue until the child dies
                pass
        while outlist and outlist[0].startswith("Warning:"):
            outlist.pop(0)
        return p.exitstatus, "".join(outlist).strip()

    def ssh(self, command, **keywd):
        return self._exec("ssh %s@%s \"%s\"" %
                          (self.username, self.host, command), **keywd)

    def scp(self, src, dst, recursive=0, **kwargs):
        if recursive:
            r = "-r "
        else:
            r = ""
        return self._exec("scp %s-c blowfish %s %s@%s:%s" %
                          (r, src, self.username, self.host, dst), **kwargs)

    def rscp(self, src, dst, recursive=0, **kwargs):
        if recursive:
            r = "-r "
        else:
            r = ""
        return self._exec("scp %s-c blowfish %s@%s:%s %s" %
                          (r, self.username, self.host, src, dst), **kwargs)

    def exists(self, file):
        status, output = self.ssh("/bin/ls -ld %s" % file, noerror=1)
        return (status == 0)

# vim:ts=4:sw=4:et
