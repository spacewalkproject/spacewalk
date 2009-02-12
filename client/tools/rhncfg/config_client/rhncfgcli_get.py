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

import os

from config_common import utils, cfg_exceptions
from config_common.rhn_log import log_debug
from config_common.transactions import DeployTransaction, FailedRollback

import handler_base

def deploying_mesg_callback(path):
    print "Deploying %s" % path

class Handler(handler_base.TopdirHandlerBase):
    _usage_options = handler_base.HandlerBase._usage_options + " [ files ... ]"
    def run(self):
        topdir = self.options.topdir or os.sep
        dep_trans = DeployTransaction(transaction_root=topdir)

        dep_trans.deploy_callback(deploying_mesg_callback)

        # Setup the excludes hash
        excludes = {}
        if self.options.exclude is not None:
            for exclude in enumerate(self.options.exclude):
                    excludes[exclude[1]] = None

        for path in self.get_valid_files():

            (directory, filename) = os.path.split(path)
            directory = os.path.normpath("%s%s%s" % (topdir, os.sep, directory))

            try:
                finfo = self.repository.get_file_info(path, auto_delete=0, dest_directory=directory)
            except cfg_exceptions.DirectoryEntryIsFile, e:
                print "Error: unable to deploy directory %s, as it is already a file on disk" % (e[0], )
                continue

            if finfo is None:
                # File disappeared since we called the function
                continue

            (processed_path, file_info, dirs_created) = finfo

            if excludes.has_key(path):
                print "Excluding %s" % path
            else:
                try:
                    dep_trans.add_preprocessed(path, processed_path, file_info, dirs_created)
                except cfg_exceptions.UserNotFound, e:
                    print "Error: unable to deploy file %s, information on user '%s' could not be found." % (path,e[0])
                    continue
                except cfg_exceptions.GroupNotFound, e:
                    print "Error: unable to deploy file %s, information on group '%s' could not be found." % (path, e[0])
                    continue

        try:
            dep_trans.deploy()
        #5/3/05 wregglej - 136415 added missing user exception stuff.
        except cfg_exceptions.UserNotFound, e:
            try:
                dep_trans.rollback()
            except FailedRollback:
                pass
            #5/3/05 wregglej - 136415 Added exception handling for missing user.
            except cfg_exceptions.UserNotFound, f:
                pass
            #5/5/05 wregglej - 136415 Added exception handling for unknown group
            except cfg_exceptions.GroupNotFound, f:
                pass
            print "Error: unable to deploy file %s, information on user '%s' could not be found." % (e[0], f[0])

        except cfg_exceptions.GroupNotFound, e:
            try:
                dep_trans.rollback()
            except FailedRollback:
                pass
            #5/3/05 wregglej - 136415 Added exception handling for missing user.
            except cfg_exceptions.UserNotFound, f:
                pass
            #5/5/05 wregglej - 136415 Added exception handling for unknown group
            except cfg_exceptions.GroupNotFound, f:
                pass
            print "Error: unable to deploy file %s, information on group '%s' could not be found." % (e[0], f[0])

        except cfg_exceptions.FileEntryIsDirectory, e:
            try:
                dep_trans.rollback()
            except FailedRollback:
                pass
            #5/3/05 wregglej - 136415 Added exception handling for missing user.
            except cfg_exceptions.UserNotFound, f:
                pass
            #5/5/05 wregglej - 136415 Added exception handling for missing group
            except cfg_exceptions.GroupNotFound, f:
                pass

            print "Error: unable to deploy file %s, as it is already a directory on disk" % (e[0],)
        except cfg_exceptions.DirectoryEntryIsFile, e:
            try:
                dep_trans.rollback()
            except FailedRollback:
                pass
            #5/3/05 wregglej - 136415 Added exception handling for missin user
            except cfg_exceptions.UserNotFound, f:
                pass
            #5/5/05 wregglej - 136415 Added exception handling for unknown group
            except cfg_exceptions.GroupNotFound, f:
                pass
            print "Error: unable to deploy directory %s, as it is already a file on disk" % (e[0],)
        except Exception:
            try:
                dep_trans.rollback()
            except FailedRollback:
                print "Failed rollback"
            except cfg_exceptions.UserNotFound, f:
                print "Failed rollback due to missing user info"
            #5/5/05 wregglej - 136415 Added exception handling for unknown group
            except cfg_exceptions.GroupNotFound, f:
                pass
                raise
            else:
                print "Deploy failed, rollback successful"
                raise
