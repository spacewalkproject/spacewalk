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
import time

from config_common import local_config, file_utils, utils, repository, cfg_exceptions
from config_common.rhn_log import set_debug_level, get_debug_level, set_logfile, log_to_file
from config_common.transactions import DeployTransaction, FailedRollback

from config_client import rpc_cli_repository

from string import split

# this is a list of the methods that get exported by a module
__rhnexport__ = [
    'mtime_upload',
    'upload',
    'deploy',
    'verify',
    'diff',
]


# action version we understand
ACTION_VERSION = 2

# when we do this within up2date, should just have something like
# __rhn_require_local_permission__ that flags the methods requiring the touched
# file
_permission_root_dir = '/etc/sysconfig/rhn/allowed-actions'
def _local_permission_check(action_type):
    # action_type ala configfiles.deploy
    atype_structure = split(action_type, '.')

    for i in range(len(atype_structure)):
        all_structure = atype_structure[:i]
        all_structure.append('all')

        potential_all_path = apply(os.path.join, all_structure)
        if os.path.exists(os.path.join(_permission_root_dir, potential_all_path)):
            return 1
    
    action_path = apply(os.path.join, atype_structure)
    return os.path.exists(os.path.join(_permission_root_dir, action_path))

def _perm_error(action_type):
    return (42, "Local permission not set for action type %s" % action_type, {})


def _visit_dir(params, dirname, names):

    matches = params['matches']
    info = params['info']
    ignore_dirs = params['ignore']
    now = params['now']
    
    i = 0
    while i < len(names):
        full_path = os.path.join(dirname, names[i])
        is_dir = os.path.isdir(full_path)
        
        if is_dir:
            if ignore_dirs.has_key(full_path):
                # don't consider the entire subtree on subsequent runs of
                # visit
                del names[i]
            else:
                i = i + 1
            # since we can have multiple search paths hitting the same subdir,
            # filter 'em out after the first pass
            ignore_dirs[full_path] = None
            continue

        if not os.path.exists(full_path):
            i = i + 1
            continue
        
        mtime = os.path.getmtime(full_path)

        # do it via delta...
        if (now - mtime) <= (info['now'] - info['start_date']):
            if info['end_date']:
                if (now - mtime) >= (info['now'] - info['end_date']):
                    matches.append(full_path)
            else:
                matches.append(full_path)

        i = i + 1


def format_result(result, files):
    files_too_large = result.get('files_too_large') or []
    quota_failed = result.get('failed_due_to_quota') or []
    missing_files = result.get('missing_files') or []

    extras = { 'attempted_paths' : files }

    if missing_files:
        extras['missing_files'] = missing_files
    if files_too_large:
        extras['files_too_large'] = files_too_large
    if quota_failed:
        extras['quota_failed'] = quota_failed

    num_files = len(files)
    num_uploaded = num_files - (len(missing_files) + len(files_too_large) + len(quota_failed))

    if num_uploaded == num_files:
        return 0, "All files successfully uploaded", extras
    else:
        return -1, "Some files failed to upload", extras


##     foo = {'ignore': ['\n', '/home/bretm/rhn/build/', '/home/bretm/rhn/sql'],
##            'info': {'now': 1071722611.0, 'import_contents': 'N', 'start_date': 1071290580.0, 'end_date': ''},
##            'search': ['/home/bretm/'],
##            }
def mtime_upload(action_id, params, cache_only=None):
    if cache_only:
        return (0, "no-ops for caching", {})

    action_type = 'configfiles.mtime_upload'
    if not _local_permission_check(action_type):
        log_to_file(0, "permissions error: " + str(action_type))
        return _perm_error(action_type)
        
    _init()

    file_matches = []
    now = time.time()
    upload_contents = None
    ignore_dirs = {'/proc':None, '/dev':None}

    if params['info']['import_contents'] == 'Y':
        upload_contents = 1

    for to_ignore in params['ignore']:
        ignore_dirs[utils.normalize_path(to_ignore)] = 1

    for search_path in params['search']:
        os.path.walk(utils.normalize_path(search_path), _visit_dir, {
            'matches' : file_matches,
            'info' : params['info'],
            'ignore' : ignore_dirs,
            'now' : now,
            })

    if not file_matches:
        return 0, "No files found", {}

    r = rpc_cli_repository.ClientRepository()
    result = r.put_files(action_id, file_matches, upload_contents=upload_contents)
    
    formatted_result = format_result(result, file_matches)
    log_to_file(0, formatted_result)
    return formatted_result


def upload(action_id, params, cache_only=None):
    if cache_only:
        return (0, "no-ops for caching", {})

    action_type = 'configfiles.upload'
    if not _local_permission_check(action_type):
        log_to_file(0, "permissions error: " + str(action_type))
        return _perm_error(action_type)
        
    _init()

    files = params or []

    r = rpc_cli_repository.ClientRepository()
    result = r.put_files(action_id, files)

    formatted_result = format_result(result, files)
    log_to_file(0, formatted_result)

    return formatted_result


def deploy(params, topdir=None, cache_only=None):
    if cache_only:
        return (0, "no-ops for caching", {})

    action_type = 'configfiles.deploy'
    if not _local_permission_check(action_type):
        log_to_file(0, "permissions error: " + str(action_type))
        return _perm_error(action_type)

    _init()
    files = params.get('files') or []
    dep_trans = DeployTransaction(transaction_root=topdir, auto_rollback=0)
    
    for file in files:
        dep_trans.add(file)

    try:
        dep_trans.deploy()
    #5/3/05 wregglej - 135415 Adding stuff for missing user info
    except cfg_exceptions.UserNotFound, e:
            try:
                dep_trans.rollback()    
            except FailedRollback:
                log_to_file(0, "Failed deployment and rollback, information on user '%s' could not be found" % (e[0], ))
                return (44, "Failed deployment and rollback, information on user '%s' could not be found" % (e[0], ), {})
            #5/3/05 wregglej - 136415 Adding some more exceptions to handle
            except cfg_exceptions.UserNotFound, f:
                log_to_file(0, "Failed deployment and rollback, information on user '%s' could not be found" % (f[0], ))
                return (50, "Failed deployment and rollback, information on user '%s' could not be found" % (f[0], ), {})
            #5/5/05 wregglej - 136415 Adding exception handling for unknown group,
            except cfg_exceptions.GroupNotFound, f:
                log_to_file(0, "Failed deployment and rollback, group '%s' could not be found" % (f[0],))
                return (51, "Failed deployment and rollback, group '%s' could not be found" % (f[0],), {})
            else:
                log_to_file(0, "Failed deployment and rollback, information on user '%s' could not be found" % (e[0], ))
                return (50, "Failed deployment and rollback, information on user '%s' could not be found" % (e[0], ), {})
    except cfg_exceptions.GroupNotFound, e:
            try:
                dep_trans.rollback()
            except FailedRollback:
                log_to_file(0, "Failed deployment and rollback, information on user '%s' could not be found" % (e[0], ))
                return (44, "Failed deployment and rollback, information on user '%s' could not be found" % (e[0], ), {})
            #5/3/05 wregglej - 136415 Adding some more exceptions to handle
            except cfg_exceptions.UserNotFound, f:
                log_to_file(0, "Failed deployment and rollback, information on user '%s' could not be found" % (f[0], ) )
                return (50, "Failed deployment and rollback, information on user '%s' could not be found" % (f[0], ), {})
            #5/5/05 wregglej - 136415 Adding exception handling for unknown group,
            except cfg_exceptions.GroupNotFound, f:
                log_to_file(0, "Failed deployment and rollback, group '%s' could not be found" % (f[0],))
                return (51, "Failed deployment and rollback, group '%s' could not be found" % (f[0],), {})
            else:
                log_to_file(0, "Failed deployment and rollback, group '%s' could not be found" % (e[0], ))
                return (51, "Failed deployment and rollback, group '%s' could not be found" % (e[0], ), {})
    except cfg_exceptions.FileEntryIsDirectory, e:
            try:
                dep_trans.rollback()
            except FailedRollback:
                log_to_file(0, "Failed deployment and rollback, %s already exists as a directory" % (e[0], ))
                return (44, "Failed deployment and rollback, %s already exists as a directory" % (e[0], ), {})
            #5/3/05 wregglej - 136415 Adding some more exceptions to handle
            except cfg_exceptions.UserNotFound, f:
                log_to_file(0, "Failed deployment and rollback, information on user '%s' could not be found" % (f[0], ))
                return (50, "Failed deployment and rollback, information on user '%s' could not be found" % (f[0], ), {})
            #5/5/05 wregglej - 136415 Adding exception handling for unknown group,
            except cfg_exceptions.GroupNotFound, f:
                log_to_file(0, "Failed deployment and rollback, group '%s' could not be found" % (f[0],))
                return (51, "Failed deployment and rollback, group '%s' could not be found" % (f[0],), {})
            else:
                log_to_file(0, "Failed deployment, %s already exists as a directory" % (e[0], ))
                return (45, "Failed deployment, %s already exists as a directory" % (e[0], ), {})
    except cfg_exceptions.DirectoryEntryIsFile, e:
            try:
                dep_trans.rollback()
            except FailedRollback:
                log_to_file(0, "Failed deployment and rollback, %s already exists as a file" % (e[0], ))
                return (46, "Failed deployment and rollback, %s already exists as a file" % (e[0], ), {})
            #5/3/05 wregglej - 136415 Adding exceptions for missing user
            except cfg_exceptions.UserNotFound, f:
                log_to_file(0, "Failed deployment and rollback, information on user '%s' could not be found" % (f[0], ))
                return (50, "Failed deployment and rollback, information on user '%s' could not be found" % (f[0], ), {})
            #5/5/05 wregglej - 136415 Adding exception handling for unknown group,
            except cfg_exceptions.GroupNotFound, f:
                log_to_file(0, "Failed deployment and rollback, group '%s' could not be found" % (f[0],))
                return (51, "Failed deployment and rollback, group '%s' could not be found" % (f[0],), {})
            else:
                log_to_file(0, "Failed deployment, %s already exists as a file" % (e[0], ))
                return (47, "Failed deployment, %s already exists as a file" % (e[0], ), {})

    except Exception, e:
        print e
        try:
            dep_trans.rollback()
        except FailedRollback, e2:
            log_to_file(0, "Failed deployment, failed rollback:  %s" % e2)
            return (48, "Failed deployment, failed rollback:  %s" % e2, {})
        #5/3/05 wregglej - 135415 Add exception handling for missing user.
        except cfg_exceptions.UserNotFound, f:
            log_to_file(0, "Failed deployment and rollback, information on user '%s' could not be found" % (f[0]))
            return (50, "Failed deployment and rollback, information on user '%s' could not be found" % (f[0]), {})
        #5/5/05 wregglej - 136415 Adding exception handling for unknown group,
        except cfg_exceptions.GroupNotFound, f:
            log_to_file(0, "Failed deployment and rollback, group '%s' could not be found" % (f[0],))
            return (51, "Failed deployment and rollback, group '%s' could not be found" % (f[0],), {})
        else:
            log_to_file(0, "Failed deployment, rolled back:  %s" % e)
            return (49, "Failed deployment, rolled back:  %s" % e, {})

    extras = {}
    log_to_file(0, "Files successfully deployed: %s %s" % (format_file_string(files, create_key_list()), str(extras)))
    return 0, "Files successfully deployed", extras


def diff(params, cache_only=None):
    if cache_only:
        return (0, "no-ops for caching", {})

    action_type = 'configfiles.diff'
    if not _local_permission_check(action_type):
        log_to_file(0, "permissions error: " + str(action_type))
        return _perm_error(action_type)

    _init()
    files = params.get('files') or []
    fp = file_utils.FileProcessor()
    missing_files = []
    diffs = {}
    exists = hasattr(os.path, 'lexists') and os.path.lexists or os.path.exists
    for file in files:
        path = file['path']
        if not exists(path):
            missing_files.append(path)
            continue
        if os.path.isdir(path):
            # We dont support dir diffs, ignore
            continue

        diff = fp.diff(file)
        diffs[path] = diff

    extras = {}
    if missing_files:
        extras['missing_files'] = missing_files
    
    if diffs:
        extras['diffs'] = diffs

    log_to_file(0, "Files successfully diffed: %s %s" % (format_file_string(files, create_key_list()), str(extras)))
    return 0, "Files successfully diffed", extras

verify = diff

#The format_file_string and create_key_list functions can be used together to create a string
#containing information about the files in file_list. Use sparingly.

#file_list is a list of dictionaries containing file information.
#keylist is a list of strings containing the keys of the information in file_list that you wish to print out.
def format_file_string(file_list, keylist):
    outstr = ""
    for afile in file_list:
        outstr
        for key in keylist:
            formatstr = "\n%s: %s"
            if key in afile:
                outstr = outstr + formatstr % (key, afile[key])
        outstr = outstr + "\n"
    return outstr

#Returns a list of strings. Each string is a key in the dictionary containing file information.
#The number of keys returned corresponds to the debug_level. The higher the debug_level, the longer the 
#list of keys.
def create_key_list():
    #The list of keys. The order of the keys determines what debug_level they will be returned in.
    #For example, at debug level 0 only the path and revision will be included. At level 1, the path, revision,
    #config_channel, and filemode keys should be included.
    key_list = [
                    'path',
                    'revision',
                    'config_channel',
                    'filemode',
                    'filetype',
                    'encoding',
                    'username',
                    'groupname',
                    'delim_start',
                    'delim_end',
                    'md5sum',
                    'checksum_type',
                    'checksum',
                    'file_contents',
                ]
    #This dictionary associates each debug level (the key) with the index into key_list (the value) at which
    #we should stop including keys in the returned list.
    debug_levels = {
                        0 : 2,
                        1 : 4,
                        2 : 6,
                        3 : 8,
                        4 : 10,
                        5 : 14,
                   }
    curr_debug = get_debug_level()
    if curr_debug > 5:
        curr_debug = 5
    if curr_debug < 0:
        curr_debug = 0
    if not curr_debug in debug_levels.keys():
        curr_debug = 0
    return key_list[:debug_levels[curr_debug]]

def _init():
    up2date_config = utils.get_up2date_config()
    local_config.init('rhncfg-client', defaults=up2date_config)
    set_debug_level(int(local_config.get('debug_level') or 0))
    set_logfile("/var/log/rhncfg-actions")

    
