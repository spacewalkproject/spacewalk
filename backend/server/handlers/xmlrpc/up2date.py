#
# Copyright (c) 2008--2016 Red Hat, Inc.
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
# Implements the up2date.* fucntions for XMLRPC
#

# system module import
import time
import string

from spacewalk.server.rhnServer import server_lib
from rhn import rpclib
from spacewalk.common.usix import ListType, TupleType, StringType, IntType
from spacewalk.common import rhnFlags, rhn_rpm
from spacewalk.common.rhnLog import log_debug, log_error
from spacewalk.common.rhnConfig import CFG
from spacewalk.common.rhnException import rhnFault
from spacewalk.common.rhnTB import add_to_seclist
from spacewalk.common.rhnTranslate import _
from spacewalk.server.rhnLib import computeSignature
from spacewalk.server.rhnHandler import rhnHandler
from spacewalk.server import rhnChannel, rhnPackage, rhnDependency,\
    rhnCapability
from spacewalk.server.rhnServer import server_route

import re
NONSUBSCRIBABLE_CHANNELS = re.compile("(rhn-proxy|rhn-satellite)")


class Up2date(rhnHandler):

    """ xml-rpc Server Functions that we will provide for the outside world.
    """

    def __init__(self):
        """ Up2date Class Constructor

           o Initializes inherited class.
           o Appends the functions available to the outside world in the
             rhnHandler list.
        """
        rhnHandler.__init__(self)
        # Function list inherited from rhnHandler
        # This action garners control of what is available to the client.

        # --- Clients v2+ ---
        # (getting headers, source and packages done with GETs now).
        self.functions.append('login')
        self.functions.append('listChannels')
        self.functions.append('subscribeChannels')
        self.functions.append('unsubscribeChannels')
        self.functions.append('history')
        self.functions.append('solvedep')
        self.functions.append('solveDependencies')
        self.functions.append('solveDependencies_arch')
        self.functions.append('solveDependencies_with_limits')

    def auth_system(self, action, system_id):
        # Stuff the action in the headers:
        transport = rhnFlags.get('outputTransportOptions')
        transport['X-RHN-Action'] = action
        return rhnHandler.auth_system(self, system_id)

    def login(self, system_id, extra_data={}):
        """ Clients v2+
            Log in routine.
            Return a dictionary of session token/channel information.
            Also sets this information in the headers.
        """
        log_debug(5, system_id)
        # Authenticate the system certificate. We need the user record
        # to generate the tokens
        self.load_user = 1
        server = self.auth_system('login', system_id)
        # log the entry
        log_debug(1, self.server_id)
        # Update the capabilities list
        rhnCapability.update_client_capabilities(self.server_id)
        # Fetch the channels this client is subscribed to
        channels = rhnChannel.getSubscribedChannels(self.server_id)

        rhnServerTime = str(time.time())
        expireOffset = str(CFG.CLIENT_AUTH_TIMEOUT)
        signature = computeSignature(CFG.SECRET_KEY,
                                     self.server_id,
                                     self.user,
                                     rhnServerTime,
                                     expireOffset)

        loginDict = {
            'X-RHN-Server-Id': self.server_id,
            'X-RHN-Auth-User-Id': self.user,
            'X-RHN-Auth': signature,
            'X-RHN-Auth-Server-Time': rhnServerTime,
            'X-RHN-Auth-Expire-Offset': expireOffset,
            # List of lists [[label,last_mod],...]:
            'X-RHN-Auth-Channels': channels
        }

        # Duplicate these values in the headers so that the proxy can
        # intercept and cache them without parseing the xmlrpc.
        transport = rhnFlags.get('outputTransportOptions')
        for k, v in loginDict.items():
            # Special case for channels
            if string.lower(k) == string.lower('X-RHN-Auth-Channels'):
                # Concatenate the channel information column-separated
                transport[k] = [string.join(x, ':') for x in v]
            else:
                transport[k] = v
        log_debug(5, "loginDict", loginDict, transport)

        # store route in DB (schema for RHN 3.1+ only!)
        server_route.store_client_route(self.server_id)

        return loginDict

    def listChannels(self, system_id):
        """ Clients v2+ """
        log_debug(5, system_id)
        # Authenticate the system certificate
        self.auth_system('listChannels', system_id)
        # log the entry
        log_debug(1, self.server_id)
        channelList = rhnChannel.channels_for_server(self.server_id)
        return channelList

    def subscribeChannels(self, system_id, channelNames, username, passwd):
        """ Clients v2+ """
        add_to_seclist(passwd)
        log_debug(5, system_id, channelNames, username, passwd)
        # Authenticate the system certificate
        self.auth_system('subscribeChannel', system_id)
        # log the entry
        log_debug(1, self.server_id, channelNames)
        server_lib.snapshot_server(self.server_id, 'Base Channel Updated')
        for channelName in channelNames:
            if NONSUBSCRIBABLE_CHANNELS.search(channelName):
                raise rhnFault(73, explain=False)
            else:
                rhnChannel.subscribe_channel(self.server_id, channelName,
                                             username, passwd)
        return 0

    def unsubscribeChannels(self, system_id, channelNames, username, passwd):
        """ Clients v2+ """
        add_to_seclist(passwd)
        log_debug(3)
        # Authenticate the system certificate
        self.auth_system('unsubscribeChannel', system_id)
        # log the entry
        log_debug(1, self.server_id, channelNames)
        for channelName in channelNames:
            rhnChannel.unsubscribe_channel(self.server_id, channelName,
                                           username, passwd)
        return 0

    def solvedep(self, system_id, deps):
        """ Clients v1-
            Solve dependencies for a given dependency problem list.
            IN:  a dependency problem list: [name, name, name, ...]
            RET: a package list: [[n,v,r,e],[n,v,r,e],...] That solves the
                 dependencies.
        """
        log_debug(4, system_id)
        return self.__solveDep(system_id, deps, action="solvedep",
                               clientVersion=1)

    def solveDependencies(self, system_id, deps):
        """ Clients v2+
            Solve dependencies for a given dependency problem list (newer version)
            IN:  a dependency problem list: [name, name, name, ...]
            RET: a hash {name: [[n, v, r, e], [n, v, r, e], ...], ...}
        """
        log_debug(4, system_id)
        return self.__solveDep(system_id, deps, action="solvedep",
                               clientVersion=2)

    def solveDependencies_arch(self, system_id, deps):
        """ Does the same thing as solve_dependencies, but also returns the architecture label with the
            package info.
            IN:  a dependency problem list: [name, name, name, ...]
            RET: a hash {name: [[n, v, r, e, a], [n, v, r, e, a], ...], ...}
        """
        log_debug(4, system_id)
        return self.__solveDep_arch(system_id, deps, action="solvedep",
                                    clientVersion=2)

    def solveDependencies_with_limits(self, system_id, deps, all=0, limit_operator=None, limit=None):
        """ This version of solve_dependencies allows the caller to get all of the packages that solve a
            dependency and limit the packages that are returned to those that match the criteria defined
            by limit_operator and limit. This version of the function also returns the architecture label
            of the package[s] that get returned.

            limit_operator can be any of: '<', '<=', '==', '>=', or '>'.
            limit is a a string of the format [epoch:]name-version-release
            deps is a list of filenames that the packages that are returned must provide.
            version is the version of the client that is calling the function.
        """
        log_debug(4, system_id)
        return self.__solveDep_with_limits(system_id, deps, action="solvedep",
                                           clientVersion=2, all=all, limit_operator=limit_operator, limit=limit)

    def history(self, system_id, summary, body=""):
        """ Clients v2+
            Add a history log for a performed action
        """
        log_debug(5, system_id, summary, body)
        # Authenticate the system certificate
        server = self.auth_system('history', system_id)
        # log the entry
        log_debug(1, self.server_id)
        # XXX: Probably this should be a non fatal error...
        server.add_history(summary, body)
        server.save_history()
        return 0

    # --- PRIVATE METHODS ---

    def __solveDep_prepare(self, system_id, deps, action, clientVersion):
        """ Response for clients:
                version 1: list
                version 2: hash
        """
        log_debug(7, system_id, deps, action, clientVersion)
        faultString = _("Invalid value %s (%s)")
        if type(deps) not in (ListType, TupleType):
            log_error("Invalid argument type", type(deps))
            raise rhnFault(30, faultString % (deps, type(deps)))
        for dep in deps:
            if type(dep) is not StringType:
                log_error("Invalid dependency member", type(dep))
                raise rhnFault(30, faultString % (dep, type(dep)))
        # Ignore empty strings
        deps = list(filter(len, deps))
        # anything left to do?
        if not deps:
            return []
        # Authenticate the system certificate
        server = self.auth_system(action, system_id)
        log_debug(1, self.server_id, action, "items: %d" % len(deps))
        return deps

    def __solveDep(self, system_id, deps, action, clientVersion):
        """ Response for clients:
                version 1: list
                version 2: hash
        """
        log_debug(5, system_id, deps, action, clientVersion)
        result = self.__solveDep_prepare(system_id, deps, action, clientVersion)
        if result:
            # Solve dependencies
            result = rhnDependency.solve_dependencies(self.server_id,
                                                      result, clientVersion)
        return result

    def __solveDep_arch(self, system_id, deps, action, clientVersion):
        """ Response for clients:
                version 1: list
                version 2: hash
        """
        log_debug(5, system_id, deps, action, clientVersion)
        result = self.__solveDep_prepare(system_id, deps, action, clientVersion)
        if result:
            # Solve dependencies
            result = rhnDependency.solve_dependencies_arch(self.server_id,
                                                           result, clientVersion)
        return result

    def __solveDep_with_limits(self, system_id, deps, action, clientVersion, all=0, limit_operator=None, limit=None):
        """ Response for clients:
                version 1: list
                version 2: hash
        """
        log_debug(5, system_id, deps, action, clientVersion)
        result = self.__solveDep_prepare(system_id, deps, action, clientVersion)
        if result:
            # Solve dependencies
            result = rhnDependency.solve_dependencies_with_limits(self.server_id,
                                                                  deps, clientVersion, all, limit_operator, limit)
        return result


class Servers(rhnHandler):

    """ A class to handle the site selection... """

    def __init__(self):
        """Servers Class Constructor. """
        rhnHandler.__init__(self)
        self.functions.append('get')
        self.functions.append('list')

    def get(self, *junk):
        """ Older funtion that can be a noop. """
        return []

    def list(self, systemid=None):
        """ Returns a list of available servers the client can connect to. """
        servers_list = [
            {
                'server':   'xmlrpc.rhn.redhat.com',
                'handler':   '/XMLRPC',
                'description':   'XML-RPC Server',
                'location':   'United States',
            },
        ]
        return servers_list
