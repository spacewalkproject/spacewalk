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

from kickstart_exceptions import KickstartException

from virtualization.errors import VirtualizationException

class VirtualizationKickstartException(VirtualizationException,
                                       KickstartException):
    """General kickstart exception for virtualization."""
    pass

class DiskImageCreationException(VirtualizationKickstartException):
    """Error occurred while creating a xen guest disk image."""
    pass

class VirtLibNotFoundException(VirtualizationKickstartException):
    """Unable to find virtualization library."""
    pass

class UnsupportedFeatureException(VirtualizationKickstartException):
    """This exception is raised if a piece of functionality is unsupported."""
    pass
