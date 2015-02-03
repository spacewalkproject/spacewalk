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
from thread import start_new_thread
import traceback

class Hooks:
    def __init__(self):
        self._hook = {}

    def register(self, hookname, hookfunc, priority=500, threaded=0):
        hook = self._hook.get(hookname)
        if not hook:
            self._hook[hookname] = [(hookfunc,priority,threaded)]
        else:
            l = len(hook)
            i = 0
            while i < l:
                if hook[i][1] > priority:
                    hook.insert(i, (hookfunc,priority,threaded))
                    break
                i = i + 1
            else:
                hook.append((hookfunc,priority,threaded))

    def unregister(self, hookname, hookfunc, priority=500, threaded=0):
        self._hook[hookname].remove((hookfunc,priority,threaded))

    def call(self, hookname, *hookparam, **hookkwparam):
        ret = []
        if hookname in self._hook:
            for hook in self._hook[hookname][:]:
                if hook[2]:
                    start_new_thread(hook[0], hookparam, hookkwparam)
                else:
                    val = hook[0](*hookparam, **hookkwparam)
                    ret.append(val)
                    if val == -1:
                        break
        return ret
