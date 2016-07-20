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

import base64
from datetime import datetime
import difflib
import os
import sys

from config_common import handler_base, utils, cfg_exceptions
from config_common.rhn_log import log_debug, die
from config_common.file_utils import f_date, ostr_to_sym
from spacewalk.common.usix import next
from rhn.i18n import bstr, sstr


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
             help="Remote file to compare to",
         ),
        handler_base.HandlerBase._option_class(
            '-t', '--topdir',       action="store",
             help="Directory to which all file paths are relative",
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

        files = [utils.normalize_path(x) for x in self.args]
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

    def __attributes_differ(self, fsrc, fdst):
        """ Returns true if acl, ownership, type or selinux context differ.
            fsrc is config file retrieved from xmlrpc, fdst is output of make_stat_info()
        """
        return (fsrc['filemode'] != fdst['mode']) or \
               (fsrc['username'] != fdst['user']) or (fsrc['groupname'] != fdst['group']) or \
               (fsrc['selinux_ctx'] != fdst['selinux_ctx'])

    def diff_file(self, channel, path, local_file, revision):
        r = self.repository
        try:
            info = r.get_raw_file_info(channel, path, revision)
            if 'encoding' in info and info['file_contents']:
                if info['encoding'] == 'base64':
                    info['file_contents'] = base64.decodestring(bstr(info['file_contents']))
                else:
                    die(9, 'Error: unknown encoding %s' % info['encoding'])
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

        response_output = ""
        content_differs = False
        if 'is_binary' in info and info['is_binary'] == 'Y':
            from_content = info['file_contents']
            to_file = open(local_file, 'rb')
            to_content = to_file.read()
            to_file.close()
            if len(from_content) != len(to_content):
                content_differs = True
            else:
                for i in range(len(from_content)):
                    if from_content[i] != to_content[i]:
                         content_differs = True
                         break
            if content_differs:
                response_output = "Binary file content differs\n"
        else:
            fromlines = sstr(info['file_contents']).splitlines(1)
            tofile = open(local_file, 'r')
            tolines = tofile.readlines()
            tofile.close()
            diff_output = difflib.unified_diff(fromlines, tolines, info['path'], local_file)
            first_row = second_row = ''
            try:
                first_row = next(diff_output)
                # if content was same, exception thrown so following
                # lines don't execute
                content_differs = True
                second_row = next(diff_output)
                response_output = ''.join(list(diff_output))
            except StopIteration:
                pass

        file_stat = os.lstat(local_file)
        local_info = r.make_stat_info(local_file, file_stat)
        # rhel4 do not support selinux
        if not 'selinux_ctx' in local_info:
            local_info['selinux_ctx'] = ''
        if 'selinux_ctx' not in info:
            info['selinux_ctx'] = ''
        if not content_differs and not self.__attributes_differ(info, local_info):
            return ""
        else:
            template = "%s %s\t%s\tattributes: %s %s %s %s\tconfig channel: %s\trevision: %s"
            if 'modified' not in info:
                info['modified'] = ''
            first_row = template % ('---', path, str(info['modified']), ostr_to_sym(info['filemode'], info['filetype']),
                        info['username'], info['groupname'], info['selinux_ctx'], channel,
                        info['revision'],
            )
            second_row = template % ('+++', local_file, f_date(datetime.fromtimestamp(local_info['mtime'])), ostr_to_sym(local_info['mode'], 'file'),
                        local_info['user'], local_info['group'], local_info['selinux_ctx'], 'local file', None
            )
        return first_row + '\n' + second_row + '\n' + response_output
