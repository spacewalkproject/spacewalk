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
import sys

from config_common import local_config, cfg_exceptions, file_utils, \
    repository
from config_common.rhn_rpc import rpclib
from config_common.rhn_log import log_debug

import traceback

class ClientRepository(repository.RPC_Repository):
    
    default_systemid = "/etc/sysconfig/rhn/systemid"
    
    # bug #170825,169203: reusing the base class's default value for setup_network
    def __init__(self, setup_network=1):
        repository.RPC_Repository.__init__(self, setup_network)
            
        systemid_file = local_config.get("systemid") or self.default_systemid
        try:
            f = open(systemid_file, "r")
        except IOError, e:
            sys.stderr.write("Cannot open %s: %s\n" % (systemid_file, e))
            sys.exit(1)
            
        self.system_id = f.read()
        f.close()

        log_debug(4, 'system id', self.system_id)

        self.files_to_delete = []
    
    def rpc_call(self, method_name, *params):
        try:
            result = apply(repository.RPC_Repository.rpc_call, 
                (self, method_name) + params)
        except rpclib.Fault, e:
            if e.faultCode == -9:
                # System not subscribed
                raise cfg_exceptions.AuthenticationError(
                    "Invalid digital server certificate%s" % e.faultString)
            raise
        return result

    def load_config_channels(self):
        log_debug(4)
        self.config_channels = self.rpc_call(
            'config.client.list_config_channels', self.system_id)
        return self.config_channels

    def list_files(self):
        log_debug(4)
        return self.rpc_call('config.client.list_files', self.system_id)

    def get_file_info(self, file, auto_delete=1, dest_directory=None):
        log_debug(4, file)
        result = self.rpc_call('config.client.get_file', self.system_id, file)

        if result.has_key('missing'):
            return None

        dirs_created = None

        # Older servers will not return directories; if filetype is missing,
        # assume file
        if result.get('filetype') == 'directory':
            if os.path.isfile(result['path']):
                raise cfg_exceptions.DirectoryEntryIsFile(result['path'])
            else:
                auto_delete = 0
                temp_file = result['path']
        else:
            f = file_utils.FileProcessor()
            temp_file, dirs_created = f.process(result, directory=dest_directory)

        if auto_delete:
            self.files_to_delete.append(temp_file)

        return temp_file, result, dirs_created

    def put_files(self, action_id, files, upload_contents=1):
        """Inserts a set of files into the repo, as a result of a scheduled 
        action"""
        log_debug(4)
        missing_files = []
        files_too_large = []
        failed_due_to_quota = []

        max_file_size = self.get_maximum_file_size()
        
        for file in files:
            try:
                params = self._make_file_info(file, local_path=None,
                    load_contents=upload_contents)
            except cfg_exceptions.RepositoryLocalFileError:
                missing_files.append(file)
                continue

            if upload_contents and (params['size'] > max_file_size):
                files_too_large.append(file)
                continue

            try:
                self.rpc_call('config.client.upload_file',
                    self.system_id, action_id, params)
            except repository.rpclib.Fault, e:
                fault_code, fault_string = e.faultCode, e.faultString
                # deal with particular faults
                if fault_code == -4003:
                    # File too large
                    files_too_large.append(file)
                elif fault_code == -4014:
                    # Ran out of org quota space
                    failed_due_to_quota.append(file)
                else:
                    raise cfg_exceptions.RepositoryFilePushError(fault_code,
                        fault_string)
            except Exception:
                traceback.print_exc()
                raise

        result = {}
        # If there are files too large to be pushed, result will have a key
        # `file_too_large'
        if len(files_too_large) > 0:
            result['files_too_large'] = files_too_large

        if len(failed_due_to_quota) > 0:
            result['failed_due_to_quota'] = failed_due_to_quota

        if len(missing_files) > 0:
            result['missing_files'] = missing_files

        return result


    def list_config_channels(self):
        log_debug(4)
        return self.config_channels

    def _get_default_delimiters(self):
        "retrieves the default delimiters from the server"
        log_debug(4)
        result = self.rpc_call('config.client.get_default_delimiters', 
            self.system_id)
        return result.get('delim_start'), result.get('delim_end')

    def _get_maximum_file_size(self):
        log_debug(4)
        result = self.rpc_call('config.client.get_maximum_file_size', 
            self.system_id)
        return result

    def cleanup(self):
        log_debug(4)
        for file in self.files_to_delete:
            os.unlink(file)
