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
# Simple string buffer that wraps around streams to speed up writes
#

class StringBuffer:
    def __init__(self, stream):
        self.stream = stream
        self.buffer_size = 65536
        self.buffer = ""

    def write(self, data):
        self.buffer = self.buffer + data
        if len(self.buffer) < self.buffer_size:
            return
        # The buffer is full, send it
        self.stream.write(self.buffer[:self.buffer_size])
        self.buffer = self.buffer[self.buffer_size:]

    def flush(self):
        if self.buffer:
            self.stream.write(self.buffer)
            self.buffer = ""

    def close(self):
        self.flush()

    def __del__(self):
        self.close()
        

if __name__ == '__main__':
    import sys
    import time
    sb = StringBuffer(sys.stdout)
    sb.buffer_size = 10

    while 1:
        sb.write('a')
        time.sleep(.2)
