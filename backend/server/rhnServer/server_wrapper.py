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
# this file implements the ServerWrapper class, which takes care
# of all the load and save functions for misc tables associated
# with a server (such as packages, hardware, history)
#
# the server.Server class inherits this ServerWrapper class
#

from server_hardware import Hardware
from server_packages import Packages
from server_history import History

from rhn.UserDictCase import UserDictCase
from spacewalk.server import rhnSQL

class ServerWrapper(Packages, Hardware, History):
    """ This is a middle class that ties all the subclasses together, plus it
        provides a cleaner way to keep all the wrapper functions in one place.
        The main Server class is based on this one and it looks a little bit
        cleaner that way.
    """
    def __init__(self):
        self.server = UserDictCase()
        Packages.__init__(self)
        History.__init__(self)
        Hardware.__init__(self)

    def __repr__(self):
        return "<%s instance>" % (self.__class__,)

    def set_value(self, name, value):
        """ update a value in self.server """
        if name is None or value is None:
            return -1
        self.server[name] = value
        return 0

    ###
    ### PACKAGES
    ###

    def add_package(self, entry):
        """ Wrappers for the similar functions from Packages class that supplementaly
            require a valid sysid.
        """
        return Packages.add_package(self, self.server.get("id"), entry)

    def delete_package(self, entry):
        return Packages.delete_package(self, self.server.get("id"), entry)

    def dispose_packages(self):
        return Packages.dispose_packages(self, self.server["id"])

    def save_packages(self, schedule=1):
        """ wrapper for the Packages.save_packages_byid() which requires the sysid """
        ret = self.save_packages_byid(self.server["id"], schedule=schedule)
        # this function is primarily called from outside
        # so we have to commit here
        rhnSQL.commit()
        return ret

    ###
    ### HARDWARE
    ###

    def delete_hardware(self):
        """ Wrappers for the similar functions from Hardware class """
        return Hardware.delete_hardware(self, self.server.get("id"))
    def save_hardware(self):
        """ wrapper for the Hardware.save_hardware_byid() which requires the sysid """
        ret = self.save_hardware_byid(self.server["id"])
        # this function is primarily called from outside
        # so we have to commit here
        rhnSQL.commit()
        return ret
    def reload_hardware(self):
        """ wrapper for the Hardware.reload_hardware_byid() which requires the sysid """
        ret = self.reload_hardware_byid(self.server["id"])
        return ret

    ###
    ### HISTORY
    ###
    def save_history(self):
        ret = self.save_history_byid(self.server["id"])
        # this function is primarily called from outside
        # so we have to commit here
        rhnSQL.commit()
        return ret

