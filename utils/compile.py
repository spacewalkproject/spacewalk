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
#
# python compiler. "Borrowed" from Python's py_compile module. As
# opposed to the Python one, this script returns error codes when a
# compile fails, so it can be used from Makefiles
#
# $Id$

import os
import sys
import marshal
import traceback
import string
import __builtin__

import imp
MAGIC = imp.get_magic()

if len(sys.argv) != 3:
    print "Usage:", sys.argv[0], "infile outfile"
    sys.exit(-1)
infile = sys.argv[1]
outfile = sys.argv[2]

def wr_long(f, x):
    "Internal; write a 32-bit int to a file in little-endian order."
    f.write(chr( x        & 0xff))
    f.write(chr((x >> 8)  & 0xff))
    f.write(chr((x >> 16) & 0xff))
    f.write(chr((x >> 24) & 0xff))

def compile(file, cfile=None, dfile=None):
    """Byte-compile one Python source file to Python bytecode.

    Arguments:

    file:  source filename
    cfile: target filename; defaults to source with 'c' or 'o' appended
           ('c' normally, 'o' in optimizing mode, giving .pyc or .pyo)
    dfile: purported filename; defaults to source (this is the filename
           that will show up in error messages)

    Note that it isn't necessary to byte-compile Python modules for
    execution efficiency -- Python itself byte-compiles a module when
    it is loaded, and if it can, writes out the bytecode to the
    corresponding .pyc (or .pyo) file.

    However, if a Python installation is shared between users, it is a
    good idea to byte-compile all modules upon installation, since
    other users may not be able to write in the source directories,
    and thus they won't be able to write the .pyc/.pyo file, and then
    they would be byte-compiling every module each time it is loaded.
    This can slow down program start-up considerably.

    See compileall.py for a script/module that uses this module to
    byte-compile all installed files (or all files in selected
    directories).
    """

    f = open(file)
    try:
        timestamp = long(os.fstat(f.fileno())[8])
    except AttributeError:
        timestamp = long(os.stat(file)[8])
    codestring = f.read()
    f.close()
    if codestring and codestring[-1] != '\n':
        codestring = codestring + '\n'
    try:
        codeobject = __builtin__.compile(codestring, dfile or file, 'exec')
    except SyntaxError, detail:
        lines = traceback.format_exception_only(SyntaxError, detail)
        sys.stderr.write("%s: Error compiling\n" % file)
        for line in lines:
            sys.stderr.write(string.replace(line, 'File "<string>"',
                                            'File "%s"' % (dfile or file)))
        return -1
    if not cfile:
        cfile = file + (__debug__ and 'c' or 'o')
    fc = open(cfile, 'wb')
    fc.write('\0\0\0\0')
    wr_long(fc, timestamp)
    marshal.dump(codeobject, fc)
    fc.flush()
    fc.seek(0, 0)
    fc.write(MAGIC)
    fc.close()
    return 0

if compile(infile, outfile) != 0:
    sys.exit(-1)
