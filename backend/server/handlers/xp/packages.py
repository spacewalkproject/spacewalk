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
# Package uploading functions.
# Package info checking routines.
#

import string

from common import RPC_Base, rhnFault, log_debug

from server.importlib.packageUpload import uploadPackages, listChannels
from server.importlib.importLib import IncompatibleArchError
from server.importlib.userAuth import UserAuth
from server import rhnSQL

class Packages(RPC_Base):
    def __init__(self):
        log_debug(3)
        RPC_Base.__init__(self)        
        self.functions.append('uploadPackageInfo')
        self.functions.append('uploadSourcePackageInfo')
        self.functions.append('listChannel')
        self.functions.append('listMissingSourcePackages')


    def uploadPackageInfo(self, login, password, info):
        """ Upload a collection of binary packages """
        log_debug(5, login, info)
        authobj = auth(login, password)
        # Get the channels
        channels = info.get('channels')
        if channels:
            authobj.authzChannels(channels)
        info['orgId'] = authobj.org_id
        try:
            return uploadPackages(info, caller="server.xp.uploadPackageInfo")
        except IncompatibleArchError, e:
            raise rhnFault(506, string.join(e.args), explain=0)
    
    
    def uploadSourcePackageInfo(self, login, password, info):
        """ Upload a collection of source packages """
        log_debug(5, login, info)
        authobj = auth(login, password)
        info['orgId'] = authobj.org_id
        return uploadPackages(info, source=1, 
            caller="server.xp.uploadSourcePackageInfo")


    def listChannel(self, channelList, login, password):
        """ List packages of a specified channel """
        log_debug(4, channelList, login)
        authobj = auth(login, password)
        authobj.authzChannels(channelList)
        return listChannels(channelList)

    def listMissingSourcePackages(self, channelList, username, password):
        """ List source packages for a list of channels """
        log_debug(5, channelList, username)
        authobj = auth(username, password)
        authobj.authzChannels(channelList)

        h = rhnSQL.prepare("""
            select sr.name source_rpm
              from rhnChannel c,
                   rhnChannelNewestPackage cnp,
                   rhnPackage p,
                   rhnSourceRPM sr
             where cnp.channel_id = c.id
               and c.label = :channel_label
               and cnp.package_id = p.id
               and p.source_rpm_id = sr.id
            minus
            select sr.name source_rpm
              from rhnChannel c,
                   rhnChannelNewestPackage cnp,
                   rhnPackage p,
                   rhnSourceRPM sr,
                   rhnPackageSource ps
             where cnp.channel_id = c.id
               and c.label = :channel_label
               and cnp.package_id = p.id
               and p.source_rpm_id = sr.id
               and p.source_rpm_id = ps.source_rpm_id
               and (p.org_id = ps.org_id or
                    (p.org_id is null and ps.org_id is null)
                   )
        """)
        missing_packages = []
        for c in channelList:
            h.execute(channel_label=c)
            while 1:
                row = h.fetchone_dict()
                if not row:
                    break

                missing_packages.append([row['source_rpm'], c])

        return missing_packages

def auth(login, password):
    """ Authorize this user """
    authobj = UserAuth()
    authobj.auth(login, password)
    # Check if he's authorized to perform administrative tasks
    authobj.authzOrg({'orgId' : authobj.org_id})
    return authobj
