#!/usr/bin/python
#
# Copyright (c) 2008--2015 Red Hat, Inc.
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
"""\
Management tool for the Spacewalk Proxy.

This script performs various management operations on the Spacewalk Proxy:
- Creates the local directory structure needed to store local packages
- Uploads packages from a given directory to the RHN servers
- Optionally, once the packages are uploaded, they can be linked to (one or
  more) channels, and copied in the local directories for these channels.
- Lists the RHN server's vision on a certain channel
- Checks if the local image of the channel (the local directory) is in sync
  with the server's image, and prints the missing packages (or the extra
  ones)
- Cache any RPM content locally to avoid needing to download them. This can be
  particularly useful if bandwitdth is precious or the connection to the server
  is slow.
"""

# system imports
import gzip
import os
from xml.dom import minidom
import sys
import shutil
import xmlrpclib
from optparse import Option, OptionParser

# RHN imports
from spacewalk.common.rhnConfig import CFG, initCFG
from spacewalk.common.rhnLib import parseUrl
initCFG('proxy.package_manager')
from rhnpush.uploadLib import UploadError
from rhnpush import uploadLib
from proxy.broker.rhnRepository import computePackagePaths

# globals
PREFIX = 'rhn'


def main():
    # Initialize a command-line processing object with a table of options
    optionsTable = [
        Option('-v', '--verbose',   action='count',      help='Increase verbosity'),
        Option('-d', '--dir',       action='store',      help='Process packages from this directory'),
        Option('-L', '--cache-locally', action='store_true',
               help='Locally cache packages so that Proxy will not ever need to '
               + 'download them. Changes nothing on the upstream server.'),
        Option('-e', '--from-export', action='store', dest='export_location',
               help='Process packages from this channel export. Can only be used '
               + 'with --cache-locally or --copyonly.'),
        Option('-c', '--channel',   action='append',
               help='Channel to operate on. When used with --from-export '
               + 'specifies channels to cache rpms for, else specifies channels '
               + 'that we will be pushing into.'),
        Option('-n', '--count',     action='store',      help='Process this number of headers per call', type='int'),
        Option('-l', '--list',      action='store_true', help='Only list the specified channels'),
        Option('-s', '--sync',      action='store_true', help='Check if in sync with the server'),
        Option('-p', '--printconf', action='store_true', help='Print the configuration and exit'),
        Option('-X', '--exclude',   action="append",     help="Exclude packages that match this glob expression"),
        Option('--newest',    action='store_true', help='Only push the files that are newer than the server ones'),
        Option('--stdin',     action='store_true', help='Read the package names from stdin'),
        Option('--nosig',     action='store_true', help="Push unsigned packages"),
        Option('--username',  action='store',      help='Use this username to connect to RHN'),
        Option('--password',  action='store',      help='Use this password to connect to RHN'),
        Option('--source',    action='store_true', help='Upload source package headers'),
        Option('--dontcopy',  action='store_true', help='Do not copy packages to the local directory'),
        Option('--copyonly',  action='store_true',
               help="Only copy packages; don't reimport. Same as --cache-locally"),
        Option('--test',      action='store_true', help='Only print the packages to be pushed'),
        Option('-N', '--new-cache',  action='store_true', help='Create a new username/password cache'),
        Option('--no-ssl',    action='store_true', help='Turn off SSL (not recommended).'),
        Option('--no-session-caching',  action='store_true',
               help='Disables session-token authentication.'),
        Option('-?', '--usage',     action='store_true', help="Briefly describe the options"),
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

    # It's just an alias to copyonly
    if options.cache_locally:
        options.copyonly = True

    # remeber to process dir option before export, export can overwrite dir
    if options.dir:
        upload.directory()
    if options.export_location:
        if not options.copyonly:
            upload.die(0, "--from-export can only be used with --cache-locally"
                       + " or --copyonly")
        if options.source:
            upload.die(0, "--from-export cannot be used with --source")
        upload.from_export()
    if options.stdin:
        upload.readStdin()

    # if we're going to allow the user to specify packages by dir *and* export
    # *and* stdin *and* package list (why not?) then we have to uniquify
    # the list afterwards. Sort just for user-friendly display.
    upload.files = sorted(list(set(upload.files)))

    if options.copyonly:
        if not upload.files:
            upload.die(0, "Nothing to do; exiting. Try --help")
        if options.test:
            upload.test()
            return
        upload.copyonly()
        return

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
    # pylint: disable=R0904,W0221

    def setURL(self, path='/APP'):
        # overloaded for uploadlib.py
        if not CFG.RHN_PARENT:
            self.die(-1, "rhn_parent not set in the configuration file")
        self.url = CFG.RHN_PARENT
        scheme = 'http://'
        if not self.options.no_ssl and CFG.USE_SSL:
            # i.e., --no-ssl overrides the USE_SSL config variable.
            scheme = 'https://'
        self.url = CFG.RHN_PARENT or ''
        self.url = parseUrl(self.url)[1].split(':')[0]
        self.url = scheme + self.url + path

    # The rpm names in channel exports have been changed to be something like
    # rhn-package-XXXXXX.rpm, but that's okay because the rpm headers are
    # still intact and that's what we use to determine the destination
    # filename. Read the channel xml to determin what rpms to cache if the
    # --channel option was used.
    def from_export(self):
        export_dir = self.options.export_location
        self.warn(1, "Getting files from channel export: ", export_dir)
        if not self.options.channel:
            self.warn(2, "No channels specified, getting all files")
            # If no channels specified just upload all rpms from
            # all the rpm directories
            for hash_dir in uploadLib.listdir(os.path.join(
                    export_dir, "rpms")):
                self.options.dir = hash_dir
                self.directory()
            return
        # else...
        self.warn(2, "Getting only files in these channels",
                  self.options.channel)
        # Read the channel xml and add only packages that are in these channels
        package_set = set([])
        for channel in self.options.channel:
            xml_path = os.path.join(export_dir, "channels", channel,
                                    "channel.xml.gz")
            if not os.access(xml_path, os.R_OK):
                self.warn(0, "Could not find metadata for channel %s, skipping..." % channel)
                print "Could not find metadata for channel %s, skipping..." % channel
                continue
            dom = minidom.parse(gzip.open(xml_path))
            # will only ever be the one
            dom_channel = dom.getElementsByTagName('rhn-channel')[0]
            package_set.update(dom_channel.attributes['packages']
                               .value.encode('ascii', 'ignore').split())
        # Try to find relevent packages in the export
        for hash_dir in uploadLib.listdir(os.path.join(export_dir, "rpms")):
            for rpm in uploadLib.listdir(hash_dir):
                # rpm name minus '.rpm'
                if os.path.basename(rpm)[:-4] in package_set:
                    self.files.append(rpm)

    def setServer(self):
        try:
            uploadLib.UploadClass.setServer(self)
            uploadLib.call(self.server.packages.no_op, raise_protocol_error=True)
        except xmlrpclib.ProtocolError, e:
            if e.errcode == 404:
                self.use_session = False
                self.setURL('/XP')
                uploadLib.UploadClass.setServer(self)
            else:
                raise

    def authenticate(self):
        if self.use_session:
            uploadLib.UploadClass.authenticate(self)
        else:
            self.setUsernamePassword()

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
        # set the server
        self.setServer()

        self.authenticate()

        # List the channel's contents
        channel_list = self._listChannel()

        # Convert it to a hash of hashes
        remotePackages = {}
        for channel in self.channels:
            remotePackages[channel] = {}
        for p in channel_list:
            channelName = p[-1]
            key = tuple(p[:5])
            remotePackages[channelName][key] = None

        missing = []
        for package in channel_list:
            found = False
            # if the package includes checksum info
            if self.use_checksum_paths:
                checksum = package[6]
            else:
                checksum = None

            packagePaths = computePackagePaths(package, 0, PREFIX, checksum)
            for packagePath in packagePaths:
                packagePath = "%s/%s" % (CFG.PKG_DIR, packagePath)
                if os.path.isfile(packagePath):
                    found = True
                    break
            if not found:
                missing.append([package, packagePaths[0]])

        if not missing:
            self.warn(0, "Channels in sync with the server")
            return

        for package, packagePath in missing:
            channelName = package[-1]
            self.warn(0, "Missing: %s in channel %s (path %s)" % (
                rpmPackageName(package), channelName, packagePath))

    def processPackage(self, package, filename, checksum=None):
        if self.options.dontcopy:
            return

        if not CFG.PKG_DIR:
            self.warn(1, "No package directory specified; will not copy the package")
            return

        if not self.use_checksum_paths:
            checksum = None
        # Copy file to the prefered path
        packagePath = computePackagePaths(package, self.options.source,
                                          PREFIX, checksum)[0]
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

    def _listChannelSource(self):
        self.die(1, "Listing source rpms not supported")

    def copyonly(self):
        # Set the forcing factor
        self.setForce()
        # Relative directory
        self.setRelativeDir()
        # Set the count
        self.setCount()

        if not CFG.PKG_DIR:
            self.warn(1, "No package directory specified; will not copy the package")
            return

        # Safe because proxy X can't be activated against Spacewalk / Satellite
        # < X.
        self.use_checksum_paths = True

        for filename in self.files:
            fileinfo = self._processFile(filename,
                                         relativeDir=self.relativeDir,
                                         source=self.options.source,
                                         nosig=self.options.nosig)
            self.processPackage(fileinfo['nvrea'], filename,
                                fileinfo['checksum'])


def rpmPackageName(p):
    return "%s-%s-%s.%s.rpm" % (p[0], p[1], p[2], p[4])

if __name__ == '__main__':
    try:
        main()
    except SystemExit, se:
        sys.exit(se.code)
