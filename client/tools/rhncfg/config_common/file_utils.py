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
import stat
import time
import tempfile
import base64
import difflib
try:
    from selinux import lgetfilecon, is_selinux_enabled
except:
    # on rhel4 we do not support selinux
    def lgetfilecon(path):
        return [0, '']
    def is_selinux_enabled():
        return 0

from config_common import utils

class FileProcessor:
    file_struct_fields = {
        'file_contents'     : None,
        'delim_start'       : None,
        'delim_end'         : None,
    }
    def __init__(self):
        pass

    def process(self, file_struct, directory=None, strict_ownership=1):
        # Older servers will not return directories; if filetype is missing,
        # assume file

    	if file_struct.get('filetype') == 'directory':
                file_struct['path'] = directory + file_struct['path']
                return file_struct['path'], []

        if directory:
            directory += os.path.split(file_struct['path'])[0]
        if file_struct.get('filetype') == 'symlink':
            if not file_struct.has_key('symlink'):
                raise Exception, "Missing key symlink"

            (fullpath, dirs_created, fh) = maketemp(prefix=".rhn-cfg-tmp",
                                  directory=directory, symlink=file_struct['symlink'])
            return fullpath, dirs_created

        for k in self.file_struct_fields.keys():
            if not file_struct.has_key(k):
                # XXX
                raise Exception, "Missing key %s" % k

        encoding = ''

        if file_struct.has_key('encoding'):
            encoding = file_struct['encoding']
        
        contents = file_struct['file_contents']

        if contents and (encoding == 'base64'):
            contents = base64.decodestring(contents)
        
        delim_start = file_struct['delim_start']
        delim_end = file_struct['delim_end']

        fh = None        

        (fullpath, dirs_created, fh) = maketemp(prefix=".rhn-cfg-tmp",
                                  directory=directory)

        try:
            fh.write(contents)
        except Exception:
            if fh:
                fh.close()  # don't leak fds...
            raise
        else:
            fh.close()

        return fullpath, dirs_created


    def diff(self, file_struct):
        self._validate_struct(file_struct)

        temp_file, temp_dirs = self.process(file_struct)
        path = file_struct['path']
        sectx_result = ''
        result = ''

        try:
            cur_sectx = lgetfilecon(path)[1]
        except OSError: # workarounding BZ 690238
            cur_sectx = None
        if not is_selinux_enabled():
            cur_sectx = None

        if cur_sectx == None:
            cur_sectx = ''

        if file_struct.has_key('selinux_ctx') and file_struct['selinux_ctx']:
            if cur_sectx != file_struct['selinux_ctx']:
                sectx_result = "SELinux contexts differ:  actual: [%s], expected: [%s]\n" % (cur_sectx, file_struct['selinux_ctx'])

        if file_struct['filetype'] == 'symlink':
            try:
                curlink = os.readlink(path)
                newlink = os.readlink(temp_file)
                if curlink == newlink:
                    result = ''
                else:
                    result = "Link targets differ for [%s]: actual: [%s], expected: [%s]\n" % (path, curlink, newlink)
            except OSError, e:
                if e.errno == 22:
                    result = "Deployed symlink is no longer a symlink!"
                else:
                    raise e
        else:
            result = ''.join(diff(path, temp_file))

        os.unlink(temp_file)
        return sectx_result + result
        
    def _validate_struct(self, file_struct):
        for k in self.file_struct_fields.keys():
            if not file_struct.has_key(k):
                # XXX
                raise Exception, "Missing key %s" % k
        

def diff(src, dst, srcname=None, dstname=None):
    def f_content(path, name):
        if os.access(path, os.R_OK):
            f = open(path, 'U')
            content = f.readlines()
            f.close()
            statinfo = os.stat(path)
            f_time = time.ctime(statinfo.st_mtime)
            if content and content[-1] and content[-1][-1] != "\n":
                content[-1] += "\n"
        else:
            content = []
            f_time = time.ctime(0)
        if not name:
            name = path
        return (content, name, f_time, statinfo)

    (src_content, src_name, src_time, src_stat) = f_content(src, srcname)
    (dst_content, dst_name, dst_time, dst_stat) = f_content(dst, dstname)

    diff_u = difflib.unified_diff(src_content, dst_content,
                                  src_name, dst_name,
                                  src_time, dst_time)

    ret_list = list(diff_u)
    # don't return the diff if the file is not readable by everyone
    # for security reasons.
    if (len(ret_list) > 0 # if differences exist
            and src_stat.st_uid == 0 # and file is owned by root
            and not src_stat.st_mode & stat.S_IROTH): #and not readable by all
        ret_list = [
                "Differences exist in a file that is not readable by all. ",
                "Re-deployment of configuration file is recommended."]
    return ret_list



def maketemp(prefix=None, directory=None, symlink=None):
    """Creates a temporary file (guaranteed to be new), using the
       specified prefix.

       Returns the filename and an open stream
    """
    if not directory:
        directory = tempfile.gettempdir()

    dirs_created = None
    if not os.path.exists(directory):
        dirs_created = utils.mkdir_p(directory)
    
    if not prefix:
    # Create the file in /tmp by default
        prefix = 'rhncfg-tempfile'

    file_prefix = "%s-%s-" % (prefix, os.getpid())
    (fd, filename) = tempfile.mkstemp(prefix=file_prefix, dir=directory)

    if symlink:
        os.unlink(filename)
        os.symlink(symlink, filename)
        open_file = None
    else:
        open_file = os.fdopen(fd, "w+")

    return filename, dirs_created, open_file
