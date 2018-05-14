#
# Copyright (c) 2008--2017 Red Hat, Inc.
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
import stat
import time
import tempfile
import base64
import difflib
import pwd
import grp
try:
    from selinux import lgetfilecon
except:
    # on rhel4 we do not support selinux
    def lgetfilecon(path):
        return [0, '']

from config_common import utils
from config_common.local_config import get as get_config
from rhn.i18n import bstr, sstr


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
            if directory is None:
                directory = ""
            return None, utils.mkdir_p(directory + file_struct['path'])

        if directory:
            directory += os.path.split(file_struct['path'])[0]
        if file_struct.get('filetype') == 'symlink':
            if 'symlink' not in file_struct:
                raise Exception("Missing key symlink")

            (fullpath, dirs_created, fd) = maketemp(prefix=".rhn-cfg-tmp", directory=directory)
            os.close(fd)
            os.unlink(fullpath)
            os.symlink(file_struct['symlink'], fullpath)
            return fullpath, dirs_created

        for k in self.file_struct_fields.keys():
            if k not in file_struct:
                # XXX
                raise Exception("Missing key %s" % k)

        encoding = ''

        if 'encoding' in file_struct:
            encoding = file_struct['encoding']

        contents = file_struct['file_contents']

        if contents and (encoding == 'base64'):
            contents = base64.decodestring(bstr(contents))

        delim_start = file_struct['delim_start']
        delim_end = file_struct['delim_end']

        if ('checksum' in file_struct
                and 'checksum_type' in file_struct
                and 'verify_contents' in file_struct
                and file_struct['verify_contents']):
            if file_struct['checksum'] != utils.getContentChecksum(
                    file_struct['checksum_type'], contents):
                raise Exception("Corrupt file received: Content checksums do not match!")
        elif ('md5sum' in file_struct and 'verify_contents' in file_struct
                and file_struct['verify_contents']):
            if file_struct['md5sum'] != utils.getContentChecksum(
                    'md5', contents):
                raise Exception("Corrupt file received: Content checksums do not match!")
        elif ('verify_contents' in file_struct
                and file_struct['verify_contents']):
            raise Exception("Corrupt file received: missing checksum information!")


        (fullpath, dirs_created, fd) = maketemp(prefix=".rhn-cfg-tmp", directory=directory)

        try:
            os.write(fd, bstr(contents))
        except Exception:
            raise
        finally:
            os.close(fd)

        # try to set mtime and ctime of the file to
        # the last modified time on the server
        if 'modified' in file_struct:
            try:
                modified = xmlrpc_time(file_struct['modified'].value)
                epoch_time = time.mktime(modified)
                os.utime(fullpath, (epoch_time, epoch_time))
            except (ValueError, AttributeError):
                # we can't parse modified time
                pass

        return fullpath, dirs_created


    def diff(self, file_struct):
        self._validate_struct(file_struct)

        temp_file, temp_dirs = self.process(file_struct)
        path = file_struct['path']
        sectx_result = ''
        owner_result = ''
        group_result = ''
        perm_result = ''
        result = ''

        stat_err = 0

        try:
            cur_stat = os.lstat(path)
        except:
            stat_err = 1

        if file_struct['filetype'] != 'symlink':
            if not stat_err:
                 #check for owner differences
                 cur_uid = cur_stat[stat.ST_UID]
                 try:
                     cur_user = pwd.getpwuid(cur_uid)[0]
                 except KeyError:
                     #Orphan UID with no name,return unknown
                     cur_user = "unknown(UID %d)" % (cur_uid,)
            else:
                 cur_user = "missing"

            if cur_user == file_struct['username']:
                 owner_result = ""

            else:
                 owner_result = "User name differ: actual: [%s], expected: [%s]\n" % (cur_user, file_struct['username'])

            if not stat_err:
                #check for group differences
                cur_gid = cur_stat[stat.ST_GID]
                try:
                    cur_group = grp.getgrgid(cur_gid)[0]
                except KeyError:
                    #Orphan GID with no name,return unknown
                    cur_group = "unknown(GID %d)" % (cur_gid,)
            else:
                cur_group = "missing"

            if cur_group == file_struct['groupname']:
                group_result = ""
            else:
                group_result = "Group name differ: actual: [%s], expected: [%s]\n" % (cur_group, file_struct['groupname'])

            #check for permissions differences
            if not stat_err:
                cur_perm = str(oct(stat.S_IMODE(cur_stat[stat.ST_MODE])))
            else:
                cur_perm = "missing"

            #rip off the leading '0' from the mode returned by stat()
            if cur_perm[0] == '0':
                cur_perm = cur_perm[2:] if cur_perm[1] == 'o' else cur_perm[1:]

            #perm_status gets displayed with the verbose option.
            if cur_perm == str(file_struct['filemode']):
                perm_result = ""
            else:
                perm_result = "File mode differ: actual: [%s], expected: [%s]\n" % (cur_perm, file_struct['filemode'])

        try:
            cur_sectx = lgetfilecon(path)[1]
        except OSError: # workarounding BZ 690238
            cur_sectx = None

        if cur_sectx == None:
            cur_sectx = ''

        if 'selinux_ctx' in file_struct and file_struct['selinux_ctx']:
            if cur_sectx != file_struct['selinux_ctx']:
                sectx_result = "SELinux contexts differ:  actual: [%s], expected: [%s]\n" % (cur_sectx, file_struct['selinux_ctx'])

        if file_struct['filetype'] == 'directory':
            if os.path.isdir(file_struct['path']):
                result = ''
            else:
                result = "Deployed directory is no longer a directory!"
        elif file_struct['filetype'] == 'symlink':
            try:
                curlink = os.readlink(path)
                newlink = os.readlink(temp_file)
                if curlink == newlink:
                    result = ''
                else:
                    result = "Link targets differ for [%s]: actual: [%s], expected: [%s]\n" % (path, curlink, newlink)
            except OSError:
                e = sys.exc_info()[1]
                if e.errno == 22:
                    result = "Deployed symlink is no longer a symlink!"
                else:
                    raise e
        else:
            result = ''.join(diff(temp_file, path,
                    display_diff=get_config('display_diff')))

        if temp_file:
            os.unlink(temp_file)
        return owner_result + group_result + perm_result + sectx_result + result

    def _validate_struct(self, file_struct):
        for k in self.file_struct_fields.keys():
            if k not in file_struct:
                # XXX
                raise Exception("Missing key %s" % k)


def diff(src, dst, srcname=None, dstname=None, display_diff=False):
    def f_content(path, name):
        statinfo = None
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
            and not display_diff # and we have not explicitly decided to display
            and (dst_stat == None # file is not there or not readable to root
                or (dst_stat.st_uid == 0 # file is owned by root
                    and not dst_stat.st_mode & stat.S_IROTH))): # not read-all
        ret_list = [
                "Differences exist in a file %s that is not readable by all. " % dst,
                "Re-deployment of configuration file is recommended.\n"]
    return ret_list



def maketemp(prefix=None, directory=None):
    """Creates a temporary file (guaranteed to be new), using the
       specified prefix.

       Returns the filename and a file descriptor
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

    return filename, dirs_created, fd


# Duplicated from backend/common/fileutils.py to remove dependency requirement.
# If making changes make them there too.
FILETYPE2CHAR = {
    'file'      : '-',
    'directory' : 'd',
    'symlink'   : 'l',
    'chardev'   : 'c',
    'blockdev'  : 'b',
}

# Duplicated from backend/common/fileutils.py to remove dependency requirement.
# If making changes make them there too.
def _ifelse(cond, thenval, elseval):
    if cond:
        return thenval
    else:
        return elseval

# Duplicated from backend/common/fileutils.py to remove dependency requirement.
# If making changes make them there too.
def ostr_to_sym(octstr, ftype):
    """ Convert filemode in octets (like '644') to string like "ls -l" ("-rwxrw-rw-")
        ftype is one of: file, directory, symlink, chardev, blockdev.
    """
    mode = int(str(octstr), 8)

    symstr = FILETYPE2CHAR.get(ftype, '?')

    symstr += _ifelse(mode & stat.S_IRUSR, 'r', '-')
    symstr += _ifelse(mode & stat.S_IWUSR, 'w', '-')
    symstr += _ifelse(mode & stat.S_IXUSR,
                      _ifelse(mode & stat.S_ISUID, 's', 'x'),
                      _ifelse(mode & stat.S_ISUID, 'S', '-'))
    symstr += _ifelse(mode & stat.S_IRGRP, 'r', '-')
    symstr += _ifelse(mode & stat.S_IWGRP, 'w', '-')
    symstr += _ifelse(mode & stat.S_IXGRP,
                      _ifelse(mode & stat.S_ISGID, 's', 'x'),
                      _ifelse(mode & stat.S_ISGID, 'S', '-'))
    symstr += _ifelse(mode & stat.S_IROTH, 'r', '-')
    symstr += _ifelse(mode & stat.S_IWOTH, 'w', '-')
    symstr += _ifelse(mode & stat.S_IXOTH,
                      _ifelse(mode & stat.S_ISVTX, 't', 'x'),
                      _ifelse(mode & stat.S_ISVTX, 'T', '-'))
    return symstr

# Duplicated from backend/common/fileutils.py to remove dependency requirement.
# If making changes make them there too.
def f_date(dbiDate):
    return "%04d-%02d-%02d %02d:%02d:%02d" % (dbiDate.year, dbiDate.month,
        dbiDate.day, dbiDate.hour, dbiDate.minute, dbiDate.second)

def xmlrpc_time(xtime):
    if xtime[8] == 'T':
        # oracle backend: 20130304T23:19:17
        timefmt='%Y%m%dT%H:%M:%S'
    else:
        # postresql backend format: 2014-02-28 18:47:31.506953+01:00
        timefmt='%Y-%m-%d %H:%M:%S'
        xtime = xtime[:19]

    return time.strptime(xtime, timefmt)
