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

# RHN imports
from spacewalk.common.checksum import getFileChecksum
from rhnpush import uploadLib

class UploadClass(uploadLib.UploadClass):
    """ Functionality for an uploading tool """

    # pylint: disable=R0904
    def authenticate(self):
        self.setUsernamePassword()

    def list(self):
        # set the URL
        self.setURL()
        # set the channels
        self.setChannels()
        # set the username and password
        self.authenticate()
        # set the server
        self.setServer()

        if self.options.source:
            self.die(1, "Listing source rpms not supported")
        else:
            # List the channel's contents
            channel_list = uploadLib.listChannel(self.server,
                self.username, self.password,
                self.channels)
        for p in channel_list:
            print p[:6]

    def copyonly(self):
        # Set the forcing factor
        self.setForce()
        # Relative directory
        self.setRelativeDir()
        # Set the count
        self.setCount()
        
        for filename in self.files:
            fileinfo = self._processFile(filename,
                                    relativeDir=self.relativeDir,
                                    source=self.options.source,
                                    nosig=self.options.nosig)
            self.processPackage(fileinfo['nvrea'], filename) 
            
    def _get_files(self):
        return self.files

    def _uploadSourcePackageInfo(self, info):
        return uploadLib.call(self.server.packages.uploadSourcePackageInfo,
                              self.username, self.password, info)

    def _uploadPackageInfo(self):
        return uploadLib.call(self.server.packages.uploadPackageInfo,
                              self.username, self.password, info)

    def _processFile(self, filename, relativeDir=None, source=None, nosig=None):
        """ call parent _processFile and add to returned has md5sum """
        info = uploadLib.UploadClass._processFile(self, filename, relativeDir, source, nosig)
        checksum = getFileChecksum('md5', filename=filename)
        info['md5sum'] = checksum
        return info
