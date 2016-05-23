#
# Copyright (c) 2008--2016 Red Hat, Inc.
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

from config_common.transactions import DeployTransaction, FailedRollback
from config_common import file_utils
from config_common import cfg_exceptions

def deploy_msg_callback(path):
    print("Deploying %s" % path)

def deploy_files(topdir, repository, files, excludes = None, config_channel = None):
    topdir = topdir or os.sep
    if not excludes:
        excludes = []
    dep_trans = DeployTransaction(transaction_root=topdir)
    dep_trans.deploy_callback(deploy_msg_callback)

    for path in files:
        if path in excludes:
            print("Excluding %s" % path)
        else:
            try:
                if config_channel:
                    args = (config_channel, path)
                else:
                    args = (path, )
                kwargs = {'auto_delete': 0, 'dest_directory': topdir}
                finfo = repository.get_file_info(*args, **kwargs)
            except cfg_exceptions.DirectoryEntryIsFile:
                e = sys.exc_info()[1]
                print("Error: unable to deploy directory %s, as it is already a file on disk" % e[0])
                continue

            if finfo is None:
                # File disappeared since we called the function
                continue

            (processed_path, file_info, dirs_created) = finfo
            try:
                dep_trans.add_preprocessed(path, processed_path, file_info, dirs_created)
            except cfg_exceptions.UserNotFound:
                e = sys.exc_info()[1]
                print("Error: unable to deploy file %s, information on user '%s' could not be found." % (path,e[0]))
                continue
            except cfg_exceptions.GroupNotFound:
                e = sys.exc_info()[1]
                print("Error: unable to deploy file %s, information on group '%s' could not be found." % (path, e[0]))
                continue

    try:
        dep_trans.deploy()
    #5/3/05 wregglej - 136415 added missing user exception stuff.
    except cfg_exceptions.UserNotFound:
        e = sys.exc_info()[1]
        try_rollback(dep_trans, "Error unable to deploy file, information on user '%s' could not be found" % e[0])
    except cfg_exceptions.GroupNotFound:
        e = sys.exc_info()[1]
        try_rollback(dep_trans, "Error: unable to deploy file, information on group '%s' could not be found" % e[0])
    except cfg_exceptions.FileEntryIsDirectory:
        e = sys.exc_info()[1]
        try_rollback(dep_trans, "Error: unable to deploy file %s, as it is already a directory on disk" % e[0])
    except cfg_exceptions.DirectoryEntryIsFile:
        e = sys.exc_info()[1]
        try_rollback(dep_trans, "Error: unable to deploy directory %s, as it is already a file on disk" % e[0])
    except Exception:
        try:
            try_rollback(dep_trans, "Deploy failed, rollback successful")
        except:
            print("Failed rollback")
            raise

def try_rollback(dep_trans, msg):
    try:
        dep_trans.rollback()
    except (FailedRollback,
            cfg_exceptions.UserNotFound,
            cfg_exceptions.GroupNotFound):
        pass
    print(msg)
