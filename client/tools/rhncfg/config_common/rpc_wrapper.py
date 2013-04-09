#
# Copyright (c) 2008--2011 Red Hat, Inc.
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

import sys
import string
from rhn import rpclib
import xmlrpclib
try:
    from socket import error, sslerror, herror, gaierror, timeout
except ImportError:
    from socket import error
    sslerror = error
    herror = error
    gaierror = error
    timeout = error

#This is raised when the failover stuff has gone through every server in the server list
#and the error is still occurring.
class NoMoreServers(Exception):
    pass


#This was supposed to be a wrapper that contained a reference to a rpclib.Server object and delegated calls to it,
#but it turns out that I needed to override _request() to make sure that all
#communication errors are caught and handled here, so I changed it to be a subclass of rpclib.Server.
#The problem that spurred that was when a xmlrpc function was called on an object that was an
#attribute of the server class it wasn't passing through the _request that I had written here,
#it was going directly to rpclib.Server's _request() and missing all of the failover logic that I had added.
#The short version is that I needed to make sure this class was in the inheritance hierarchy. 
class Server(rpclib.Server):
    def __init__(self, uri, transport=None, encoding=None, verbose=0,
        proxy=None, username=None, password=None, refreshCallback=None,
        progressCallback=None, server_list=None, rpc_handler=None):
        self.list_of_uris = None    #Contains all of the possible uris.
        self.current_index = 0      #index of the uri that we're currently using.
        
        #If server_list is None, then no failover systems were listed in the up2date config and
        #we need to use the one that was put together in the rhncfg-* config, which was passed in as
        #uri.
        if server_list is None:
            if type(uri) == type([]):
                self.list_of_uris = uri
            else:
                self.list_of_uris = [uri]
        else:
            #If the server_url passed in is the same as the first element of the server_list, then
            #that means all of the server info came from the up2date config (or is the same as the up2date config)
            #and we should use the server_list.
            #If they don't match then we should use the server_url passed in as uri, because it's a specific setting from
            #the rhncfg-*.conf file.
            if uri == server_list[0]:
                self.list_of_uris = server_list
            else:
                self.list_of_uris = [uri]

        self.rpc_handler = rpc_handler

        #Grabs the initial uri that we're going to use.
        init_uri = self._get_uri()

        
        #self.rpc_args = {
        #                    'transport'             :       transport,
        #                    'encoding'              :       encoding,
        #                    'verbose'               :       verbose,
        #                    'proxy'                 :       proxy,
        #                    'username'              :       username,
        #                    'password'              :       password,
        #                    'refreshCallback'       :       refreshCallback,
        #                    'progressCallback'      :       progressCallback,

        #                 }
        #Set up the rpclib.Server stuff with the first uri.
        rpclib.Server.__init__(self, init_uri, transport=transport, encoding=encoding, verbose=verbose,\
                                      proxy=proxy, username=username, password=password, refreshCallback=refreshCallback,\
                                      progressCallback=progressCallback)

    #Return the uri that we should be using.
    def _get_uri(self):
        return self.list_of_uris[self.current_index]

    #Returns the list of uris that could be used.
    def get_uri_list(self):
        return self.list_of_uris

    #This is called when we failover. It re-inits the server object to use the new uri. Most of this was cribbed from
    #alikins' wrapper that does a similar thing for up2date.
    def init_server(self, myuri):
        #Borrowed the following from rpcServer.py
        #rpclib.Server.__init__(self, uri, transport=self.rpc_args['transport'], encoding=self.rpc_args['encoding'], verbose=self.rpc_args['verbose'],\
        #                              proxy=self.rpc_args['proxy'], username=self.rpc_args['username'],\
        #                              password=self.rpc_args['password'], refreshCallback=self.rpc_args['refreshCallback'],\
        #                              progressCallback=self.rpc_args['progressCallback'])
        import urllib
        self._uri = myuri
        typ, uri = urllib.splittype(self._uri)
        typ = string.lower(typ)
        if typ not in ("http", "https"):
            raise InvalidRedirectionError(
                "Redirected to unsupported protocol %s" % typ)
        
        self._host, self._handler = urllib.splithost(uri)
        self._orig_handler = self._handler
        self._type = typ
        if not self._handler:
            self._handler = self.rpc_handler
        self._allow_redirect = 1
        del self._transport
        self._transport = self.default_transport(typ, self._proxy,
                                             self._username, self._password)
        self.set_progress_callback(self._progressCallback)
        self.set_refresh_callback(self._refreshCallback)
        self.set_buffer_size(self._bufferSize)
        self.setlang(self._lang)

        if self._trusted_cert_files != [] and \
            hasattr(self._transport, "add_trusted_cert"):
            for certfile in self._trusted_cert_files:
                self._transport.add_trusted_cert(certfile)

    #This is the logic for switching to a new server resides.
    def _failover(self):
        #The print statements are from alikins rpcServer.py.
        msg = "An error occured talking to %s:\n" % self._get_uri()
        msg = msg + "%s\n%s\n" % (sys.exc_type, sys.exc_value)

        #Increments the index to point to the next server in self.list_of_uris
        self.current_index = self.current_index + 1

        #Make sure we don't try to go past the end of the list.
        if self.current_index > (len(self.list_of_uris) - 1):
            raise NoMoreServers()
        else:
            failover_uri = self._get_uri()  #Grab the uri of the new server to use.
        msg = msg + "Trying the next serverURL: %s\n" % failover_uri

        print msg        

        #Set up rpclib.Server to use the new uri.
        self.init_server(failover_uri)

    #This is where the magic happens. function is a function reference, arglist is the list of arguements
    #that get passed to the function and kwargs is the list of named arguments that get passed into the function.
    #I used apply() here so it will work with Python 1.5, which doesn't have the extended call syntax.
    def _call_function(self, function, arglist, kwargs={}):
        succeed = 0
        while succeed == 0:
            try:
                ret = apply(function, arglist, kwargs)
            except rpclib.InvalidRedirectionError:
                raise
            except xmlrpclib.Fault, e:
                save_traceback = sys.exc_info()[2]
                try:
                    self._failover()
                except NoMoreServers, f:
                    raise e, None, save_traceback  #Don't raise the NoMoreServers error, raise the error that triggered the failover.
                continue
            except (error, sslerror, herror, gaierror, timeout), e:
                save_traceback = sys.exc_info()[2]
                try:
                    self._failover()    
                except NoMoreServers, f:
                    raise e, None, save_traceback
                continue
            succeed = 1 #If we get here then the function call eventually succeeded and we don't need to try again.
        return ret
 
    def _request(self, methodname, params):
        return self._call_function(rpclib.Server._request, (self, methodname, params))

    def __getattr__(self, name):
        return rpclib.xmlrpclib._Method(self._request, name)
