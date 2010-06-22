#
# Copyright (c) 2008 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
# 
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation. 
#
#

import time

class TimerException(Exception):
    pass

class MissingCheckpointException(Exception):
    pass

class Timer:
    def __init__(self):
        self._start = None
        self._checkpoint = None
        self._laps = {}

    def start(self):
        self._start = time.time()
        self._checkpoint = self._start
        return self

    def start_lap(self, name):
        self._laps[name] = time.time()
        return self
    
    def checkpoint(self, name=None, raw=0):
        now = time.time()
        if name is None:
            if self._checkpoint is None:
                raise MissingCheckpointException
            elapsed = now - self._checkpoint
            self._checkpoint = now
        else:
            if not self._laps.has_key(name):
                raise MissingCheckpointException(name)
            t = self._laps[name]
            if t is None:
                raise MissingCheckpointException(name)
            elapsed = now - t
            self._laps[name] = now

        if raw:
            return elapsed
        return self.format(elapsed)

    def elapsed(self, raw=0):
        e = time.time() - self._start
        if raw:
            return e
        return self.format(e)
    
    def format(self, val):
        return "%.3f" % val

    def end_lap(self, name, raw=0):
        ret = self.checkpoint(raw=raw, name=name)
        del self._laps[name]
        return self

