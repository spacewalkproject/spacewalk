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

class USB:
    """ Interace to usb.ids from hwdata package """
    filename = '/usr/share/hwdata/usb.ids'
    devices = None

    def __init__(self, filename=None):
        """ Load pci.ids from file to internal data structure.
            parameter 'filename' can specify location of this file
        """
        if filename:
            self.filename = filename
        else:
            self.filename = USB.filename
        self.cache = 1

        if self.cache and not USB.devices:
            # parse usb.ids
            USB.devices = {}
            for line in open(self.filename).readlines():
                l = line.split()
                if line.startswith('#'):
                    if line.startswith('# List of known device classes, subclasses and protocols'):
                        break # end of database of devices, rest is protocols, types etc.
                    else:
                        continue
                elif len(l) == 0:
                    continue
                elif line.startswith('\t\t'):
                    interface_id = l[0].lower()
                    if len(l) > 2:
                        interface_name = ' '.join(l[1:])
                    else:
                        interface_name = ''
                    USB.devices[vendor][1][device][0][interface_id] = interface_name
                elif line.startswith('\t'):
                    device = l[0].lower()
                    device_name = ' '.join(l[1:])
                    USB.devices[vendor][1][device] = [device_name, {}]
                else:
                    vendor = l[0].lower()
                    vendor_name = ' '.join(l[1:])
                    if vendor not in USB.devices:
                        USB.devices[vendor] = [vendor_name, {}]
                    else: # this should not happen
                        USB.devices[vendor][0] = vendor_name

    def get_vendor(self, vendor):
        """ Return description of vendor. Parameter is two byte code in hexa.
            If vendor is unknown None is returned.
        """
        vendor = vendor.lower()
        if self.cache:
            if vendor in USB.devices:
                return USB.devices[vendor][0]
            else:
                return None
        else:
            raise # not implemented yet

    def get_device(self, vendor, device):
        """ Return description of device. Parameters are two byte code variables in hexa.
            If device is unknown None is returned.
        """
        vendor = vendor.lower()
        device = device.lower()
        if self.cache:
            if vendor in USB.devices:
                if device in USB.devices[vendor][1]:
                    return USB.devices[vendor][1][device][0]
                else:
                    return None
            else:
                return None
        else:
            raise # not implemented yet

class PCI:
    """ Interace to pci.ids from hwdata package """
    filename = '/usr/share/hwdata/pci.ids'
    devices = None

    def __init__(self, filename=None):
        """ Load pci.ids from file to internal data structure.
            parameter 'filename' can specify location of this file
        """
        if filename:
            self.filename = filename
        else:
            self.filename = PCI.filename
        self.cache = 1

        if self.cache and not PCI.devices:
            # parse pci.ids
            pcirec = {}
            PCI.devices = {}
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
                    if not subvendor in list(PCI.devices.keys()):
                        PCI.devices[subvendor] = [vendor_name, {subdevice: subsystem_name}]
                    else: # this should not happen
                            PCI.devices[subvendor][1][subdevice] = subsystem_name
                elif line.startswith('\t'):
                    device = l[0].lower()
                    device_name = ' '.join(l[1:])
                    PCI.devices[vendor][1][device] = device_name
                else:
                    vendor = l[0].lower()
                    vendor_name = ' '.join(l[1:])
                    if not vendor in  list(PCI.devices.keys()):
                        PCI.devices[vendor] = [vendor_name, {}]
                    else: # this should not happen
                        PCI.devices[vendor][0] = vendor_name

    def get_vendor(self, vendor):
        """ Return description of vendor. Parameter is two byte code in hexa.
            If vendor is unknown None is returned.
        """
        vendor = vendor.lower()
        if self.cache:
            if vendor in list(PCI.devices.keys()):
                return PCI.devices[vendor][0]
            else:
                return None
        else:
            raise # not implemented yet

    def get_device(self, vendor, device):
        """ Return description of device. Parameters are two byte code variables in hexa.
            If device is unknown None is returned.
        """
        vendor = vendor.lower()
        device = device.lower()
        if self.cache:
            if vendor in list(PCI.devices.keys()):
                if device in list(PCI.devices[vendor][1].keys()):
                    return PCI.devices[vendor][1][device]
                else:
                    return None
            else:
                return None
        else:
            raise # not implemented yet
