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

import os
import tempfile
import base64

from config_common import cfg_exceptions, repository, utils, file_utils
from config_common.rhn_log import log_debug

class Repository(repository.RPC_Repository):
    _session_file = '.rhncfg-manager-session'
    def __init__(self, setup_network=1):
        log_debug(2)
        repository.RPC_Repository.__init__(self, setup_network)

        self.files_to_delete = []

        self.username = None
        self.password = None

        self.session = None

    def login(self, username=None, password=None):

        self._get_session()

        if not self.session and not (username and password):
            raise cfg_exceptions.InvalidSession()
            
        if self.session and not username:
            test = self.rpc_call('config.test_session', 
                {'session' : self.session})
            if not test:
                raise cfg_exceptions.InvalidSession('Session is either expired or invalid')

        else:
            self.username = username
            self.password = password

            try:
                self.session = self.rpc_call('config.rhn_login', {
                    'username' : self.username,
                    'password' : self.password,
                    })
            except repository.rpclib.Fault, e:
                fault_code, fault_string = e.faultCode, e.faultString
                if fault_code == -2:
                    raise cfg_exceptions.AuthenticationError(
                        "Invalid username or incorrect password")
                raise cfg_exceptions.InvalidSession(fault_code, fault_string)

            self._save_session()

        if not self.session:
            raise cfg_exceptions.InvalidSession
        
        self.assert_repo_health()


    def cleanup(self):
        log_debug(4)
        for file in self.files_to_delete:
            if not os.path.isdir(file):
                os.unlink(file)

    def get_file_info(self, config_channel, repopath, revision=None, auto_delete=1, directory=tempfile.gettempdir()):
        """
        given a namepath, return the filename and the rest of the info passed
        by the server
        """
        log_debug(4)
        params =  {
            'session'           : self.session,
            'config_channel'    : config_channel,
            'path'              : repopath,
        }
        if revision is not None:
            params['revision'] = revision
        try:
            result = self.rpc_call('config.management.get_file', params)
        except repository.rpclib.Fault, e:
            if e.faultCode == -4011:
                # File not present
                raise cfg_exceptions.RepositoryFileMissingError(config_channel,
                    repopath)
            raise e

        fp = file_utils.FileProcessor()
        fullpath, dirs_created = fp.process(result, directory=directory, strict_ownership=0)

        if auto_delete:
            self.files_to_delete.append(fullpath)
        
        del result['file_contents']

        return fullpath, result, dirs_created
    

    def has_file(self, config_channel, repopath):
        params =  {
            'session'           : self.session,
            'config_channel'    : config_channel,
            'path'              : repopath,
        }
        return self.rpc_call('config.management.has_file', params)
        
    def remove_file(self, config_channel, repopath):
        """ remove a given file from the repo """
        log_debug(4)
        params =  {
            'session'           : self.session,
            'config_channel'    : config_channel,
            'path'              : repopath,
        }
        return self.rpc_call('config.management.remove_file', params)

    def put_file(self, config_channel, repopath, localfile=None, 
            is_first_revision=None, old_revision=None, delim_start=None, 
            delim_end=None):
        """
        Insert a given file into the repo, overwriting if necessary.
        localfile defaults to the repopath
        """
        log_debug(4)

        params = self._make_file_info(repopath, localfile,
            delim_start=delim_start, delim_end=delim_end)

        max_file_size = self.get_maximum_file_size()

        if params['size'] > max_file_size:
            error_msg = "%s too large (%s bytes, %s bytes max allowed)"  
            raise cfg_exceptions.ConfigFileTooLargeError(error_msg % (localfile, params['size'], max_file_size))

        params.update({
            'session'           : self.session,
            'config_channel'    : config_channel,
        })
        if is_first_revision:
            params['is_first_revision'] = 1
        elif old_revision:
            params['old_revision'] = int(old_revision)

        try:
            result = self.rpc_call('config.management.put_file', params)
            
        except repository.rpclib.Fault, e:
            fault_code, fault_string = e.faultCode, e.faultString
            
            if is_first_revision and fault_code == -4013:
                raise cfg_exceptions.RepositoryFileExistsError(fault_string)
            
            if old_revision and fault_code == -4012:
                raise cfg_exceptions.RepositoryFileVersionMismatchError(fault_string)
            
            if fault_code == -4003:
                raise cfg_exceptions.ConfigFileTooLargeError(fault_string)
            
            if fault_code == -4014:
                raise cfg_exceptions.QuotaExceeded(fault_string)
            
            raise cfg_exceptions.RepositoryFilePushError(fault_code, fault_string)
        
        return result
    

    def config_channel_exists(self, config_channel):
        log_debug(4, config_channel)
        return (config_channel in self.list_config_channels())
        
    def list_files(self, config_channel, repopath = None, recurse = 1):
        """ 
        list files in a repo, recursing if requested; 
        repopath is not used yet 
        """
        log_debug(4)
        files = self.rpc_call('config.management.list_files',
            {'session' : self.session, 'config_channel' : config_channel})

        return map(lambda p: p['path'], files)

    def get_file_revisions(self, config_channel, repopath):
        """
        Fetch the file's revisions
        """
        log_debug(4)
        params =  {
            'session'           : self.session,
            'config_channel'    : config_channel,
            'path'              : repopath,
        }
        try:
            revisions = self.rpc_call('config.management.list_file_revisions',
                params)
        except repository.rpclib.Fault, e:
            if e.faultCode == -4011:
                # File not present
                raise cfg_exceptions.RepositoryFileMissingError(
                    config_channel, repopath)
            raise e
        return revisions

    def list_config_channels(self):
        "List config channels"
        log_debug(4)
        if hasattr(self, 'config_channels'):
            return self.config_channels
        
        self.config_channels = self.rpc_call(
            'config.management.list_config_channels', {'session' : self.session}
        ) or []

        return self.config_channels
    
    def create_config_channel(self, config_channel):
        "creates a configuration channel"
        log_debug(4, config_channel)
        try:
            return self.rpc_call('config.management.create_config_channel', 
                {'session' : self.session, 'config_channel' : config_channel})
        except repository.rpclib.Fault, e:
            if e.faultCode == -4010:
                raise cfg_exceptions.ConfigChannelAlreadyExistsError(config_channel)
            raise

    def remove_config_channel(self, config_channel):
        "Removes a configuration channel"
        log_debug(4, config_channel)
        try:
            return self.rpc_call('config.management.remove_config_channel', 
                {'session' : self.session, 'config_channel' : config_channel})
        except repository.rpclib.Fault, e:
            if e.faultCode == -4009:
                raise cfg_exceptions.ConfigChannelNotInRepo(config_channel)
            if e.faultCode == -4005:
                raise cfg_exceptions.ConfigChannelNotEmptyError(config_channel)
            raise
    
    def _get_default_delimiters(self):
        "retrieves the default delimiters from the server"
        log_debug(4)
        result = self.rpc_call('config.management.get_default_delimiters',
            {'session'   : self.session})
        return result.get('delim_start'), result.get('delim_end')

    def _get_maximum_file_size(self):
        "get the maximum file size from the server"
        log_debug(4)
        result = self.rpc_call('config.management.get_maximum_file_size',
            {'session'   : self.session})
        return result
    
    def assert_repo_health(self):
        log_debug(4)
        pass
    
    def diff_file_revisions(self, path, config_channel_src, revision_src, 
            config_channel_dst, revision_dst):
        log_debug(4)
        params = {
            'session'           : self.session,
            'path'              : path,
            'config_channel_src': config_channel_src,
            'revision_src'      : revision_src,
        }
        if config_channel_dst is not None:
            params['config_channel_dst'] = config_channel_dst
        if revision_dst is not None:
            params['revision_dst'] = revision_dst
        try:
            ret = self.rpc_call('config.management.diff', params)
        except repository.rpclib.Fault, e:
            if e.faultCode == -4011:
                # File not present
                raise cfg_exceptions.RepositoryFileMissingError(e.faultString)
            if e.faultCode == -4004:
                # Binary file requested
                raise cfg_exceptions.BinaryFileDiffError(e.faultString)
            raise e
        return ret

    def _get_session(self):
        session_path = self._get_session_path()

        try:
            fh = open(session_path, 'r')
            self.session = fh.read()
            fh.close()
        except IOError:
            # session file not there...
            self.session = None

        return self.session

    def _save_session(self):
        if not self.session:
            self._remove_session()

        session_path = self._get_session_path()

        fh = open(session_path, "w+")
        fh.write(self.session)
        fh.close()

    def _remove_session(self):
        p = self._get_session_path()
        try:
            os.unlink(p)
        except OSError:
            pass
        
    def _get_session_path(self):
        return os.path.join(utils.get_home_dir(), self._session_file)

