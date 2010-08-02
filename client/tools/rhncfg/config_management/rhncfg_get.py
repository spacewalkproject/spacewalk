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

from config_common import handler_base, utils, cfg_exceptions
from config_common.rhn_log import log_debug, die
from config_common.transactions import DeployTransaction, FailedRollback

def deploying_mesg_callback(path):
    print "Deploying %s" % path


class Handler(handler_base.HandlerBase):
    _usage_options = "[options] file [ file ... ]"

    _options_table = handler_base.HandlerBase._options_table + [
        handler_base.HandlerBase._option_class(
            '-c', '--channel',      action="store",
             help="Get file(s) from this config channel",
         ),
        handler_base.HandlerBase._option_class(
            '-t', '--topdir',       action="store",
             help="Make all files relative to this string",
         ),
        handler_base.HandlerBase._option_class(
            '-r', '--revision',    action="store",
             help="Get this file revision",
         ),
    ]
                                                    
    def run(self):
        log_debug(2)
        r = self.repository

        channel = self.options.channel
        if not channel:
            die(6, "Config channel not specified")

        topdir = self.options.topdir
        if topdir:
            if not os.path.isdir(self.options.topdir):
                die(8, "--topdir specified, but `%s' not a directory" %
                    self.options.topdir)

        if not self.args:
            die(7, "No files specified")

        revision = self.options.revision
        if revision:
            if len(self.args) > 1:
                die(9, "--revision specified with multiple files")

        dep_trans = None

        if topdir:
            dep_trans = DeployTransaction(transaction_root=topdir)
            dep_trans.deploy_callback(deploying_mesg_callback)

        for f in self.args:
            try:
                directory = topdir or tempfile.gettempdir()
                
                dest = utils.join_path(directory, f)
                (dest_dir, dest_file) = os.path.split(dest)

                #5/11/05 wregglej - 157066 dirs_created is returned from get_file_info.
                (temp_file, info, dirs_created) = r.get_file_info(channel, f, revision=revision,
                                                    auto_delete=0, directory=dest_dir)
                
            except cfg_exceptions.RepositoryFileMissingError:
                if revision is not None:
                    die(2, "Error: file %s (revision %s) not in config "
                        "channel %s" % (f, revision, channel))
                else:
                    die(2, "Error: file %s not in config channel %s" % 
                        (f, channel))

            if topdir:
                #5/11/05 wregglej - 157066 dirs_created now gets passed into add_preprocessed.
                dep_trans.add_preprocessed(f, temp_file, info, dirs_created, strict_ownership=0)
                continue
            elif info.get('filetype') == 'symlink':
                print "%s -> %s" % (info['path'], info['symlink'])
                continue            
            elif info.get('filetype') == 'directory':
                print "%s is a directory entry, nothing to get" % info['path']
                continue
            else:
                print open(temp_file).read()
                os.unlink(temp_file)

        if topdir:
            try:
                dep_trans.deploy()
            except Exception, e:
                try:
                    dep_trans.rollback()
                except FailedRollback, e2:
                    raise "FAILED ROLLBACK:  ", e2
                #5/3/05 wregglej - 136415 Added exception stuff for missing user info.
                except cfg_exceptions.UserNotFound, f:
                    raise f
                #5/5/05 wregglej - 136415 Added exception handling for unknown group.
                except cfg_exceptions.GroupNotFound, f:
                    raise f
                else:
                    raise "Deploy failed, rollback successful:  ", e
            

