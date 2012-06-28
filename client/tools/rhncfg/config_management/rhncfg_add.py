#
# Copyright (c) 2008--2011 Red Hat, Inc.
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

from config_common import handler_base, utils, cfg_exceptions
from config_common.rhn_log import log_debug, die, log_error

class Handler(handler_base.HandlerBase):
    _usage_options = "[options] file [ file ... ]"

    is_first_revision=1

    _options_table = handler_base.HandlerBase._options_table + [
        handler_base.HandlerBase._option_class(
            '-c', '--channel',      action="store",
             help="Upload files in this config channel",
         ),
        handler_base.HandlerBase._option_class(
            '-d', '--dest-file',    action="store",
             help="Upload the file as this path",
         ),
        handler_base.HandlerBase._option_class(
            '-t', '--topdir',       action="store",
             help="Make all files relative to this string",
         ),
        handler_base.HandlerBase._option_class(
            '--delim-start',        action="store",
             help="Start delimiter for variable interpolation",
         ),
        handler_base.HandlerBase._option_class(
            '--delim-end',          action="store",
             help="End delimiter for variable interpolation",
         ),
        handler_base.HandlerBase._option_class(
            '-i', '--ignore-missing',       action="store_true",
             help="Ignore missing local files",
         ),
        handler_base.HandlerBase._option_class(
            '--selinux-context',       action="store",
             help="Overwrite the SELinux context",
         ),
    ]
                                                    
    def run(self):
        log_debug(2)

        if self.options.dest_file and self.options.topdir:
            die(6, "Error: conflicting options --dest-file and --topdir")

        if len(self.args) == 0:
            die(0, "No files supplied (use --help for help)")

        channel = self.options.channel

        if not channel:
            die(6, "Config channel not specified")

        r = self.repository
        if not r.config_channel_exists(channel):
            die(6, "Error: config channel %s does not exist" % channel)

        files = map(utils.normalize_path, self.args)
        files_to_push = []
        if self.options.dest_file:
            if len(files) != 1:
                die(7, "--dest-file accepts a single file")
	    if not (self.options.dest_file[0] == os.sep):
		die(7, "--dest-file argument must begin with " + os.sep)
            files_to_push.append((files[0], self.options.dest_file)) 
        elif self.options.topdir:
            if not os.path.isdir(self.options.topdir):
                die(8, "--topdir specified, but `%s' not a directory" %
                    self.options.topdir)

            #5/11/05 wregglej - 141790 remove the trailing slash from topdir
            self.options.topdir = utils.rm_trailing_slash(self.options.topdir)

            for f in files:
                if not f.startswith(self.options.topdir):
                    die(8, "--topdir %s specified, but file `%s' doesn't comply"
                        % (self.options.topdir, f))
                files_to_push.append((f, f[len(self.options.topdir):]))
        else:
            for f in files:
		#if a file is given w/o a full path, then use the abspath of the 
		#file as name of the file to be uploaded into the channel
		if not (f[0] == os.sep):
                    files_to_push.append((f, os.path.abspath(f)))
		else: 
                    files_to_push.append((f, f))

        for (local_file, remote_file) in files_to_push:
            if not os.path.exists(local_file):
                if self.options.ignore_missing:
                    files_to_push.remove((local_file,remote_file))
                    print "Local file %s does not exist. Ignoring file..." %(local_file)
                else:
                    die(9, "No such file `%s'" % local_file)

        print "Pushing to channel %s:" % (channel, )

        delim_start = self.options.delim_start
        delim_end = self.options.delim_end

        selinux_ctx = None
        if type(self.options.selinux_context) != None:
            selinux_ctx = self.options.selinux_context
        
        for (local_file, remote_file) in files_to_push:
            try:
                r.put_file(channel, remote_file, local_file, 
                    is_first_revision=self.is_first_revision,
                    delim_start=delim_start,
                    delim_end=delim_end,
                    selinux_ctx=selinux_ctx)
            except cfg_exceptions.RepositoryFileExistsError, e:
                log_error("Error: %s is already in channel %s" %
                          (remote_file, channel))
            except cfg_exceptions.RepositoryFilePushError, e:
                log_error("Error pushing file:  %s" % e)
            else:
                print "Local file %s -> remote file %s" % (local_file, remote_file)
