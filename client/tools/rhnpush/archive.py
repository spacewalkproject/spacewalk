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

"""Archive Parsing module"""

import os
import subprocess
import shutil
import sys
import tempfile
import time
import zipfile
import select

# exceptions -------------------------------------------------------------

class ArchiveException(Exception):
    pass

class DecompressionError(ArchiveException):
    pass

class UnknownArchiveError(ArchiveException):
    pass

class InvalidArchiveError(ArchiveException):
    pass

# base archive parsing class ---------------------------------------------

class ArchiveParser(object):
    """Explode an zip or (compressed) tar archive and parse files and
    directories contained therein"""

    # constructor --------------------------------------------------------

    def __init__(self, archive, tempdir="/tmp/"):
        """Initialize an archive parser"""
        assert os.path.exists(archive)

        self._archive = archive
        self._archive_dir = None

        # bug 164756: allow optional working directory
        self._parent_dir = tempdir

        # bug: 171086: support for older versions of tempfile (ie python 2.2)
        tempfile.tempdir = tempdir
        self._temp_dir = tempfile.mktemp()
        os.mkdir(self._temp_dir, 0700)

        self._explode(archive)

    # destructor ---------------------------------------------------------

    def __del__(self):
        """Cleanup temporary files and directories"""

        if hasattr(self, "_temp_dir") and os.path.isdir(self._temp_dir):
            shutil.rmtree(self._temp_dir, ignore_errors=True)

    # methods called by constructor --------------------------------------

    def _get_archive_dir(self):
        """[internal] find the archive's top level directory name"""

        raise NotImplementedError("ArchiveParser: abstract base class method '_get_archive_dir'")


    def _explode_cmd(self):
        """[internal] find the appropriate command to open the archive"""

        raise NotImplementedError("ArchiveParser: abstract base class method '_explode_cmd'")

    def _explode(self, archive):
        """[internal] Explode a archive for neutral parsing"""

        cmd = self._explode_cmd()

        assert self._archive is not None        # assigned in _copy_archive
        assert self._archive_dir is not None    # assigned in _explode_cmd

        if cmd:
#            if __debug__: print "DEBUG: running command: %s" % cmd
            status = _my_popen(cmd)

#            if __debug__: print "DEBUG: testing for %s" % self._archive_dir
            if os.path.isdir(self._archive_dir):
                return

            raise InvalidArchiveError("Archive did not expand to %s" % self._archive_dir)

        raise InvalidArchiveError("Could not find command to open archive: %s" % self._archive)

    # private helper methods ---------------------------------------------

    def _find(self, file):
        """[internal] Returns the absolute path to a file in the archive"""

        file_path = None
        contents = os.listdir(self._archive_dir)

        while contents:
            entry = contents.pop()
            path = os.path.join(self._archive_dir, entry)

            if os.path.isdir(path):
                p_contents = os.listdir(path)
                e_contents = [os.path.join(entry, e) for e in p_contents]
                # this really is something of a hack, the newest contents will 
                # 'prepended' to the queue instead of 'appended' changing the 
                # search into depth-first when I think breadth-first would be 
                # the expected behavior
                # that's what we get for programming in python which doesn't 
                # supply a nice way of adding real data-structure support
                # I already tried extending e_contents with contents and then 
                # reassigning the contents reference to e_contents, but the 
                # damn while loop still had a hold of the original reference
                contents.extend(e_contents)
            else:
                if entry.endswith(file):
                    file_path = os.path.join(os.path.abspath(self._archive_dir), entry)
                    assert os.path.isfile(file_path), "[_find] invalid path: %s" % file_path
                    break

        else:
#            if __degug__: sys.stderr.write("[_find] '%s' not found\n" % file)
            pass

        return file_path

    # public api ---------------------------------------------------------

    def list(self, prefix=""):
        """Return a tuple of directories and files in the archive at the given
        directory: prefix"""

        dir = os.path.join(self._archive_dir, prefix)
        assert os.path.isdir(dir)

        l = os.listdir(dir)

        d = []
        f = []

        for i in l:
            if os.path.isdir(os.path.join(dir, i)):
                d.append(i)
            else:
                f.append(i)

        if __debug__:
            d.sort()
            f.sort()

        return (d, f)

    def contains(self, file):
        """Returns true iff the file is contained in the archive"""
        return self._find(file) is not None

    def read(self, file):
        """Returns the contents of the file, or None on error"""

        f = self._find(file) or ''
        contents = None

        if os.path.isfile(f) and os.access(f, os.R_OK):
            try:
                fd = open(f)
                contents = fd.read()
                fd.close()
            except Exception:
                contents = None

        return contents

    def zip(self, prefix=""):
        """Create a zip archive of a (sub-)directory of the archive"""
#        if __debug__: print "DEBUG: creating zip file for %s" % dir

        dir = os.path.join(self._archive_dir, prefix)
        zip_dir = os.path.basename(dir)
        parent_dir = os.path.dirname(dir)

        cwd = os.getcwd()
        os.chdir(parent_dir)

        zip_file = os.path.join(self._parent_dir, "%s.zip" % zip_dir)

        cmd = "zip -q -r %s %s" % (zip_file, prefix)
        stat = _my_popen(cmd)

        os.chdir(cwd)

        if os.path.isfile(zip_file):
            return zip_file

        return None

    def cpio(self, prefix):
        """Create a cpio archive of a (sub-)directory of the archive"""
#        if __debug__: print "DEBUG: creating cpio archive file for %s" % prefix

        cpio_file = os.path.join(self._temp_dir, "%s.pkg" % prefix)

        cmd = "pkgtrans -s %s %s %s" % (self._archive_dir, cpio_file, prefix)
        stat = _my_popen(cmd)

        if os.path.isfile(cpio_file):
            return cpio_file

        return None

# parser for zip archives ------------------------------------------------

class ZipParser(ArchiveParser):

    def _get_archive_dir(self):
        list_cmd = "unzip -l %s" % (self._archive,)
        return os.popen(list_cmd).readlines()[3].split()[3][:-1]

    def _explode_cmd(self):
        """Return the appropriate command for exploding a zip archive"""

        if not _has_executable("unzip"):
            raise ArchiveException("cannot open %s, 'unzip' not found" % self._archive)

        self._archive_dir = os.path.join(self._temp_dir, self._get_archive_dir())

        return "unzip -q -n %s -d %s" % (self._archive, self._temp_dir)

# parser for tar archives ------------------------------------------------

class TarParser(ArchiveParser):

    def _get_archive_dir(self):
        list_cmd = "tar -tf %s" % (self._archive,)
        return os.popen(list_cmd).readlines()[0][:-2]

    def _explode_cmd(self):
        """Return the appropriate command for exploding a tar archive"""

        if not _has_executable("tar"):
            raise ArchiveException("cannot open %s, 'tar' not found" % self._archive)

        self._archive_dir = os.path.join(self._temp_dir, self._get_archive_dir())

        return "cd %s; tar xf %s" % (self._temp_dir, self._archive)

# parser for cpio archives -----------------------------------------------

class CpioParser(ArchiveParser):

    def _get_archive_dir(self):
        return os.path.basename(self._archive)[0:5] # arbitrary

    def _explode_cmd(self):
        """Return the appropriate command for exploding a cpio archive"""

        self._archive_dir = os.path.join(self._temp_dir, self._get_archive_dir())

        if not _has_executable("pkgtrans"):
            raise ArchiveException("cannot open %s, 'pkgtrans' not found" % self._archive)

        return "cd %s; mkdir %s; pkgtrans %s %s all" % \
               (self._temp_dir, self._archive_dir, self._archive, self._archive_dir)

# internal helper methods ------------------------------------------------

def _has_executable(exc):
    """Return true if the executable is found in the $PATH"""

    # flag the error condition, this will evaluate to False
    if "PATH" not in os.environ:
        return None

    # this is posix specific
    dirs = os.environ["PATH"].split(':')

    for dir in dirs:
        path = os.path.join(dir, exc)
        if os.access(path, os.X_OK):
            return True

    return False


def _my_popen(cmd):
    """Execute a command as a subprocess and return its exit status"""

    popen = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                 stderr=subprocess.PIPE, close_fds=True)
    popen.stdin.close()

    txt = ""
    while 1:
        rd, wr, ex = select.select([ popen.stdout, popen.stderr ], [], [ popen.stdout, popen.stderr ], 5)
        if ex:
            txt += popen.stdout.read()
            txt += popen.stderr.read()
            break
        if rd:
            txt += rd[0].read()
        break

    status = popen.wait()
    if status != 0:
        raise Exception("%s exited with status %s and error\n%s" % (cmd, status, txt))

    return status

# NOTE these next two functions rely on file magic to determine the compression
# and archive types. some file magic information can be found here:
# http://www.astro.keele.ac.uk/oldusers/rno/Computing/File_magic.html

def _decompress(archive):
    """[internal] Decompress compressed archives and return the new archive name"""
#    if __debug__: print "DEBUG decompressing '%s'" % archive

    cmd = ""
    sfx_list = None

    # determine which type of compression we're dealing with, if any
    fd = open(archive, 'r')
    magic = fd.read(2)
    fd.close()

    if magic == "BZ":
        cmd = "bunzip2"
        sfx_list = (".bz2", ".bz")

    elif magic == "\x1F\x9D":
        cmd = "uncompress"
        sfx_list = (".Z",)

    elif magic == "\x1F\x8B":
        cmd = "gunzip"
        sfx_list = (".gz",)

    # decompress the archive if it is compressed
    if cmd:

        if not _has_executable(cmd):
            raise ArchiveException("Cannot decompress %s, '%s' not found" % (archive, cmd))

        print "Decompressing archive"

        stat = _my_popen("%s %s" % (cmd, archive))

        if stat != 0:
            raise DecompressionError("Error decompressing '%s'" % archive)

        # remove the now invalid suffix from the archive name
        for sfx in sfx_list:
            if archive[-len(sfx):] == sfx:
                archive = archive[:-len(sfx)]
                break

    return archive

# archive parser factory -------------------------------------------------

def get_archive_parser(archive, tempdir="/tmp/"):
    """Factory function that returns an ArchiveParser object for the given archive"""

    # decompress the archive
    archive = _decompress(archive)
    Class = None
    fd = open(archive, 'r')

    magic = fd.read(4)
    if magic == "PK\x03\x04":
        Class = ZipParser

    fd.seek(0)
    magic = fd.read(20)
    if magic == "# PaCkAgE DaTaStReAm":
        Class = CpioParser

    fd.seek(257)
    magic = fd.read(5)
    if magic == "ustar":
        Class = TarParser

    # pre-posix tar doesn't have any standard file magic
    if archive.endswith(".tar"):
        Class = TarParser

    fd.close()

    if Class is None:
        raise UnknownArchiveError("Wasn't able to identify: '%s'" % archive)

    return Class(archive, tempdir)

