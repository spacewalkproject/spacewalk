# Communication routines for sockets connecting to the auth token cache daemon
#
# Copyright (c) 2008--2012 Red Hat, Inc.
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
#-------------------------------------------------------------------------------

## system imports
import struct

## local imports
from xmlrpclib import dumps, loads


class CommunicationError(Exception):
    def __init__(self, faultCode, faultString, *params):
        Exception.__init__(self)
        self.faultCode = faultCode
        self.faultString = faultString
        self.args = params


def readSocket(fd, n):
    """ Reads exactly n bytes from the file descriptor fd (if possible) """
    result = "" # The result
    while n > 0:
        buff = fd.read(n)
        if not buff:
            break
        n = n - len(buff)
        result = result + buff
    return result


def send(fd, methodname=None, fault=None, *params):
    if methodname:
        buff = dumps(params, methodname=methodname)
    elif fault:
        buff = dumps(fault)
    else:
        buff = dumps(params)
    # Write the length first
    fd.write(struct.pack("!L", len(buff)))
    # Then send the data itself
    fd.write(buff)
    return len(buff)


def recv(rfile):
    # Compute the size of an unsigned int
    n = struct.calcsize("L")
    # Read the first bytes to figure out the size
    buff = readSocket(rfile, n)
    if len(buff) != n:
        # Incomplete read
        raise CommunicationError(0,
            "Expected %d bytes; got only %d" % (n, len(buff)))

    n,  = struct.unpack("!L", buff)

    if n > 65536:
        # The buffer to be read is too big
        raise CommunicationError(1, "Block too big: %s" % len(buff))

    buff = readSocket(rfile, n)
    if len(buff) != n:
        # Incomplete read
        raise CommunicationError(0,
            "Expected %d bytes; got only %d" % (n, len(buff)))

    return loads(buff)

