# This module extends rhn.rpclib (an xmlrpclib.py wrapper) with null values and
# handles UserDictCase properly.
#-------------------------------------------------------------------------------
#
# Copyright (c) 2008--2010 Red Hat, Inc.
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
# $Id: xxmlrpclib.py,v 1.10 2005/07/05 17:39:03 wregglej Exp $

## language imports
from types import NoneType, InstanceType

## extension imports
from rhn import rpclib

## local imports
from spacewalk.common import log_error, UserDictCase

class Marshaller(rpclib.xmlrpclib.Marshaller):
    """ Marshaller that understands NoneTypes
        FIXME: need to NOT use the static dispatch object it really interferes
               with the common code (hence I had to jump through hoops in
               proxy/rhnException.py - this will cause issues in the future.

        NOTE:
            In Python 2.3, the argument list to the Marshaller's dump_* methods
            gained an additional argument called 'write'.  In order to make our
            custom dispatch methods backward-compatible with <= 2.2, we'll
            use an optional argument called "compat_args".  If supplied, we 
            assume this is the "write" argument required in >= Python 2.3 and 
            pass it along if necessary.
    """

    def dump_null(self, value, *compat_args):
        self.write("<value><null/></value>\n")
    rpclib.xmlrpclib.Marshaller.dispatch[NoneType] = dump_null

    def dump_instance(self, value, *compat_args):
        if len(compat_args) > 0:
            # Python >= 2.3 version

            write = compat_args[0]
            if isinstance(value, UserDictCase):
                return self.dump_struct(value.dict(), write)
            rpclib.xmlrpclib.Marshaller.dump_instance(self, value, write)
        else:
            # Python < 2.3 version

            if isinstance(value, UserDictCase):
                return self.dump_struct(value.dict())
            rpclib.xmlrpclib.Marshaller.dump_instance(self, value)
    rpclib.xmlrpclib.Marshaller.dispatch[InstanceType] = dump_instance


class Unmarshaller(rpclib.xmlrpclib.Unmarshaller):
    """ Unmarshaller that understands NoneTypes
        FIXME: need to NOT use the static dispatch object it really interferes
               with the common code (hence I had to jump through hoops in
               proxy/rhnException.py - this will cause issues in the future.
    """
    def end_null(self, join=None):
        self.append(None)
    rpclib.xmlrpclib.Unmarshaller.dispatch["null"] = end_null


Fault = rpclib.xmlrpclib.Fault
dumps = rpclib.xmlrpclib.dumps
loads = rpclib.xmlrpclib.loads

transports = rpclib.transports

