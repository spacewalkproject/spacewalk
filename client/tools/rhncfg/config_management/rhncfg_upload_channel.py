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
import string

from config_common import handler_base, utils, cfg_exceptions
from config_common.rhn_log import log_debug, log_error, die

class Handler(handler_base.HandlerBase):
    _usage_options = "[options] [ config_channel ... ]"

    _options_table = handler_base.HandlerBase._options_table + [
        handler_base.HandlerBase._option_class(
            '-t', '--topdir',
            action="store",
            default="./",
             help="Directory all the file paths are relative to",
         ),
        handler_base.HandlerBase._option_class(
            '-c', '--channel',
            action='store',
            default=None,
            help="List of channels the config info will be uploaded into. Channels delimited by ','.\nExample: --channel=foo,bar,baz",
        ),
    ]

    def run(self):
        log_debug(2)
        #5/12/05 wregglej - 149034 changed r into a instance variable
        self.r = self.repository
        
        topdir = self.options.topdir
        if not topdir:
            die(7, "--topdir not specified")
            
        if not os.path.isdir(topdir):
            die(8, "--topdir specified, but `%s' not a directory" %
                topdir)

        topdir = utils.normalize_path(topdir)
       
        #5/12/05 wregglej - 149034 allowing the channel name and the directory name to vary independently.
        if not self.options.channel is None:
            #Get the list of channels with leading and trailing whitespace removed.
            channels = map(string.strip, string.split(self.options.channel,','))

            #Get the list of directories to upload. At this point it's the list of arguments.
            dirs = self.args
        elif not self.args:
            #If we get to this point, then --channel wasn't used and nothing was included as arguments.
            #Assumes that the directories in topdir are the ones we want to upload, and since no channels were
            #specified that each directory is it's own channel.
            channels = os.listdir(topdir)
            dirs = None
            print "No config channels specified, using %s" % channels
        else:
            #At this point, --channel wasn't used but there was something included as an argument.
            #The name of the channel is assumed to be the same as the name of the directory.
            channels = self.args
            dirs = None
        
        #If dirs isn't None, then each directory needs to be uploaded into each channel.
        if dirs: 
            for channel in channels:
                for directory in dirs:
                    self.upload_config_channel(topdir, channel, directory)
        #If dirs is None, then each channel is it's own channel.
        else:
            for channel in channels:
                self.upload_config_channel(topdir, channel, channel)

    def upload_config_channel(self, topdir, channel, directory_name):
        if not self.r.config_channel_exists(channel):
            die(6, "Error: config channel %s does not exist" % channel)

        print "Using config channel %s" % channel

        channel_dir = utils.join_path(topdir, directory_name)

        if not os.path.exists(channel_dir):
            die(6, "Error: channel directory %s does not exist" % channel_dir)
                
        flist = list_files_recursive(channel_dir)

        for (dirname, filenames) in flist:
            assert utils.startswith(dirname, channel_dir)
            remote_dirname = dirname[len(channel_dir):]

            for f in filenames:
                local_file = utils.join_path(dirname, f)
                remote_file = utils.join_path(remote_dirname, f)
                    
                print "Uploading %s from %s" % (remote_file, local_file)
                try:
                    self.r.put_file(channel, remote_file, local_file, is_first_revision=0)
                except cfg_exceptions.RepositoryFilePushError, e:
                    log_error(e)

    
def is_file_or_link(dirname, basename):
    return os.path.isfile(os.path.join(dirname, basename)) or \
                        os.path.islink(os.path.join(dirname, basename))

def list_files_recursive(d):
    def visitfunc(arg, dirname, names):
        arg.append((dirname, filter(lambda x, d=dirname: is_file_or_link(d, x),
            names)))

    file_list = []
    os.path.walk(d, visitfunc, file_list)
    return file_list
