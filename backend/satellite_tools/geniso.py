#!/usr/bin/python
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
#

import os
import sys
import time
import string
from stat import ST_SIZE
from optparse import Option, OptionParser

from spacewalk.common.fileutils import maketemp

MOUNT_POINT = '/tmp'
IMAGE_SIZE = "630M"
DVD_IMAGE_SIZE = "4380M"

def main(arglist):
    optionsTable = [
        Option('-m', '--mountpoint',    action='store', 
            help="mount point"),
        Option('-s', '--size',          action='store', 
            help="image size (eg. 630M)"),
        Option('-p', '--file-prefix',   action='store',
            help='Filename prefix'),
        Option('-o', '--output',        action='store', 
            help='output directory'),
        Option('-v', '--version',       action='store', 
            help='version string'),
        Option('-r', '--release',       action='store', 
            help='release string'),
        Option('--copy-iso-dir',        action='store',
            help='directory to copy the isos to after they have been generated.'),
        Option('-t', '--type',          action='store',
            help='the type of iso being generated.\
                  this flag is optional, but can be set to spanning, non-spanning, or base.'),
    ]
    parser = OptionParser(option_list=optionsTable)
    options, args = parser.parse_args()

    # Check to see if mkisofs is installed
    if not os.path.exists('/usr/bin/mkisofs'):
        print "ERROR:: mkisofs is not Installed. Cannot Proceed iso build. Please install mkisofs and rerun this command."
        return

    mountPoint = options.mountpoint or MOUNT_POINT
    if options.type == "dvd":
        print "Building  DVD Iso ..."
        sizeStr = options.size or DVD_IMAGE_SIZE
    else:
        sizeStr = options.size or IMAGE_SIZE
    imageSize = sizeStrToInt(sizeStr)
    if imageSize == 0:
        print "Unknown size %s" % sizeStr
        return

    if options.version is None:
        options.version = time.strftime("%Y%m%d", time.gmtime(time.time()))

    if options.release is None:
        options.release = '0'
    
    if options.output is None:
        options.output = "/tmp/satellite-isos"

    file_prefix = options.file_prefix or "rhn-satellite"
    if not os.path.isdir(options.output):
        os.makedirs(options.output)

    # Get rid of the extra files in that directory
    for f in os.listdir(options.output):
        os.unlink(os.path.join(options.output, f))
    
    # Normalize the directory name
    mountPoint = os.path.normpath(mountPoint)
        
    # Generate the listings for each CD
    files = findFiles(mountPoint)
    cds = []
    while files:
        cd = []
        sz = 0
        while files:
            filePath, fileSize = files[0]
            if sz + fileSize > imageSize:
                # Overflow
                break

            cd.append(filePath)
            sz = sz + fileSize
            # Advance to the next record
            del files[0] 
        cds.append(cd)
        
    # We now have the CD contents available; generate the ISOs
    cdcount = len(cds)
    
    # Create an empty temp file
    empty_file_path, fd = maketemp("/tmp/empty.file")
    os.close(fd)

    # command-line template
    mkisofsTemplate = "mkisofs -r -J -D -file-mode 0444 -new-dir-mode 0555 -dir-mode 0555 -graft-points %s -o %s /DISK_%s_OF_%s=%s"
    for i in range(cdcount):
        print "---------- %s/%s" % (i+1, cdcount)

        #if options.type is None:
        filename = "%s/%s-%s.%s-%02d.iso" % (options.output, file_prefix,
            options.version, options.release, i+1)
        #else:
        #    filename = "%s/%s-%s-%s.%s-%02d.iso" % (options.output, file_prefix, 
        #        options.type, options.version, options.release, i+1)

        # Create a temp file to store the path specs
        pathfiles, pathfiles_fd = maketemp("/tmp/geniso")

        # Command-line options; the keys are supposed to start with a dash
        opts = {
            'preparer'      : "Red Hat Network <rhn-feedback@redhat.com>",
            'publisher'     : "Red Hat Network <rhn-feedback@redhat.com>",
            'volid'         : "RHNSAT_%s/%s" % (i+1, cdcount),
            'path-list'     : pathfiles,
        }
        opts = map(lambda x: '-%s "%s"' % x, opts.items())

        # Generate the file list that will go into the CD
        # See the man page for mkisofs to better understand how graft points
        # work (although the man page is not great)
        grafts = []
        for f in cds[i]:
            # Compute the relative path
            relpath = f[len(mountPoint) + 1:]
            # Append to the graft list: relative=real
            relpath = os.path.dirname(relpath)
            grafts.append("%s/=%s" % (relpath, f))

        # Generate the command line
        cmd = mkisofsTemplate % (string.join(opts), filename, i+1, cdcount,
            empty_file_path)

        # Write the path specs in pathfiles
        for graft in grafts:
            os.write(pathfiles_fd, graft)
            os.write(pathfiles_fd, "\n")
        os.close(pathfiles_fd)
        
        print "Creating %s" % filename
        # And run it
        fd = os.popen(cmd, "r")
        print fd.read()

        if not options.copy_iso_dir is None:
            copy_iso_path = os.path.join(options.copy_iso_dir, os.path.basename(os.path.dirname(filename)))
            if not os.path.exists(copy_iso_path):
                os.mkdir(copy_iso_path)
            fd = os.popen("mv %s %s" % (filename, copy_iso_path), "r")
            print fd.read()
            fd = os.popen("rm %s" % filename)
            print fd.read()

        # Remove the temp file
        os.unlink(pathfiles)

    # Remove the file we used to label the CDs
    os.unlink(empty_file_path)
        

def sizeStrToInt(s):
    # Converts s to an int
    if s is None or s is "":
        # Don't know how to interpret it
        return 0

    s = str(s)
    # Strip the dashes in front - we don't want the number to be negative
    while s and s[0] == '-':
        s = s[1:]
        
    try:
        return int(s)
    except ValueError:
        # not an int
        pass

    if s[-1] in ('k', 'K', 'm', 'M'):
        # Specified a multiplier
        if string.lower(s[-1]) == 'k':
            mult = 1024
        else:
            mult = 1024 * 1024

        try:
            return mult * int(s[:-1])
        except ValueError:
            pass

    # Don't know how to interpret it
    return 0

# The visitfunc argument for os.path.walk
def __visitfunc(arg, dirname, names):
     for f in names:
        filename = os.path.normpath("%s/%s" % (dirname, f))
        if os.path.isdir(filename):
            # walk will process it later
            continue
        # Get the size
        sz = os.stat(filename)[ST_SIZE]
        # Append the filename and size to the list
        arg.append((filename, sz))
    
# Given a directory name, returns the paths of all the files from that
# directory, together with the file size
def findFiles(start):
    a = []
    os.path.walk(start, __visitfunc, a)
    return a


if __name__ == '__main__':
    main(sys.argv)
