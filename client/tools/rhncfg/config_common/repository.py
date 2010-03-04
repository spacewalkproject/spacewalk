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

import re
import os
import pwd
import grp
import sys
import stat
import string
import cfg_exceptions
import local_config
import base64
import utils

from rhn_log import log_debug, die
#from rhn_rpc import rpclib
try:
    from selinux import lgetfilecon
except:
    # on rhel4 we do not support selinux
    def lgetfilecon(path):
        return [0, ''];


#6/29/05 rpc_wrapper implements the failover logic.
import rpc_wrapper
rpclib = rpc_wrapper

def deci_to_octal(number):
    """convert a normal decimal int to another int representing the octal value"""
    temp = number
    oct_str = ""
    while temp > 0:
        digit = temp % 8
        oct_str = string.octdigits[digit] + oct_str
        temp = temp / 8
    return int(oct_str)

class Repository:
    _uid_cache = {}
    _gid_cache = {}
    _local_config = local_config

    def __init__(self):
        self.default_delimiters = None
        self.maximum_file_size = None

    # Helpers

    # Unless overridden in a subclass, per-file delimiters are the same as the
    # global delimiters
    def get_file_delimiters(self, file):
        "returns the default delimiters for this file"
        return self.get_default_delimiters()

    def get_default_delimiters(self):
        "returns the default delimiters"
        if self.default_delimiters is None:
            self.default_delimiters = self._get_default_delimiters()
        return self.default_delimiters

    def _get_default_delimiters(self):
        raise NotImplementedError

    def get_maximum_file_size(self):
        "returns the maximum file size"
        if self.maximum_file_size is None:
            self.maximum_file_size = self._get_maximum_file_size()
        return self.maximum_file_size

    def _get_maximum_file_size(self):
        "To be overwritten in subclasses"
        return 1024

    def _make_stat_info(self, path, file_stat):
        # Returns the stat information as required by the API
        ret = {}
        fields = {
            'mode'      : stat.ST_MODE & 07777,
            'user'      : stat.ST_UID,
            'group'     : stat.ST_GID,
            'size'      : stat.ST_SIZE,
            'mtime'     : stat.ST_MTIME,
            'ctime'     : stat.ST_CTIME,
        }
        for label, st in fields.items():
            ret[label] = file_stat[st]

        # server expects things like 644, 700, etc.
        ret['mode'] = deci_to_octal(ret['mode'] & 07777)

        #print ret['size']
        #if ret['size'] > self.get_maximum_file_size():
        #    die(4, "File %s exceeds the maximum file size (%s)" %
        #        (path, ret['size']))

        uid = ret['user']
        gid = ret['group']

        pw_name = self._uid_cache.get(uid)
        if not pw_name:
            try:
                pw_name = pwd.getpwuid(uid)[0]
            except KeyError:
                print "Error looking up user id %s" % (uid, )

        if pw_name:
            ret['user'] = pw_name
            self._uid_cache[uid] = pw_name

        gr_name = self._gid_cache.get(gid)
        if not gr_name:
            try:
                gr_name = grp.getgrgid(gid)[0]
            except KeyError:
                print "Error looking up group id %s" % (gid, )

        if gr_name:
            ret['group'] = gr_name
            self._gid_cache[gid] = gr_name

        ret['selinux_ctx'] = lgetfilecon(path)[1]
        if ret['selinux_ctx'] == None:
            ret['selinux_ctx'] = ''

        return ret

    def _make_file_info(self, remote_path, local_path=None, delim_start=None,
            delim_end=None, load_contents=1):
        if not local_path:
            # Safe enough to assume local path is the same as the remote one
            local_path = remote_path

        try:
            file_stat = os.stat(local_path)
        except OSError, e:
            raise cfg_exceptions.RepositoryLocalFileError(
                "Error stat()-ing local file: %s" % e)

        # Dlimiters
        if delim_start or delim_end:
            if not (delim_start and delim_end):
                # If only one delimiter is provided, assume the delimiters are
                # the same, whatever that is (or is nice)
                delim_start = delim_end = (delim_start or delim_end)
        else:
            # Use the default
            delim_start, delim_end = self.get_file_delimiters(remote_path)

        params = {
            'path'          : remote_path,
            'delim_start'   : delim_start,
            'delim_end'     : delim_end,
        }

        file_contents = None
        if os.path.isdir(local_path):
            params['config_file_type_id'] = 2
            load_contents = 0
        else:
            params['config_file_type_id'] = 1

        if load_contents:
            try:
                file_contents = open(local_path, "r").read()
            except IOError, e:
                raise cfg_exceptions.RepositoryLocalFileError(
                    "Error opening local file: %s" % e)

            self._add_content(file_contents, params)

        params.update(self._make_stat_info(local_path, file_stat))
        return params

    def _add_content(self, file_contents, params):
        """Add the file contents to the params hash"""

        params['enc64'] = 1
        params['file_contents'] = base64.encodestring(file_contents)

    def login(self, username=None, password=None):
        pass


class RPC_Repository(Repository):


    def __init__(self, setup_network=1):
        Repository.__init__(self)
        # all this so needs to be in a seperate rhnConfig library,
        # shared by up2date, rhncfg*, etc.
        #
        # But, I digress.

        self.__server_url = self._local_config.get('server_url')

        # 6/29/05 wregglej 152388
        # server_list contains the list of servers to failover to.
        self.__server_list = self._local_config.get('server_list')

        # 6/29/05 wregglej 152388
        # Grab server_handler, which is different for rhncfg-client and rhncfg-manager
        # and is needed when failover occurs. During a failover, when the server object is
        # being set up to use a new satellite, the server_handler is added to the address so
        # the tool communicates with the correct xmlrpc handler.
        handler = self._local_config.get('server_handler')
        cap_handler = re.sub('[^/]+$', 'XMLRPC', handler)

        if not self.__server_url:
            raise cfg_exceptions.ConfigurationError(
                "Missing entry 'server_url' in the config files\n" \
                "Try running as root, or configure server_url as described in the configuration file"
                )

        log_debug(3, "server url", self.__server_url)
        self.__proxy_user = None
        self.__proxy_password = None
        self.__proxy_host = None

        self.__enable_proxy = self._local_config.get('enableProxy')
        self.__enable_proxy_auth = self._local_config.get('enableProxyAuth')

        if self.__enable_proxy:
            self.__proxy_host = self._local_config.get('httpProxy')

            if self.__enable_proxy_auth:
                self.__proxy_user = self._local_config.get('proxyUser')
                self.__proxy_password = self._local_config.get('proxyPassword')

        ca = self._local_config.get('sslCACert')
        if type(ca) == type(""):
            ca = [ca]

        ca_certs = ca or ["/usr/share/rhn/RHNS-CA-CERT"]

        # not sure if we need this or not...
        lang = None
        for env in 'LANGUAGE', 'LC_ALL', 'LC_MESSAGES', 'LANG':
            if os.environ.has_key(env):
                if not os.environ[env]:
                    # sometimes unset
                    continue
                lang = string.split(os.environ[env], ':')[0]
                lang = string.split(lang, '.')[0]
                break

        if setup_network:
            # Fetch server capabilities - we need the /XMLRPC handler
            #t = list(utils.parse_url(self.__server_url))
            #t[2] = '/XMLRPC'
            #x_server_url = utils.unparse_url(t)

            # 6/29/05 wregglej 152388
            # Fetching the server capabilities involves using the /XMLRPC handler. It's
            # the only place that I know of that does that. The server_url and server_list
            # both need to have /XMLRPC on the ends, which is what _patch_uris() does by default.
            x_server_url = self._patch_uris(self.__server_url, cap_handler)
            if self.__server_list != None:
                x_server_list = self._patch_uris(self.__server_list, cap_handler)
            else:
                x_server_list = None

            x_server = rpclib.Server(x_server_url,
                proxy=self.__proxy_host,
                username=self.__proxy_user,
                password=self.__proxy_password,
                server_list=x_server_list,
                rpc_handler="/XMLRPC")

            # Make a call to a function that can export the server's capabilities
            # without setting any state on the server side
            try:
                x_server.registration.welcome_message()
            except rpclib.Fault, e:
                sys.stderr.write("XML-RPC error while talking to %s:\n %s\n" % (self.__server_url, e))
                sys.exit(2)

            self._server_capabilities = get_server_capability(x_server)
            del x_server

        # 6/29/05 wregglej 152388
        # From here on out all communication should take place through the xmlrpc handler
        # that's appropriate for the tool being used. For rhncfg-client that's /CONFIG-MANAGEMENT.
        # For rhncfg-manager that's /CONFIG-MANAGEMENT-TOOL. No, I don't know the reasoning behind that.
        # First we need to patch the uris in server_list, to use the correct handler.
        self.__server_url = self._patch_uris(self.__server_url, handler)
        if self.__server_list != None:
            self.__server_list = self._patch_uris(self.__server_list, handler)
        else:
            self.__server_list = None

        self.server = rpclib.Server(self.__server_url,
                                    proxy=self.__proxy_host,
                                    username=self.__proxy_user,
                                    password=self.__proxy_password,
                                    server_list=self.__server_list,
                                    rpc_handler=handler)

        self._set_capabilities()
        self.server.set_transport_flags(encoding="gzip", transfer="binary")

        if lang:
            self.server.setlang(lang)

        for ca_cert in ca_certs:
            if not os.access(ca_cert, os.R_OK):
                raise cfg_exceptions.ConfigurationError("Can not find CA file: %s" % ca_cert)

            log_debug(3, "ca cert", ca_cert)
            # force the validation of the SSL cert
            self.server.add_trusted_cert(ca_cert)

    # 6/29/05 wregglej 152388
    # Places handler at the end of the uri.
    # uris can be either a uri string or a list of uri strings.
    def _patch_uris(self, uris, handler="/XMLRPC"):
        #Handles patching the uris when they're in a list.
        if type(uris) == type([]):
            ret = []
            for i in range(len(uris)):
                t = list(utils.parse_url(uris[i]))
                t[2] = handler
                ret.append(utils.unparse_url(t))
        #Handles patching the uri when it's a string.
        else:
            t = list(utils.parse_url(uris))
            t[2] = handler
            ret = utils.unparse_url(t)
        return ret

    def _set_capabilities(self):
        # list of client capabilities
        capabilities = {
            'configfiles.base64_enc' : {'version' : 1, 'value' : 1},
            'rhncfg.dirs_enabled'    : {'version' : 1, 'value' : 1},
        }
        for name, hashval in capabilities.items():
            cap = "%s(%s)=%s" % (name, hashval['version'], hashval['value'])
            self.server.add_header("X-RHN-Client-Capability", cap)

    def rpc_call(self, method_name, *params):
        method = getattr(self.server, method_name)
        try:
            result = apply(method, params)
        except rpclib.ProtocolError, e:
            sys.stderr.write("XML-RPC call error: %s\n" % e)
            sys.exit(1)
        except rpclib.Fault:
            # Re-raise them
            raise
        except Exception, e:
            sys.stderr.write("XML-RPC error while talking to %s: %s\n" % (
                self.__server_url, e))
            sys.exit(2)

        return result

    def _get_maximum_file_size(self):
        return self.rpc_call('config.max_upload_fsize')

    def _add_content(self, file_contents, params):
        """Add the file contents to the params hash"""

        # check for the rhncfg.content.base64_decode capability and encode the
        # data if the server is capable of descoding it
        if self._server_capabilities.has_key('rhncfg.content.base64_decode'):
            params['enc64'] = 1
            params['file_contents'] = base64.encodestring(file_contents)
        else:
            params['file_contents'] = file_contents

        return params

def get_server_capability(s):
    headers = s.get_response_headers()
    if headers is None:
        # No request done yet
        return {}
    cap_headers = headers.getallmatchingheaders("X-RHN-Server-Capability")
    if not cap_headers:
        return {}
    regexp = re.compile(
            r"^(?P<name>[^(]*)\((?P<version>[^)]*)\)\s*=\s*(?P<value>.*)$")
    vals = {}
    for h in cap_headers:
        arr = string.split(h, ':', 1)
        assert len(arr) == 2
        val = string.strip(arr[1])
        if not val:
            continue

        mo = regexp.match(val)
        if not mo:
            # XXX Just ignoring it, for now
            continue
        vdict = mo.groupdict()
        for k, v in vdict.items():
            vdict[k] = string.strip(v)

        vals[vdict['name']] = vdict
    return vals

