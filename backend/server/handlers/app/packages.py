#!/usr/bin/python
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
#
# Package uploading functions.
# Package info checking routines.
#

import os
import string
import tempfile
from types import TupleType

from common import RPC_Base, rhnFault, log_debug, log_error, CFG

from server import rhnSQL, rhnPackageUpload, rhnUser, rhnSession

from server.importlib.importLib import Collection, IncompatibleArchError,\
    Channel, IncompletePackage, InvalidChannelError
from server.importlib.packageImport import ChannelPackageSubscription
from server.importlib.backendOracle import OracleBackend

from server.importlib.packageUpload import uploadPackages, listChannels, listChannelsSource
from server.importlib.userAuth import UserAuth
from server.importlib.errataCache import schedule_errata_cache_update
from spacewalk.common.checksum import getFileChecksum

#12/22/05 wregglej 173287
#I made a decent number of changes to this file to implement session authentication.
#One of the requirements for this was to maintain backwards compatibility, so older
#versions of rhnpush can still talk to a newer satellite. This meant that I had to
#add new versions of each XMLRPC call that did authentication by sessions rather than
#username/password. I noticed that the only real difference between the two was the 
#authentication scheme that the functions used, so rather than copy-n-paste a bunch of code,
#I separated the functionality from the authentication and just pass a authentication object
#to the function that actually does stuff.


class Packages(RPC_Base):
    def __init__(self):
        log_debug(3)
        RPC_Base.__init__(self)        
        self.functions.append('uploadPackageInfo')
        self.functions.append('uploadPackageInfoBySession')
        self.functions.append('uploadSourcePackageInfo')
        self.functions.append('uploadSourcePackageInfoBySession')
        self.functions.append('listChannel')
        self.functions.append('listChannelBySession')
        self.functions.append('listChannelSource')
        self.functions.append('listChannelSourceBySession')
        self.functions.append('listMissingSourcePackages')
        self.functions.append('listMissingSourcePackagesBySession')
        self.functions.append('uploadPackage')
        self.functions.append('uploadPackageBySession')
        self.functions.append('channelPackageSubscription')
        self.functions.append('channelPackageSubscriptionBySession')
        self.functions.append('no_op')
        self.functions.append('test_login')
        self.functions.append('test_new_login')
        self.functions.append('test_check_session')
        self.functions.append('login')
        self.functions.append('check_session')
        self.functions.append('getPackageChecksum')
        self.functions.append('getPackageChecksumBySession')
        self.functions.append('getSourcePackageChecksum')
        self.functions.append('getSourcePackageChecksumBySession')
        # old MD5 compatibility functions
        self.functions.append('getPackageMD5sum')
        self.functions.append('getPackageMD5sumBySession')
        self.functions.append('getSourcePackageMD5sum')
        self.functions.append('getSourcePackageMD5sumBySession')
        
    def no_op(self):
        """ This is so the client can tell if the satellite supports session tokens or not. """
        return 1

    def uploadPackageInfo(self, username, password, info):
        """ Upload a collection of binary packages. """
        log_debug(5, username, info)
        authobj = auth(username, password)
        return self._uploadPackageInfo(authobj, info)

    def uploadPackageInfoBySession(self, session_string, info):
        log_debug(5, session_string)
        authobj = auth_session(session_string)
        return self._uploadPackageInfo(authobj, info)

    def _uploadPackageInfo(self, authobj, info):
        # Authorize the org id passed
        authobj.authzOrg(info)
        # Get the channels
        channels = info.get('channels')
        if channels:
            authobj.authzChannels(channels)
        force = 0
        if info.has_key('force'):
            force = info['force']
        return uploadPackages(info, force=force, 
            caller="server.app.uploadPackageInfo")
    
    def uploadSourcePackageInfo(self, username, password, info):
        """ Upload a collection of source packages. """
        log_debug(5, username, info)
        authobj = auth(username, password)
        return self._uploadSourcePackageInfo(authobj, info)

    def uploadSourcePackageInfoBySession(self, session_string, info):
        log_debug(5, session_string)
        authobj = auth_session(session_string)
        return self._uploadSourcePackageInfo(authobj, info)

    def _uploadSourcePackageInfo(self, authobj, info):
        # Authorize the org id passed
        authobj.authzOrg(info)
        force = 0
        if info.has_key('force'):
            force = info['force']
        return uploadPackages(info, source=1, force=force,
            caller="server.app.uploadSourcePackageInfo")


    def listChannelSource(self, channelList, username, password):
        log_debug(5, channelList, username)
        authobj = auth(username, password)
        return self._listChannelSource(authobj, channelList)
    
    def listChannelSourceBySession(self, channelList, session_string):
        log_debug(5, channelList, session_string)
        authobj = auth_session(session_string)
        return self._listChannelSource(authobj, channelList)

    def _listChannelSource(self, authobj, channelList):
        authobj.authzChannels(channelList)
        ret = listChannelsSource(channelList)
        return ret 


    def listChannel(self, channelList, username, password):
        """ List packages of a specified channel. """
        log_debug(5, channelList, username)
        authobj = auth(username, password)
        return self._listChannel(authobj, channelList)

    def listChannelBySession(self, channelList, session_string):
        log_debug(5, channelList, session_string)
        authobj = auth_session(session_string)
        return self._listChannel(authobj, channelList)

    def _listChannel(self, authobj, channelList):
        authobj.authzChannels(channelList)
        return listChannels(channelList)

    def login(self, username, password):
        """ This function that takes in the username
            and password and returns a session string if they are correct. It raises a
            rhnFault if the user/pass combo is not acceptable.
        """ 
        log_debug(5, username)
        user = rhnUser.search(username)
        if not user or not user.check_password(password):
            raise rhnFault(2)
        session = user.create_session()
        return session.get_session()

    def check_session(self, session):
        """ Checks a session string to make sure it is authentic expired. """
        try:
            user = rhnUser.session_reload(session)
        except (rhnSession.InvalidSessionError, rhnSession.ExpiredSessionError):
            return 0
        return 1

    def test_login(self, username, password):
        log_debug(5, username)
        try:
            authobj = auth( username, password )
        except:
            return 0
        return 1
    
    def test_new_login(self, username, password, session=None):
        """ rhnpush's --extended-test will call this function. """
        log_debug(5, "testing new login")
        return self.login(username, password)

    def test_check_session(self, session):
        """ rhnpush's --extended-test will call this function. """
        log_debug(5, "testing check session")
        return self.check_session(session)


    ###listMissingSourcePackages###
    def listMissingSourcePackages(self, channelList, username, password):
        """ List source packages for a list of channels. """
        log_debug(5, channelList, username)
        authobj = auth(username, password)
        return self._listMissingSourcePackages(authobj, channelList)

    def listMissingSourcePackagesBySession(self, channelList, session_string):
        log_debug(5, channelList, session_string)
        authobj = auth_session(session_string)  
        return self._listMissingSourcePackages(authobj, channelList)

    def _listMissingSourcePackages(self, authobj, channelList):
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


    def uploadPackage(self, username, password, info):
        """ Uploads an RPM package. """
        log_debug(3)

        channels = info.get('channels', [])
        force = info.get('force', 0)

        org_id, force = rhnPackageUpload.authenticate(username, password,
            channels=channels, force=force)
        return self._uploadPackage(channels, org_id, force, info)

    def uploadPackageBySession(self, session_string, info):
        log_debug(3)
        channels = info.get('channels', [])
        force = info.get('force', 0)

        org_id, force = rhnPackageUpload.authenticate_session(session_string,
            channels=channels, force=force)
        return self._uploadPackage(channels, org_id, force, info)

    def _uploadPackage(self, channels, org_id, force, info):
        """ Write the bits to a temporary file """
        packageBits = info['package']

        package_stream = tempfile.TemporaryFile()
        package_stream.write(packageBits)
        package_stream.seek(0, 0)
        del packageBits

        header, payload_stream, header_start, header_end = \
            rhnPackageUpload.load_package(package_stream)
        relative_path = rhnPackageUpload.relative_path_from_header(
            header, org_id=org_id)

        checksum_type = header.checksum_type()
        checksum = getFileChecksum(header.checksum_type(), file=package_stream)
        package_dict, diff_level = rhnPackageUpload.push_package(
            header, payload_stream, checksum_type, checksum, org_id=org_id, force=force,
            header_start=header_start, header_end=header_end,
            relative_path=relative_path)

        if diff_level:
            return package_dict, diff_level

        return 0

    
    def channelPackageSubscription(self, username, password, info):
        """ Uploads an RPM package. """
        log_debug(3)
        authobj = auth(username, password)
        return self._channelPackageSubscription(authobj, info)

    def channelPackageSubscriptionBySession(self, session_string, info):
        log_debug(3, info)
        authobj = auth_session(session_string)
        return self._channelPackageSubscription(authobj, info)

    def _channelPackageSubscription(self, authobj, info):
        # Authorize the org id passed
        authobj.authzOrg(info)

        packageList = info.get('packages') or []
        if not packageList:
            log_debug(1, "No packages found; done")
            return 0
        
        if not info.has_key('channels') or not info['channels']:
            log_debug(1, "No channels found; done")
            return 0

        channelList = info['channels']
        authobj.authzChannels(channelList)

        # Have to turn the channel list into a list of Channel objects
        channelList = map(lambda x: Channel().populate({'label' : x}), 
            channelList)

        # Since we're dealing with superusers, we allow them to change the org
        # id
        # XXX check if we don't open ourselves too much (misa 20030422)
        org_id = info.get('orgId')
        if org_id == '':
            org_id = None

        batch = Collection()
        package_keys = ['name', 'version', 'release', 'epoch', 'arch']
        for package in packageList:
            for k in package_keys:
                if not package.has_key(k):
                    raise Exception("Missing key %s" % k)
                if package['arch'] == 'src' or package['arch'] == 'nosrc':
                    # Source package - no reason to continue
                    continue
                _checksum_sql_filter = ""
                checksum_exists = 0
                if 'md5sum' in package: # for old rhnpush compatibility
                    package['checksum_type'] = 'md5'
                    package['checksum'] = package['md5sum']

                if package.has_key('checksum') and CFG.ENABLE_NVREA:
                    checksum_exists = 1
                    _checksum_sql_filter = """and c.checksum = :checksum
                                              and c.checksum_type = :checksum_type"""

                h = rhnSQL.prepare(self._get_pkg_info_query % \
                                    _checksum_sql_filter)
                pkg_epoch =  None
                if package['epoch'] != '':
                    pkg_epoch = package['epoch']

                if checksum_exists:
                    h.execute(pkg_name=package['name'], \
                    pkg_epoch=pkg_epoch, \
                    pkg_version=package['version'], \
                    pkg_rel=package['release'],pkg_arch=package['arch'], \
                    orgid = org_id, \
                    checksum_type = package['checksum_type'], \
                    checksum = package['checksum'])
                else:
                    h.execute(pkg_name=package['name'], \
                    pkg_epoch=pkg_epoch, \
                    pkg_version=package['version'], \
                    pkg_rel=package['release'], \
                    pkg_arch=package['arch'], orgid = org_id )

                row = h.fetchone_dict()

                package['checksum_type'] = row['checksum_type']
                package['checksum'] = row['checksum']
                package['org_id'] = org_id
                package['channels'] = channelList
                batch.append(IncompletePackage().populate(package))

        caller = "server.app.channelPackageSubscription"

        backend = OracleBackend()
        backend.init()
        importer = ChannelPackageSubscription(batch, backend, caller=caller)
        try:
            importer.run()
        except IncompatibleArchError, e:
            raise rhnFault(50, string.join(e.args), explain=0)
        except InvalidChannelError, e:
            raise rhnFault(50, str(e), explain=0)

        affected_channels = importer.affected_channels

        log_debug(3, "Computing errata cache for systems affected by channels",
            affected_channels)

        schedule_errata_cache_update(affected_channels)
        rhnSQL.commit()

        return 0

    _query_count_channel_servers = rhnSQL.Statement("""
        select count(*) server_count
          from rhnServerChannel sc, 
               rhnChannel c
         where c.label = :channel
           and c.id = sc.channel_id
    """)
    def _count_channel_servers(self, channel):
        h = rhnSQL.prepare(self._query_count_channel_servers)
        h.execute(channel=channel)
        row = h.fetchone_dict()
        return row['server_count']

    def getPackageChecksum(self, username, password, info):
        """ returns checksum info of available packages
            also does an existance check on the filesystem.
        """
        log_debug(3)

        pkg_infos = info.get('packages')
        channels = info.get('channels', [])
        force = info.get('force', 0)
        orgid = info.get('org_id')

        if orgid == 'null':
            null_org=1
        else:
            null_org=None
        org_id, force = rhnPackageUpload.authenticate(username, password,
                                                          channels=channels,
                                                          null_org=null_org,
                                                          force=force)
        return self._getPackageChecksum(org_id, pkg_infos)

    def getPackageMD5sum(self, username, password, info):
        """ bug#177762 gives md5sum info of available packages.
            also does an existance check on the filesystem.
        """
        log_debug(3)
        self._MD5sum2Checksum_info(info)
        return self._Checksum2MD5sum_list(
                    self.getPackageChecksum(username, password, info))

    def getPackageChecksumBySession(self, session_string, info):
        log_debug(3)

        pkg_infos = info.get('packages')
        channels  = info.get('channels', [])
        force     = info.get('force', 0)
        orgid = info.get('org_id')

        try:
            if orgid == 'null':
                null_org=1
            else:
                null_org=None
            org_id, force = rhnPackageUpload.authenticate_session(
                    session_string, channels=channels, null_org=null_org, force=force)
        except rhnSession.InvalidSessionError:
            raise rhnFault(33)
        except rhnSession.ExpiredSessionError:
            raise rhnFault(34)

        return self._getPackageChecksum(org_id, pkg_infos)

    def getPackageMD5sumBySession(self, session_string, info):
        log_debug(3)
        self._MD5sum2Checksum_info(info)
        return self._Checksum2MD5sum_list(
                    self.getPackageChecksumBySession(session_string, info))

    _get_pkg_info_query = """
        select
               c.checksum_type,
               c.checksum,
               p.path path
         from
               rhnPackageEVR pe,
               rhnPackageName pn,
               rhnPackage p,
               rhnPackageArch pa,
               rhnChecksumView c
         where
               pn.name     = :pkg_name
          and  ( pe.epoch  = :pkg_epoch or
                ( pe.epoch is null and :pkg_epoch is null )
               )
          and  pe.version  = :pkg_version
          and  pe.release  = :pkg_rel
          and  ( p.org_id  = :orgid or
                ( p.org_id is null and :orgid is null )
               )
          and  p.name_id   = pn.id
          and  p.evr_id    = pe.id
          and  p.package_arch_id = pa.id
          and  pa.label    = :pkg_arch
          and  p.checksum_id = c.id
          %s 
    """
 
    def _getPackageChecksum(self, org_id, pkg_infos):
        log_debug(3)
        row_list = {}
        checksum_exists = 0
        for pkg in pkg_infos.keys():

            pkg_info = pkg_infos[pkg] 
            _checksum_sql_filter = ""
            if pkg_info.has_key('checksum') and CFG.ENABLE_NVREA:
                checksum_exists = 1
                _checksum_sql_filter = """and c.checksum = :checksum
                                          and c.checksum_type = :checksum_type"""
            
            h = rhnSQL.prepare(self._get_pkg_info_query % _checksum_sql_filter)

            pkg_epoch = None
            if pkg_info['epoch'] != '':
                pkg_epoch = pkg_info['epoch']
           
            if checksum_exists:
                h.execute(pkg_name=pkg_info['name'],
                          pkg_epoch=pkg_epoch,
                          pkg_version=pkg_info['version'],
                          pkg_rel=pkg_info['release'],
                          pkg_arch=pkg_info['arch'],
                          orgid = org_id,
                          checksum_type = pkg_info['checksum_type'],
                          checksum = pkg_info['checksum'])
            else:
                h.execute(pkg_name=pkg_info['name'],
                          pkg_epoch=pkg_epoch,
                          pkg_version=pkg_info['version'],
                          pkg_rel=pkg_info['release'],
                          pkg_arch=pkg_info['arch'],
                          orgid = org_id )
                
            row = h.fetchone_dict()
            if not row:
		row_list[pkg] = ''
		continue
            
            if row.has_key('path'):    
                filePath = os.path.join(CFG.MOUNT_POINT, row['path'])
                if os.access(filePath, os.R_OK):
                    if row.has_key('checksum'):
                        row_list[pkg] = (row['checksum_type'], row['checksum'])
                    else:
                        row_list[pkg] = 'on-disk'
                else:
                    # Package not found on the filesystem
                    log_error("Package not found", filePath)
                    row_list[pkg] = ''
            else:
                log_error("Package path null for package", filePath)
                row_list[pkg] = ''    
                    
        return row_list                

    def _MD5sum2Checksum_info(self, info):
        log_debug(5)
        pkg_infos = info.get('packages')
        for pkg in pkg_infos.keys():
            if pkg_infos[pkg].has_key('md5sum'):
                pkg_infos[pkg]['checksum_type'] = 'md5'
                pkg_infos[pkg]['checksum'] = pkg_infos[pkg]['md5sum']
                del(pkg_infos[pkg]['md5sum'])

    def _Checksum2MD5sum_list(self, checksum_list):
        log_debug(5)
        row_list = {}
        for k in checksum_list.keys():
            if checksum_list[k] == '' or checksum_list[k] == 'on-disk':
                row_list[k] = checksum_list[k]
            elif type(checksum_list[k]) == TupleType and checksum_list[k][0] == 'md5':
                row_list[k] = checksum_list[k][1]
            else:
                row_list[k] = ''
        return row_list

    def getSourcePackageChecksum(self, username, password, info):
        """ Uploads an RPM package """
        log_debug(3)
        
        pkg_infos = info.get('packages')
        channels = info.get('channels', [])
        force = info.get('force', 0)
        orgid = info.get('org_id')
        
        if orgid == 'null':
            org_id, force = rhnPackageUpload.authenticate(username, password,
                                                          channels=channels,
                                                          null_org=1,
                                                          force=force)
        else:
            org_id, force = rhnPackageUpload.authenticate(username, password,
                                                          channels=channels,
                                                          force=force)
        
        return self._getSourcePackageChecksum(org_id, pkg_infos)

    def getSourcePackageMD5sum(self, username, password, info):
        log_debug(3)
        self._MD5sum2Checksum_info(info)
        return self._Checksum2MD5sum_list(
                    self.getSourcePackageChecksum(username, password, info))

    def getSourcePackageChecksumBySession(self, session_string, info):
        log_debug(3)

        pkg_infos = info.get('packages')
        channels = info.get('channels', [])
        force = info.get('force', 0)
        orgid = info.get('org_id')
        
        try:
            if orgid == 'null':
                null_org=1
            else:
                null_org=None
            org_id, force = rhnPackageUpload.authenticate_session(
                    session_string, channels=channels, null_org=null_org, force=force)
        except rhnSession.InvalidSessionError:
            raise rhnFault(33)
        except rhnSession.ExpiredSessionError:
            raise rhnFault(34)

        return self._getSourcePackageChecksum(org_id, pkg_infos)
    
    def getSourcePackageMD5sumBySession(self, session_string, info):
        log_debug(3)
        self._MD5sum2Checksum_info(info)
        return self._Checksum2MD5sum_list(
                    self.getSourcePackageChecksumBySession(session_string, info))

    def _getSourcePackageChecksum(self, org_id, pkg_infos):
        """ Gives checksum info of available source packages.
            Also does an existance check on the filesystem.
        """

        log_debug(3)

        statement = """
            select
                ps.path path,
                c.checksum,
                c.checksum_type
            from
                rhnSourceRpm sr,
                rhnPackageSource ps,
                rhnChecksumView c
            where
                 sr.name = :name
             and ps.source_rpm_id = sr.id
             and ( ps.org_id  = :orgid or
                   ( ps.org_id is null and :orgid is null )
                 )
             and ps.checksum_id = c.id
             """
        h = rhnSQL.prepare(statement)
        row_list = {}
        for pkg in pkg_infos.keys():

            h.execute(name=pkg, orgid = org_id )
            
            row = h.fetchone_dict()
            if not row:
		row_list[pkg] = ''
		continue
            
            if row.has_key('path'):    
                filePath = os.path.join(CFG.MOUNT_POINT, row['path'])
                if os.access(filePath, os.R_OK):
                    if row.has_key('checksum'):
                        row_list[pkg] = (row['checksum_type'], row['checksum'])
                    else:
                        row_list[pkg] = 'on-disk'
                else:
                    # Package not found on the filesystem
                    log_error("Package not found", filePath)
                    row_list[pkg] = ''
            else:
                log_error("Package path null for package", filePath)
                row_list[pkg] = ''    
                    
        return row_list
        
def auth(login, password):
    """ Authorize this user. """
    authobj = UserAuth()
    authobj.auth(login, password)
    return authobj

def auth_session(session_string):
    """ Authenticate based on a session. """
    authobj = UserAuth()
    authobj.auth_session(session_string)
    return authobj
