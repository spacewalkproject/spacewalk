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

import os
import sys

from config_common import handler_base, utils, cfg_exceptions
from config_common.rhn_log import log_debug, die
from config_common.file_utils import diff

class Handler(handler_base.HandlerBase):
    _usage_options = "[options] file [ file ... ]"
    _options_table = [
        handler_base.HandlerBase._option_class(
            '-c', '--channel',    action="store",
             help="Get file(s) from this config channel",
         ),
        handler_base.HandlerBase._option_class(
            '-r', '--revision',     action="store",
             help="Use this revision",
         ),
        handler_base.HandlerBase._option_class(
            '-d', '--dest-file',    action="store",
             help="Upload the file as this path",
         ),
        handler_base.HandlerBase._option_class(
            '-t', '--topdir',       action="store",
             help="Make all files relative to this string",
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

        topdir = self.options.topdir
        revision = self.options.revision

        files_to_diff = []

        files = map(utils.normalize_path, self.args)
        files_count = len(files)

        if files_count != 1 and revision is not None:
            die(8, "--revision can only be used with a single file")

        if self.options.dest_file:
            if files_count != 1:
                die(7, "--dest-file accepts a single file")

            files_to_diff.append((files[0], self.options.dest_file))

        elif topdir:
            if not os.path.isdir(topdir):
                die(8, "--topdir specified, but `%s' not a directory" %
                    topdir)

            #5/11/04 wregglej - 141790 remove trailing slash in topdir, if present.
            topdir = utils.rm_trailing_slash(topdir)

            for f in files:
                if not f.startswith(topdir):
                    die(8, "--topdir %s specified, but file `%s' doesn't comply"
                        % (topdir, f))
                if os.path.isdir(f) and not os.path.islink(f):
                    die(8, "Cannot diff %s; it is a directory" % f)
                files_to_diff.append((f, f[len(topdir):]))
        else:
            for f in files:
                if os.path.isdir(f) and not os.path.islink(f):
                    die(8, "Cannot diff %s; it is a directory" % f)
                files_to_diff.append((f, f))

        for (local_file, remote_file) in files_to_diff:
            sys.stdout.write(
                self.diff_file(channel, remote_file, local_file, revision))


    def diff_file(self, channel, path, local_file, revision):
        r = self.repository
        try:
            #5/11/05 wregglej - 157066 dirs_created is returned by get_file_info, now.
            temp_file, info, dirs_created = r.get_file_info(channel, path, revision=revision)
        except cfg_exceptions.RepositoryFileMissingError:
            die(2, "Error: no such file %s (revision %s) in config channel %s"
                % (path, revision, channel))
        if os.path.islink(local_file) and info['filetype'] != 'symlink' :
             die(8, "Cannot diff %s; the file on the system is a symbolic link while the file in the channel is not. " % local_file)
        if  info['filetype'] == 'symlink' and not os.path.islink(local_file) :
             die(8, "Cannot diff %s; the file on the system is not a symbolic link while the file in the channel is. " % local_file)             
        if info['filetype'] == 'symlink':
            src_link = info['symlink']
            dest_link = os.readlink(local_file)
            if src_link != os.readlink(local_file):
                return "Symbolic links differ. Channel: '%s' -> '%s'   System: '%s' -> '%s' \n " % (path,src_link, path, dest_link) 
            return ""    
        diff_u = diff(temp_file, local_file)

        diff_len = len(diff_u)
        if diff_len == 0:
            return ""
        elif diff_u[0].startswith("---"):
            diff_u[0] = "--- %s\tconfig_channel: %s\trevision: %s\n" % (
                path, channel, info['revision']
            )
        return ''.join(diff_u)
