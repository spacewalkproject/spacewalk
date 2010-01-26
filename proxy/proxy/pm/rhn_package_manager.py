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
# Authors: Mihai Ibanescu <misa@redhat.com>
#          Todd Warner <taw@redhat.com>
#
# $Id: rhn_package_manager.py,v 1.83 2005/06/15 18:58:11 taw Exp $
"""\
Management tool for the RHN proxy.

This script performs various management operations on the RHN proxy:
- Creates the local directory structure needed to store local packages
- Uploads packages from a given directory to the RHN servers
- Optionally, once the packages are uploaded, they can be linked to (one or
  more) channels, and copied in the local directories for these channels.
- Lists the RHN server's vision on a certain channel
- Checks if the local image of the channel (the local directory) is in sync
  with the server's image, and prints the missing packages (or the extra
  ones)
"""

# system imports
import os
import sys
import string
import shutil
from types import IntType, StringType
from operator import truth
from rhnpush.uploadLib import UploadError
try:
    from optparse import Option, OptionParser
except ImportError:
    from optik import Option, OptionParser

# RHN imports
from common import CFG, initCFG
from common.rhnLib import parseUrl
initCFG('proxy.package_manager')

# local imports
import uploadLib

# globals
PREFIX = 'rhn'


def main():
    # Initialize a command-line processing object with a table of options
    optionsTable = [
        Option('-v','--verbose',   action='count',      help='Increase verbosity'),
        Option('-d','--dir',       action='store',      help='Process packages from this directory'),
        Option('-c','--channel',   action='append',     help='Manage this channel'),
        Option('-n','--count',     action='store',      help='Process this number of headers per call', type='int'),
        Option('-l','--list',      action='store_true', help='Only list the specified channels'),
        Option('-s','--sync',      action='store_true', help='Check if in sync with the server'),
        Option('-p','--printconf', action='store_true', help='Print the configuration and exit'),
        Option('-X','--exclude',   action="append",     help="Exclude packages that match this glob expression"),
        Option(     '--newest',    action='store_true', help='Only push the files that are newer than the server ones'),
        Option(     '--stdin',     action='store_true', help='Read the package names from stdin'),
        Option(     '--nosig',     action='store_true', help="Push unsigned packages"),
        Option(     '--username',  action='store',      help='Use this username to connect to RHN'),
        Option(     '--password',  action='store',      help='Use this password to connect to RHN'),
        Option(     '--source',    action='store_true', help='Upload source package headers'),
        Option(     '--dontcopy',  action='store_true', help='Do not copy packages to the local directory'),
        Option(     '--copyonly',  action='store_true', help="Only copy packages; don't reimport"),
        Option(     '--test',      action='store_true', help='Only print the packages to be pushed'),
        Option(     '--no-ssl',    action='store_true', help='Turn off SSL (not recommended).'),
        Option('-?','--usage',     action='store_true', help="Briefly describe the options"),
    ]
    # Process the command line arguments
    optionParser = OptionParser(option_list=optionsTable, usage="USAGE: %prog [OPTION] [<package>]")
    options, files = optionParser.parse_args()
    upload = UploadClass(options, files=files)

    if options.usage:
        optionParser.print_usage()
        sys.exit(0)

    if options.printconf:
        CFG.show()
        return

    if options.list:
        upload.list()
        return

    if options.sync:
        upload.checkSync()
        return

    if options.copyonly:
        upload.copyonly()
        return

    if options.dir:
        upload.directory()
    elif options.stdin:
        upload.readStdin()

    if options.exclude:
        upload.filter_excludes()

    if options.newest:
        upload.newest()

    if not upload.files:
        upload.die(0, "Nothing to do; exiting. Try --help")

    if options.test:
        upload.test()
        return

    try:
        upload.uploadHeaders()
    except UploadError, e:
        sys.stderr.write("Upload error: %s\n" % e)


class UploadClass(uploadLib.UploadClass):
    def setURL(self):
        # overloaded for uploadlib.py
        if not CFG.RHN_PARENT:
            self.die(-1, "rhn_parent not set in the configuration file")
        self.url = CFG.RHN_PARENT
        scheme = 'http://'
        if not self.options.no_ssl and CFG.USE_SSL:
            # i.e., --no-ssl overrides the USE_SSL config variable.
            scheme = 'https://'
        self.url = CFG.RHN_PARENT or ''
        self.url = string.split(parseUrl(self.url)[1], ':')[0]
        self.url = scheme + self.url + '/XP'

    def setProxyUsernamePassword(self):
        # overloaded for uploadlib.py
        self.proxyUsername = CFG.HTTP_PROXY_USERNAME
        self.proxyPassword = CFG.HTTP_PROXY_PASSWORD

    def setProxy(self):
        # overloaded for uploadlib.py
        self.proxy = CFG.HTTP_PROXY

    def setCAchain(self):
        # overloaded for uploadlib.py
        self.ca_chain = CFG.CA_CHAIN

    def setNoChannels(self):
        self.channels = self.options.channel

    def checkSync(self):
        # set the org
        self.setOrg()
        # set the URL
        self.setURL()
        # set the channels
        self.setChannels()
        # set the username and password
        self.setUsernamePassword()
        # set the server
        self.setServer()

        # List the channel's contents
        list = uploadLib.listChannel(self.server, self.username, self.password,
                                     self.channels)

        # Convert it to a hash of hashes
        remotePackages = {}
        for channel in self.channels:
            remotePackages[channel] = {}
        for p in list:
            channelName = p[5]
            key = tuple(p[:5])
            remotePackages[channelName][key] = None

        missing = []
        for package in list:
            packagePath = getPackagePath(package, 0, PREFIX)
            packagePath = "%s/%s" % (CFG.PKG_DIR, packagePath)
            if not os.path.isfile(packagePath):
                missing.append([package, packagePath])

        if not missing:
            self.warn(0, "Channels in sync with the server")
            return

        for package, packagePath in missing:
            channelName = package[5]
            self.warn(0, "Missing: %s in channel %s (path %s)" % (
                rpmPackageName(package), channelName, packagePath))

    def processPackage(self, package, filename):
        if self.options.dontcopy:
            return

        if not CFG.PKG_DIR:
            self.warn(1, "No package directory specified; will not copy the package")
            return

        packagePath = getPackagePath(package, self.options.source, PREFIX)
        packagePath = "%s/%s" % (CFG.PKG_DIR, packagePath)
        destdir = os.path.dirname(packagePath)
        if not os.path.isdir(destdir):
            # Try to create it
            try:
                os.makedirs(destdir, 0755)
            except OSError:
                self.warn(0, "Could not create directory %s" % destdir)
                return
        self.warn(1, "Copying %s to %s" % (filename, packagePath))
        shutil.copy2(filename, packagePath)
        # Make sure the file permissions are set correctly, so that Apache can
        # see the files
        os.chmod(packagePath, 0644)


def rpmPackageName(p):
    return "%s-%s-%s.%s.rpm" % (p[0], p[1], p[2], p[4])


def getPackagePath(nvrea, source=0, prepend=""):
    """Finds the appropriate path, prepending something if necessary
    """
    name = nvrea[0]
    release = nvrea[2]

    if source:
        dirarch = 'SRPMS'
        pkgarch = 'src'
    else:
        dirarch = pkgarch = nvrea[4]

    version = nvrea[1]
    epoch = nvrea[3]
    # Source packages are soooo broken; if they have an epoch, there is no
    # possible way to retrieve them, so assume the epoch is None
    if source:
        epoch = None
    if epoch not in [None, '']:
        version = str(epoch) + ':' + version
    template = prepend + "/%s/%s-%s/%s/%s-%s-%s.%s.rpm"
    # Sanitize the path: remove duplicated /
    template = string.join(filter(truth, string.split(template, '/')), '/')
    return template % (name, version, release, dirarch, name, nvrea[1],
        release, pkgarch)


class rhnPackageManagerException(Exception):
    """Custom exception class"""
    pass


if __name__ == '__main__':
    try:
        main()
    except SystemExit, e:
        sys.exit(e.code)

