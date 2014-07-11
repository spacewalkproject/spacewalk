#
# Copyright (c) 2008--2013 Red Hat, Inc.
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
# Kickstart-related exceptions.
#

class KickstartException(Exception):
    """General kickstart exception."""
class ImageDownloadException(KickstartException):
    """Error occurred while downloading the vmlinuz or initrd images."""
    pass

class KickstartDownloadException(KickstartException):
    """Error occurred while downloading the kickstart configuration."""
    pass

class MalformedKickstartURLException(KickstartException):
    """Couldn't parse the kickstart URL."""
    pass

class MalformedKickstartFileException(KickstartException):
    """Couldn't parse the kickstart configuration file."""
    pass
