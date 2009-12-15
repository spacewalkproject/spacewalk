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

import os
import stat
import types
import string
import cStringIO
from rhn import rpclib

from spacewalk.common import rhn_rpm

# local imports
import rhnFlags
from rhnLog import log_debug
from rhnLib import rfc822time
from rhnException import rhnException, rhnFault
from RPC_Base import RPC_Base

class Repository(RPC_Base):
    """ Shared repository class, inherited by both the proxy and server specific
        Repository classes.
    """
    def __init__(self, channelName = None):
        log_debug(2, channelName)
        RPC_Base.__init__(self)
        self.channelName = channelName
        # Default visible functions.
        self.compress_headers = 1
        self.functions = [
            'getPackage',
            'getPackageHeader',
            'getPackageSource'
        ]

    def set_compress_headers(self, val):
        self.compress_headers = val

    def __del__(self):
        self.channelName = None
        self.functions = None

    def getPackagePath(self, pkgFilename, redirect=0):
        """Returns the path to a package.
           OVERLOAD this in server and proxy rhnRepository.
           I.e.: they construct the path differently.
        """
        raise rhnException("This function should be overloaded.")

    def getPackagePathNVRA(self, nvra):
        """OVERLOAD this in server and proxy rhnRepository.
           I.e.: they construct the path differently.
        """
        raise rhnException("This function should be overloaded.")

    def getSourcePackagePath(self, pkgFilename):
        """Returns the path to a package.
           OVERLOAD this in server and proxy rhnRepository.
           I.e.: they construct the path differently.
        """
        raise rhnException("This function should be overloaded.")

    def getPackage(self, pkgFilename, *args):
        """ Get rpm package. """
        log_debug(3, pkgFilename)
        if args:
            pkg_spec = [pkgFilename] + list(args)
        else:
            pkg_spec = pkgFilename

        redirectsSupported = 0

        # If we are talking to a proxy, determine whether it's a version that
        # supports redirects.
        proxyVersionString = rhnFlags.get('x-rhn-proxy-version')
        if proxyVersionString:
            # Convert the version string to a number format that we can compare.
            versionParts = proxyVersionString.split('.')
            proxyVersionStringBaked = \
                "%s.%s" % (versionParts[0], string.join(versionParts[1:], ''))

            # Check the proxy version.  To maintain backward compatibility, we 
            # won't redirect to proxies < v4.1.0.
            log_debug(3, "Detected proxy version " + proxyVersionStringBaked)
            if float(proxyVersionStringBaked) >= 4.1:
                redirectsSupported = 1
        else:
            # Must be a client.  We'll determine the redirect capability via
            # the x-rhn-transport-capability header instead.
            transport_cap = rhnFlags.get('x-rhn-transport-capability')
            if transport_cap :
                transport_cap_list = transport_cap.split('=')
                redirectsSupported = transport_cap_list[0] == 'follow-redirects' and transport_cap_list[1] >= 2

        if redirectsSupported:
            log_debug(3, "Client supports redirects.")
	    filePath = self.getPackagePath(pkg_spec, 1)	
        else:
            #older clients just return the hosted url and download the package
            filePath = self.getPackagePath(pkg_spec)
        
        return self._getFile(filePath)

    def getPackageSource(self, pkgFilename):
        """ Get srpm packrge. """
        log_debug(3, pkgFilename)
        # Sanity check:
        l = string.split(pkgFilename, '.')
        #6/23/05 wregglej 154248, Don't mangle the filename if it's a nosrc package.
        if l[-2] != "nosrc":
            l[-2] = 'src'
        pkgFilename = string.join(l, '.')
        filePath = self.getSourcePackagePath(pkgFilename)
        return self._getFile(filePath)
    
    def getPackageHeader(self, pkgFilename):
        """ Get rpm header.
            XXX: stock 8.0 clients could not compress headers, we need to either
            change the function name, or version the protocol
        """
        log_debug(3, pkgFilename)
        pkg = string.split(pkgFilename, '.')
        # Basic sanity checks:
        if pkg[-1] not in ["hdr", 'rpm']:
            raise rhnFault(21, "'%s' not a valid RPM header name"
                               % pkgFilename)
        
        pkgFilename = string.join(pkg[:-1], ".") + '.rpm'
        filePath = self.getPackagePath(pkgFilename)
        data = self._getHeaderFromFile(filePath)
        # XXX: Interesting. Found that if returned just data, this
        #      function works fine. Investigate later.
        return rpclib.File(cStringIO.StringIO(data), len(data))

    # The real workhorse for all flavors of listall
    # It tries to pull data out of a file; if it doesn't work,
    # it calls the data producer with the specified params to generate the
    # data, which is also cached

    # --- PRIVATE METHODS ---

    def _getFile(self, filePath):
        """ Returns xmlrpclib file object to any file given a path to it.
            IN:  filePath: path to any file.
            OUT: XMLed rpm or source rpm, or an xmlrpc file object.
        """
        log_debug(3, filePath)
        features = self._fileFeatures(filePath)
        filePath = features['path']
        length = features['length']
        lastModified = features['lastModified']
        self._set_last_modified(lastModified)
        return rpclib.File(open(filePath, "rb"), length, name=filePath)

    def _getHeaderFromFile(self, filePath, stat_info=None):
        """ Utility function to extract a header from an rpm.
            If stat_info was already passed, don't re-stat the file
        """
        log_debug(3, filePath)
        if stat_info:
            s = stat_info
        else:
            s = None
            try:
                s = os.stat(filePath)
            except:
                raise rhnFault(17, "Unable to read package %s"
                                   % os.path.basename(filePath))
            
        lastModified = s[stat.ST_MTIME]
        del s # XXX: not neccessary?
        
        # Get the package header from the file
        # since we stat()ed the file, we know it's there already
        fd = os.open(filePath, os.O_RDONLY)
        h = rhn_rpm.get_package_header(fd=fd)
        os.close(fd)
        if h is None:
            raise rhnFault(17, "Invalid RPM %s" % os.path.basename(filePath))
        stringIO = cStringIO.StringIO()
        # Put the result in stringIO
        stringIO.write(h.unload())
        del h # XXX: not neccessary?

        pkgFilename = os.path.basename(filePath)
        pkg = string.split(pkgFilename, '.')
        # Replace .rpm with .hdr
        pkg[-1] = "hdr"
        pkgFilename = string.join(pkg, ".")
        extra_headers = {
            'X-RHN-Package-Header' : pkgFilename,
        }
        self._set_last_modified(lastModified, extra_headers=extra_headers)
        rhnFlags.set("AlreadyEncoded", 1)
        return stringIO.getvalue()

    def _set_last_modified(self, last_modified, extra_headers={}):
        log_debug(4, last_modified)
        if not last_modified:
            return None
        # Set a field with the name of the header
        transport = rhnFlags.get('outputTransportOptions')
        if last_modified:
            # Put the last-modified info too
            if type(last_modified) in (types.IntType, types.FloatType):
                last_modified = rfc822time(last_modified)
            transport['Last-Modified'] = last_modified
        for k, v in extra_headers.items():
            transport[str(k)] = str(v)
        return transport

    def _fileFeatures(self, filePath):
        """ From a filepath, construct a dictionary of file features. """
        log_debug(3, filePath)
        if not filePath:
            raise rhnFault(17, "While looking for file: `%s'"
                               % os.path.basename(filePath))
        try:
            s = os.stat(filePath)
        except:
            s = None
        if not s:
            l = 0
            lastModified = 0
        else:
            l = s[stat.ST_SIZE]
            lastModified = s[stat.ST_MTIME]
        del s

        # Build the result hash
        result = {}
        result['name'] = os.path.basename(filePath)
        result['length'] = l
        result['path'] = filePath
        if lastModified:
            result['lastModified'] = rfc822time(lastModified)
        else:
            result['lastModified'] = None
        return result
