#
# Copyright (c) 1999--2010 Red Hat Inc.
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

""" Query hwdata database and return decription of vendor and/or device. """

class PCI:
    """ Interace to pci.ids from hwdata package """
    filename = '/usr/share/hwdata/pci.ids'

    def __init__(self, filename=None):
        """ Load pci.ids from file to internal data structure.
            parameter 'filename' can specify location of this file
        """
        if filename:
            self.filename = filename
        else:
            self.filename = PCI.filename
        self.cache = 1

        if self.cache:
            # parse pci.ids
            pcirec = {}
            self.devices = {}
            for line in open(self.filename).readlines():
                l = line.split()
                if line.startswith('#'):
                    continue
                elif len(l) == 0:
                    continue
                elif line.startswith('\t\t'):
                    subvendor = l[0].lower()
                    if len(l) > 2:
                        subdevice = l[1].lower()
                    else:
                            subdevice = ''
                    if len(l) > 3:
                        subsystem_name = ' '.join(l[2:])
                    else:
                        subsystem_name = ''
                    if not self.devices.has_key(subvendor):
                        self.devices[subvendor] = [vendor_name, {subdevice: subsystem_name}]
                    else: # this should not happen
                            self.devices[subvendor][1][subdevice] = subsystem_name
                elif line.startswith('\t'):
                    device = l[0].lower()
                    device_name = ' '.join(l[1:])
                    self.devices[vendor][1][device] = device_name
                else:
                    vendor = l[0].lower()
                    vendor_name = ' '.join(l[1:])
                    if not self.devices.has_key(vendor):
                        self.devices[vendor] = [vendor_name, {}]
                    else: # this should not happen
                        self.devices[vendor][0] = vendor_name

    def get_vendor(self, vendor):
        """ Return description of vendor. Parameter is two byte code in hexa.
            If vendor is unknown None is returned.
        """
        if self.cache:
            if self.devices.has_key(vendor):
                return self.devices[vendor][0]
            else:
                return None
        else:
            raise # not implemented yet

    def get_device(self, vendor, device):
        """ Return description of device. Parameters are two byte code variables in hexa.
            If device is unknown None is returned.
        """
        if self.cache:
            if self.devices.has_key(vendor):
                if self.devices[vendor][1].has_key(device):
                    return self.devices[vendor][1][device]
                else:
                    return None
            else:
                return None
        else:
            raise # not implemented yet
