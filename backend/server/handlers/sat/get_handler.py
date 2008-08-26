#!/usr/bin/python
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
# GET handler for /SAT

import os
import string

import auth
import rhnPackage

from common import CFG, log_debug, log_error, rhnFault, rhnFlags
from common.rhnTranslate import _
from server import rhnSQL, apacheRequest, rhnRepository

class GetHandler(apacheRequest.GetHandler):
    """ handles the GET requests for /SAT requests """

    def method_ref(self, method):
        """ get a function reference for the GET request """
        log_debug(3, self.server, method)

        server_id = rhnFlags.get("AUTH_SESSION_TOKEN")['X-RHN-Server-Id']

        # Aithorize channel
        auth_obj = auth.Authentication()
        auth_obj.server_id = server_id

        auth_obj._auth_channel(self.channel)
        
        repository = Repository(self.channel, server_id)
            
        f = repository.get_function(method)
        if f is None:
            raise apacheRequest.UnknownXML(
                "function '%s' invalid; path_info is %s" % (
                    method, self.req.path_info))
        return f

class Repository(rhnRepository.Repository):
    def __init__(self, *args, **kwargs):
        apply(rhnRepository.Repository.__init__, (self, ) + args, kwargs)
        self.functions = [
            'getPackage',
            'getKickstartFile',
        ]
        
    def getPackagePath(self, pkgFilename, redirect_capable=0):	
        """
        Overloads getPackagePath in common/rhnRepository.
        returns remote/rhn package paths from satellite-sync
        specific sanity checks and queries.
        """
        log_debug(2, pkgFilename, redirect_capable)
        #bz#198590
        #check for re-direct check flag from header to issue package
        #request from client in order to avoid failover loops.
        skip_redirect = rhnFlags.get('x-rhn-redirect')        

        #get redirect and local paths for given package
        remotepath, localpath = self.getAllPathsByFilename(pkgFilename)

        #check for redirect conditions and fail over checks
        if redirect_capable and not CFG.SATELLITE and not skip_redirect \
            and remotepath is not None:
            self.redirect_location = remotepath
            # We've set self.redirect_location, we're done here
            #we raise a redirectException in server.rhnRepository._getFile
            return None
            # Package cannot be served from the edge, we serve it ourselves
        return localpath
    
    def getAllPathsByFilename(self,pkgFilename):
        """
        get the edge network remote path and localpath for a
        given package.
        """
        log_debug(3, pkgFilename)
        
        return rhnPackage.get_all_paths_by_filename(self.server_id, pkgFilename,
            self.channelName)

    def getKickstartFile(self, ks_label, *path_comps):
        log_debug(2, path_comps)
        # Filter out any multiple / chars
        path_comps = filter(None, path_comps)
        if len(path_comps) == 0:
            log_error(1, path_comps)
            raise rhnFault(2100, _("Invalid argument"), explain=0)
        relative_path = string.join(path_comps, '/')

        file_path = self.get_kickstart_file_path(self.channelName, ks_label,
            relative_path)
        return self._getFile(file_path)

    _query_get_ks_file_path = rhnSQL.Statement("""
        select ks.base_path
          from rhnKSTreeFile kstf,
               rhnKickstartableTree ks,
               rhnChannel c
         where kstf.relative_filename = :relative_path
           and kstf.kstree_id = ks.id
           and ks.label = :ks_label
           and ks.channel_id = c.id
           and c.label = :channel
    """)
    def get_kickstart_file_path(self, channel, ks_label, relative_path):
        h = rhnSQL.prepare(self._query_get_ks_file_path)
        h.execute(relative_path=relative_path, ks_label=ks_label,
            channel=channel)

        row = h.fetchone_dict()
        if not row:
            raise rhnFault(2101, _("Kickstart file %s not found in tree %s") % 
                (relative_path, ks_label), explain=0)

        ks_tree_base_path = row['base_path']

        path = os.path.normpath(os.path.join(CFG.MOUNT_POINT,
            ks_tree_base_path, relative_path))

        if not os.path.isfile(path):
            log_error("Unable to find kickstart file", path)
            raise rhnFault(2102, 
                _("Kickstart file %s (tree %s) not found on the disk") % (
                relative_path, ks_label), explain=0)

        return path
