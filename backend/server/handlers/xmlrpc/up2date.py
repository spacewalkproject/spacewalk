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
# Implements the up2date.* fucntions for XMLRPC
#

# system module import
import time
import string

# global module import
from rhn import rpclib
from types import ListType, TupleType, StringType, IntType

# common module imports
from common import CFG, rhnFlags, rhnFault, log_debug, log_error
from common.rhnTranslate import _
from rhn.common import rhn_rpm

# local module imports
from server.rhnLib import computeSignature
from server import rhnChannel, rhnHandler, rhnPackage, rhnDependency,\
    rhnCapability
from server.rhnServer import server_route

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
        # --- Clients v1- ---
        self.functions.append('listall')
        self.functions.append('listall_size')
        self.functions.append('header')
        self.functions.append('package')
        self.functions.append('source_package')
        self.functions.append('source_package_by_name')
        # --- All clients ---
        self.functions.append('solvedep')
        self.functions.append('solveDependencies')
        self.functions.append('solveDependencies_arch')
        self.functions.append('solveDependencies_with_limits')
    
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
        server = self.auth_system(system_id)
        # log the entry
        log_debug(1, self.server_id)
        # Update the capabilities list
        rhnCapability.update_client_capabilities(self.server_id)
        # Fetch the channels this client is subscribed to
        channelList = rhnChannel.channels_for_server(self.server_id)
        channels = []
        for each in channelList:
            if not each.has_key('last_modified'):
                # No last_modified attribute
                # Probably an empty channel, so ignore
                continue
            channel = [each['label'], each['last_modified']]
            # isBaseChannel
            if each['parent_channel']:
                flag = "0"
            else:
                flag = "1"
            channel.append(flag)

            # isLocalChannel
            if each['local_channel']:
                flag = "1"
            else:
                flag = "0"
            channel.append(flag)

            channels.append(channel)

        rhnServerTime = str(time.time())
        expireOffset = str(CFG.CLIENT_AUTH_TIMEOUT)
        signature = computeSignature(CFG.SECRET_KEY,
                                     self.server_id,
                                     self.user,
                                     rhnServerTime,
                                     expireOffset)

        loginDict = {
                'X-RHN-Server-Id'           : self.server_id,
                'X-RHN-Auth-User-Id'        : self.user,
                'X-RHN-Auth'                : signature,
                'X-RHN-Auth-Server-Time'    : rhnServerTime,
                'X-RHN-Auth-Expire-Offset'  : expireOffset,
                # List of lists [[label,last_mod],...]:
                'X-RHN-Auth-Channels'       : channels
                }

        # Duplicate these values in the headers so that the proxy can
        # intercept and cache them without parseing the xmlrpc.
        transport = rhnFlags.get('outputTransportOptions')
        transport['X-RHN-Action'] = 'login'
        for k, v in loginDict.items():
            # Special case for channels
            if string.lower(k) == string.lower('X-RHN-Auth-Channels'):
                # Concatenate the channel information column-separated
                transport[k] = map(lambda x: string.join(x, ':'), v)
            else:
                transport[k] = v
        log_debug(5, "loginDict", loginDict, transport)

        # store route in DB (schema for RHN 3.1+ only!)
        server_route.store_client_route(self.server_id)

        return loginDict


    def listChannels(self, system_id):
        """ Clients v2+ """
        log_debug(5, system_id)
        # Stuff the action in the headers:
        transport = rhnFlags.get('outputTransportOptions')
        transport['X-RHN-Action'] = 'listChannels'
        # Authenticate the system certificate
        self.auth_system(system_id)
        # log the entry
        log_debug(1, self.server_id)
        channelList = rhnChannel.channels_for_server(self.server_id)
        return channelList


    def subscribeChannels(self, system_id, channelNames, username, passwd):
        """ Clients v2+ """
        log_debug(5, system_id, channelNames, username, passwd)
        # Stuff the action in the headers:
        transport = rhnFlags.get('outputTransportOptions')
        transport['X-RHN-Action'] = 'subscribeChannel'
        # Authenticate the system certificate
        self.auth_system(system_id)
        # log the entry
        log_debug(1, self.server_id, channelNames)
        for channelName in channelNames:
            rhnChannel.subscribe_channel(self.server_id, channelName,
                                         username, passwd)
        return 0


    def unsubscribeChannels(self, system_id, channelNames, username, passwd):
        """ Clients v2+ """
        log_debug(3)
        # Stuff the action in the headers:
        transport = rhnFlags.get('outputTransportOptions')
        transport['X-RHN-Action'] = 'unsubscribeChannel'
        # Authenticate the system certificate
        self.auth_system(system_id)
        # log the entry
        log_debug(1, self.server_id, channelNames)
        for channelName in channelNames:
            rhnChannel.unsubscribe_channel(self.server_id, channelName,
                                           username, passwd)
        return 0


    def listall(self, system_id):
        """ Clients v1-
            Package listing in [[n,v,r,e],...] format.
        
            NOTE: format weirdness: epoch returned is either an integer or ''.
        """
        log_debug(5, system_id)
        # Authenticate the system certificate
        self.auth_system(system_id)
        # log the entry
        log_debug(1, self.server_id)
        # Stuff the action in the headers:
        transport = rhnFlags.get('outputTransportOptions')
        transport['X-RHN-Action'] = 'listall'
        # and now call into rhnChannel to find the data
        return rhnChannel.list_packages_for_server(self.server_id)

    def listall_size(self, system_id):
        """ Clients v1-
            Package listing in [[n,v,r,e,s],...] format.

            NOTE: format weirdness: epoch returned is either an integer or ''.
                                 size is an integer.
        """
        log_debug(5, system_id)
        # Authenticate the system certificate
        self.auth_system(system_id)
        # log the entry
        log_debug(1, self.server_id)
        # Stuff the action in the headers:
        transport = rhnFlags.get('outputTransportOptions')
        transport['X-RHN-Action'] = 'listall_size'
        # call into rhnChannel to find the data
        return rhnChannel.list_packages_for_server(self.server_id,
                                                   need_size = 1)

    def header(self, system_id, pkgList):
        """ Clients v1-

            IN:  system_id: ....
                  a package identifier (or a list of them)
                    [n,v,r,e] or
                    [[n,v,r,e],...]
            OUT: If Proxy:
                If Client:
        """
        log_debug(5, system_id, pkgList)
        if type(pkgList) not in (ListType, TupleType) or not len(pkgList):
            log_error("Invalid package list spec", type(pkgList),
                      "len = %d" % len(pkgList))
            raise rhnFault(30, _("Invalid value %s (type %s)") % (
                pkgList, type(pkgList)))
        # Okay, it's a list; is it a list of lists?
        if type(pkgList[0]) is StringType:
            # Wrap it in a list
            pkgList = [pkgList]
        # Now check all params
        req_list = []
        for p in pkgList:
            req_list.append(check_package_spec(p))
        # Authenticate the system certificate
        server = self.auth_system(system_id)
        # log the entry
        log_debug(1, self.server_id, "items: %d" % len(req_list))

        rpmHeaders = []
        for pkg in pkgList:
            # Authorize this package fetch.
            # XXX: a bit heavy-handed I think... but old client stuff.
            #      NOTE: pkg for old client is [n,v,r,e]
            path = rhnPackage.get_package_path_compat_arches(
                self.server_id, pkg, server.archname)

            # read the header from the file on disk
            h = rhn_rpm.get_package_header(filename=path)
            if h is None:
                log_error("Unable to read package header", pkg)
                raise rhnFault(17,
                        _("Unable to retrieve package header %s") % str(pkg))
            rpmHeaders.append(rpclib.xmlrpclib.Binary(h.unload()))
            del h

        # Stuff the action in the headers:
        transport = rhnFlags.get('outputTransportOptions')
        transport['X-RHN-Action'] = 'header'

        # Reset the flag for the proxy download accelerator
        # This gets set by default in rhnPackage
        rhnFlags.set("Download-Accelerator-Path", None)
        if CFG.COMPRESS_HEADERS:
            # Compress
            rhnFlags.set("compress_response", 1)
        return rpmHeaders


    def package(self, system_id, package):
        """ Clients v1-
            Get rpm package.
        """
        log_debug(5, "Begin", package)

        # Have package in canonical form
        package = check_package_spec(package)

        # Authenticate the system certificate and set the QoS data
        # according to the user type
        self.set_qos = 1
        server = self.auth_system(system_id)

        # log the entry (avoiding to fill the log in case of abuse)
        log_debug(1, self.server_id, str(package)[:100])

        filePath = rhnPackage.get_package_path_compat_arches(self.server_id,
            package, server.archname)

        # Stuff the action in the headers:
        transport = rhnFlags.get('outputTransportOptions')
        transport['X-RHN-Action'] = "package"
        return rpclib.File(open(filePath, "r"), name=filePath)


    def source_package(self, system_id, package):
        """ Clients v1-
            Get a source rpm package.
        """
        log_debug(5, "Begin", package)

        # Have package in canonical form
        package = check_package_spec(package)

        # Authenticate the system certificate and set the QoS data
        # according to the user type
        self.set_qos = 1
        server = self.auth_system(system_id)

        # log the entry (avoiding to fill the log in case of abuse)
        log_debug(1, self.server_id, str(package)[:100])

        filePath = rhnPackage.get_source_package_path_by_nvre(self.server_id,
            package)

        # Stuff the action in the headers:
        transport = rhnFlags.get('outputTransportOptions')
        transport['X-RHN-Action'] = "source_package"
        return rpclib.File(open(filePath, "r"), name=filePath)


    def source_package_by_name(self, system_id, filename):
        """ Clients v1-
            Get a source rpm package by its human readable filename.
            Just like source_package, but we get a package by filename.
        """
        log_debug(5, "Begin", filename)

        # Authenticate the system certificate and set the QoS data
        # according to the user type
        self.set_qos = 1
        server = self.auth_system(system_id)

        # log the entry (avoiding to fill the log in case of abuse)
        log_debug(1, self.server_id, str(filename)[:100])

        filePath = rhnPackage.get_source_package_path_by_name(self.server_id,
            filename)

        # Stuff the action in the headers:
        transport = rhnFlags.get('outputTransportOptions')
        transport['X-RHN-Action'] = "source_package_by_name"
        return rpclib.File(open(filePath, "r"), name=filePath)


    def solvedep(self, system_id, deps):
        """ Clients v1-
            Solve dependencies for a given dependency problem list.
            IN:  a dependency problem list: [name, name, name, ...]
            RET: a package list: [[n,v,r,e],[n,v,r,e],...] That solves the
                 dependencies.
        """
        log_debug(4, system_id)
        return self.__solveDep(system_id, deps, action = "solvedep",
                               clientVersion = 1)


    def solveDependencies(self, system_id, deps):
        """ Clients v2+
            Solve dependencies for a given dependency problem list (newer version)
            IN:  a dependency problem list: [name, name, name, ...]
            RET: a hash {name: [[n, v, r, e], [n, v, r, e], ...], ...}
        """
        log_debug(4, system_id)
        return self.__solveDep(system_id, deps, action = "solvedep",
                               clientVersion = 2)

    def solveDependencies_arch(self, system_id, deps):
        """ Does the same thing as solve_dependencies, but also returns the architecture label with the
            package info.
            IN:  a dependency problem list: [name, name, name, ...]
            RET: a hash {name: [[n, v, r, e, a], [n, v, r, e, a], ...], ...}
        """
        log_debug(4, system_id)
        return self.__solveDep_arch(system_id, deps, action = "solvedep",
                               clientVersion = 2)

    def solveDependencies_with_limits(self, system_id, deps, all=0, limit_operator = None, limit = None):
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
        return self.__solveDep_with_limits( system_id, deps, action = "solvedep", 
            clientVersion = 2, all=all, limit_operator=limit_operator, limit=limit)

    def history(self, system_id, summary, body = ""):
        """ Clients v2+
            Add a history log for a performed action
        """
        log_debug(5, system_id, summary, body)
        # Authenticate the system certificate
        server = self.auth_system(system_id)
        # log the entry
        log_debug(1, self.server_id)
        # Stuff the action in the headers:
        transport = rhnFlags.get('outputTransportOptions')
        transport['X-RHN-Action'] = 'history'
        # XXX: Probably this should be a non fatal error...
        server.add_history(summary, body)
        server.save_history()
        return 0


    # --- PRIVATE METHODS ---

    def __solveDep(self, system_id, deps, action, clientVersion):
        """ Response for clients:
                version 1: list
                version 2: hash
        """
        log_debug(5, system_id, deps, action, clientVersion)
        faultString = _("Invalid value %s (%s)")
        if type(deps) not in (ListType, TupleType):
            log_error("Invalid argument type", type(deps))
            raise rhnFault(30, faultString % (deps, type(deps)))
        for dep in deps:
            if type(dep) is not StringType:
                log_error("Invalid dependency member", type(dep))
                raise rhnFault(30, faultString % (dep, type(dep)))
        # Ignore empty strings
        deps = filter(len, deps)
        # anything left to do?
        if not deps:
            return []
        # Authenticate the system certificate
        server = self.auth_system(system_id)
        log_debug(1, self.server_id, action, "items: %d" % len(deps))
        # Solve dependencies
        result = rhnDependency.solve_dependencies(self.server_id,
                                                  deps, clientVersion)

        # Stuff the action in the headers:
        transport = rhnFlags.get('outputTransportOptions')
        transport['X-RHN-Action'] = action
        return result

    def __solveDep_arch(self, system_id, deps, action, clientVersion):
        """ Response for clients:
                version 1: list
                version 2: hash
        """
        log_debug(5, system_id, deps, action, clientVersion)
        faultString = _("Invalid value %s (%s)")
        if type(deps) not in (ListType, TupleType):
            log_error("Invalid argument type", type(deps))
            raise rhnFault(30, faultString % (deps, type(deps)))
        for dep in deps:
            if type(dep) is not StringType:
                log_error("Invalid dependency member", type(dep))
                raise rhnFault(30, faultString % (dep, type(dep)))
        # Ignore empty strings
        deps = filter(len, deps)
        # anything left to do?
        if not deps:
            return []
        # Authenticate the system certificate
        server = self.auth_system(system_id)
        log_debug(1, self.server_id, action, "items: %d" % len(deps))
        # Solve dependencies
        result = rhnDependency.solve_dependencies_arch(self.server_id,
                                                  deps, clientVersion)

        # Stuff the action in the headers:
        transport = rhnFlags.get('outputTransportOptions')
        transport['X-RHN-Action'] = action
        return result


    def __solveDep_with_limits(self, system_id, deps, action, clientVersion, all=0, limit_operator=None, limit=None):
        """ Response for clients:
                version 1: list
                version 2: hash
        """
        log_debug(5, system_id, deps, action, clientVersion)
        faultString = _("Invalid value %s (%s)")
        if type(deps) not in (ListType, TupleType):
            log_error("Invalid argument type", type(deps))
            raise rhnFault(30, faultString % (deps, type(deps)))
        for dep in deps:
            if type(dep) is not StringType:
                log_error("Invalid dependency member", type(dep))
                raise rhnFault(30, faultString % (dep, type(dep)))
        # Ignore empty strings
        deps = filter(len, deps)
        # anything left to do?
        if not deps:
            return []
        # Authenticate the system certificate
        server = self.auth_system(system_id)
        log_debug(1, self.server_id, action, "items: %d" % len(deps))
        # Solve dependencies
        result = rhnDependency.solve_dependencies_with_limits(self.server_id,
                                                  deps, clientVersion, all, limit_operator, limit)

        # Stuff the action in the headers:
        transport = rhnFlags.get('outputTransportOptions')
        transport['X-RHN-Action'] = action
        return result

def check_package_spec(package):
    """ Check for a package spec correctness
        Each package should be a list or a tuple of three or four members,
        name, version, release, [epoch]
        in case of lack of epoch we assume "" string
        WARNING: we need to make sure we bound ALL values as strings because
        the lack of epoch is suggested by the empty string (''), which is going
        to cause problems if epoch gets bound as an integer.
    """
    # This one checks for sane values for name, version, release
    def __check_Int_String(name, value, package = package):
        if type(value) not in (StringType, IntType):
            log_error("Field %s (%s)=`%s' in %s does not pass type checks" % (
                name, type(value), str(value), str(package)))
            raise rhnFault(30, _("Invalid value for %s in package tuple: "
                                 "%s (%s)") % (name, value, type(value)))
        value = str(value)
        if not len(value):
            log_error("Field %s has an EMPTY value in %s" % (value, package))
        return value

    log_debug(4, package)
    # Checks if package is a proper package spec
    if type(package) not in (ListType, TupleType) or len(package) < 3:
        log_error("Package argument %s (len = %d) does not "
                  "pass type checks" % (str(package), len(package)))
        raise rhnFault(30, _("Invalid package parameter %s (%s)") %
                       (package, type(package)))
    name, version, release = package[:3]
    # figure out the epoch
    if len(package) > 3:
        epoch = package[3]
        if epoch in ["(none)", "None", None]:
            epoch = ""
        epoch = str(epoch)
    else:
        epoch = ""
    # impose some validity checks on name, version, release
    name = __check_Int_String("name", name)
    version = __check_Int_String("version", version)
    release = __check_Int_String("release", release)
    # Fix up for safety
    return [name, version, release, epoch]


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
                'server'        :   'xmlrpc.rhn.redhat.com',
                'handler'       :   '/XMLRPC',
                'description'   :   'XML-RPC Server',
                'location'      :   'United States',
            },
        ]
        return servers_list

