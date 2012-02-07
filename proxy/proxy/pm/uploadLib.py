# Uploading function lib
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

import sys
# RHN imports
from spacewalk.common.checksum import getFileChecksum
from rhnpush import uploadLib

class UploadClass(uploadLib.UploadClass):
    """ Functionality for an uploading tool """

    def list(self):
        # set the URL
        self.setURL()
        # set the channels
        self.setChannels()
        # set the username and password
        self.setUsernamePassword()
        # set the server
        self.setServer()

        if self.options.source:
            self.die(1, "Listing source rpms not supported")
        else:
            # List the channel's contents
            list = uploadLib.listChannel(self.server, self.username, self.password,
                self.channels)
        for p in list:
            print p[:6]

    def newest(self):
        # set the URL
        self.setURL()
        # set the channels
        self.setChannels()
        # set the username and password
        self.setUsernamePassword()
        # set the server
        self.setServer()
        
        sources = self.options.source

        if sources:
            return self.get_missing_source_packages()

        return self.get_newest_binary_packages()

    def copyonly(self):
        # Set the forcing factor
        self.setForce()
        # Relative directory
        self.setRelativeDir()
        # Set the count
        self.setCount()
        # set the org
        #self.setOrg()
        # set the URL
        #self.setURL()
        # set the channels
        #self.setNoChannels()
        # set the username and password
        #self.setUsernamePassword()
        # set the server
        #self.setServer()
        
        for filename in self.files:
            fileinfo = self._processFile(filename,\
                                    relativeDir=self.relativeDir, source=self.options.source,\
                                    nosig=self.options.nosig)
            self.processPackage(fileinfo['nvrea'], filename) 
            
    def uploadHeaders(self):
        # Set the forcing factor
        self.setForce()
        # Relative directory
        self.setRelativeDir()
        # Set the count
        self.setCount()
        # set the org
        self.setOrg()
        # set the URL
        self.setURL()
        # set the channels
        self.setNoChannels()
        # set the username and password
        self.setUsernamePassword()
        # set the server
        self.setServer()

        source = self.options.source

        while self.files:
            chunk = self.files[:self.count]
            del self.files[:self.count]
            uploadedPackages, headersList = self._processBatch(chunk,
                relativeDir=self.relativeDir, source=self.options.source, 
                verbose=self.options.verbose, nosig=self.options.nosig)

            if not headersList:
                # Nothing to do here...
                continue

            # Send the big hash
            hash = {'packages' : headersList}
            if self.orgId > 0 or self.orgId == '':
                hash['orgId'] = self.orgId

            if self.force:
                hash['force'] = self.force

            if self.channels:
                hash['channels'] = self.channels

            # Some feedback
            if self.options.verbose:
                uploadLib.ReportError("Uploading batch:")
                for p in uploadedPackages.values():
                    uploadLib.ReportError("\t\t%s" % p)

            if source:
                method = self.server.packages.uploadSourcePackageInfo
            else:
                method = self.server.packages.uploadPackageInfo

            ret = uploadLib.call(method, self.username, self.password, hash)
            if ret is None:
               self.die(-1, "Upload attempt failed")

            # Append the package information
            alreadyUploaded, newPackages = ret
            pkglists = (alreadyUploaded, newPackages)

            for idx in range(len(pkglists)):
                for p in pkglists[idx]:
                    key = tuple(p[:5])
                    if not uploadedPackages.has_key(key):
                        # XXX Hmm
                        self.warn("XXX XXX %s" % str(p))
                    filename = uploadedPackages[key]
                    # Some debugging
                    if self.options.verbose:
                        if idx == 0:
                            pattern = "Already uploaded: %s"
                        else:
                            pattern = "Uploaded: %s"
                        print pattern % filename
                    # Per-package post actions
                    self.processPackage(p, filename)

    def _processFile(self, filename, relativeDir=None, source=None, nosig=None):
        """ call parent _processFile and add to returned has md5sum """
        hash = uploadLib.UploadClass._processFile(self, filename, relativeDir, source, nosig)
        checksum = getFileChecksum('md5', filename=filename)
        hash['md5sum'] = checksum
        return hash
