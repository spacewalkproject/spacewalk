# Copyright (c) 2010 Red Hat Inc.
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

import gudev
import glib

def get_devices:
    """ Returns list of dictionaries with keys for every device in system
        (values are provide as example):
        'bus' : 'pci'
        'driver' : 'pcieport-driver'
        'pciType' : '1'
        'detached' : '0'
        'class' : 'OTHER'
        'desc' : 'Intel Corporation|5000 Series Chipset PCI Express x4 Port 2'

    """
    # listen to uevents on all subsystems
    client = gudev.Client([""])
    # FIX ME - change to None to list all devices once it is fixed in gudev
    devices = client.query_by_subsystem("pci")
    result = []
    for device in devices:
        subsystem = device.get_subsystem()
        result_item = {
            'bus':      subsystem,
            'driver':   device.get_driver(),
            'pciType':  _clasify_pci_type(subsystem),
            'detached': '0', # always zero?
            'class':    _clasify_class(device)
            'desc':     _get_device_desc(device),
        }
        if subsystem == 'block':
            result_item['device'] = device.get_name()
        result.append(result_item)
    return result_item

def get_computer_info:
    """ Return dictionaries with keys (values are provided as example):
        'system.formfactor': 'unknown'
        'system.kernel.version': '2.6.18-128.1.6.el5xen'
            'system.kernel.machine': 'i686'
        'system.kernel.name': 'Linux'
    """
    pass #FIXME

#PCI DEVICE DEFINES
# These are taken from pci_ids.h in the linux kernel source and used to
# properly identify the hardware
PCI_BASE_CLASS_STORAGE =        1
PCI_CLASS_STORAGE_SCSI =        0
PCI_CLASS_STORAGE_IDE =         1
PCI_CLASS_STORAGE_FLOPPY =      2
PCI_CLASS_STORAGE_IPI =         3
PCI_CLASS_STORAGE_RAID =        4
PCI_CLASS_STORAGE_OTHER =       80

PCI_BASE_CLASS_NETWORK =        2
PCI_CLASS_NETWORK_ETHERNET =    0
PCI_CLASS_NETWORK_TOKEN_RING =  1
PCI_CLASS_NETWORK_FDDI =        2
PCI_CLASS_NETWORK_ATM =         3
PCI_CLASS_NETWORK_OTHER =       80

PCI_BASE_CLASS_DISPLAY =        3
PCI_CLASS_DISPLAY_VGA =         0
PCI_CLASS_DISPLAY_XGA =         1
PCI_CLASS_DISPLAY_3D =          2
PCI_CLASS_DISPLAY_OTHER =       80

PCI_BASE_CLASS_MULTIMEDIA =     4
PCI_CLASS_MULTIMEDIA_VIDEO =    0
PCI_CLASS_MULTIMEDIA_AUDIO =    1
PCI_CLASS_MULTIMEDIA_PHONE =    2
PCI_CLASS_MULTIMEDIA_OTHER =    80

PCI_BASE_CLASS_BRIDGE =         6
PCI_CLASS_BRIDGE_HOST =         0
PCI_CLASS_BRIDGE_ISA =          1
PCI_CLASS_BRIDGE_EISA =         2
PCI_CLASS_BRIDGE_MC =           3
PCI_CLASS_BRIDGE_PCI =          4
PCI_CLASS_BRIDGE_PCMCIA =       5
PCI_CLASS_BRIDGE_NUBUS =        6
PCI_CLASS_BRIDGE_CARDBUS =      7
PCI_CLASS_BRIDGE_RACEWAY =      8
PCI_CLASS_BRIDGE_OTHER =        80

PCI_BASE_CLASS_COMMUNICATION =  7
PCI_CLASS_COMMUNICATION_SERIAL = 0
PCI_CLASS_COMMUNICATION_PARALLEL = 1
PCI_CLASS_COMMUNICATION_MULTISERIAL = 2
PCI_CLASS_COMMUNICATION_MODEM = 3
PCI_CLASS_COMMUNICATION_OTHER = 80

#PCI DEVICE DEFINES
# These are taken from pci_ids.h in the linux kernel source and used to
# properly identify the hardware
PCI_BASE_CLASS_STORAGE =        1
PCI_CLASS_STORAGE_SCSI =        0
PCI_CLASS_STORAGE_IDE =         1
PCI_CLASS_STORAGE_FLOPPY =      2
PCI_CLASS_STORAGE_IPI =         3
PCI_CLASS_STORAGE_RAID =        4
PCI_CLASS_STORAGE_OTHER =       80

PCI_BASE_CLASS_NETWORK =        2
PCI_CLASS_NETWORK_ETHERNET =    0
PCI_CLASS_NETWORK_TOKEN_RING =  1
PCI_CLASS_NETWORK_FDDI =        2
PCI_CLASS_NETWORK_ATM =         3
PCI_CLASS_NETWORK_OTHER =       80

PCI_BASE_CLASS_DISPLAY =        3
PCI_CLASS_DISPLAY_VGA =         0
PCI_CLASS_DISPLAY_XGA =         1
PCI_CLASS_DISPLAY_3D =          2
PCI_CLASS_DISPLAY_OTHER =       80

PCI_BASE_CLASS_MULTIMEDIA =     4
PCI_CLASS_MULTIMEDIA_VIDEO =    0
PCI_CLASS_MULTIMEDIA_AUDIO =    1
PCI_CLASS_MULTIMEDIA_PHONE =    2
PCI_CLASS_MULTIMEDIA_OTHER =    80

PCI_BASE_CLASS_BRIDGE =         6
PCI_CLASS_BRIDGE_HOST =         0
PCI_CLASS_BRIDGE_ISA =          1
PCI_CLASS_BRIDGE_EISA =         2
PCI_CLASS_BRIDGE_MC =           3
PCI_CLASS_BRIDGE_PCI =          4
PCI_CLASS_BRIDGE_PCMCIA =       5
PCI_CLASS_BRIDGE_NUBUS =        6
PCI_CLASS_BRIDGE_CARDBUS =      7
PCI_CLASS_BRIDGE_RACEWAY =      8
PCI_CLASS_BRIDGE_OTHER =        80

PCI_BASE_CLASS_COMMUNICATION =  7
PCI_CLASS_COMMUNICATION_SERIAL = 0
PCI_CLASS_COMMUNICATION_PARALLEL = 1
PCI_CLASS_COMMUNICATION_MULTISERIAL = 2
PCI_CLASS_COMMUNICATION_MODEM = 3
PCI_CLASS_COMMUNICATION_OTHER = 80

def _clasify_pci_type(subsystem):
    """ return 1 if device is PCI, otherwise -1 """
    if subsystem == 'pci':
        return '1'
    else:
        return '-1'

def _clasify_class(device):
    """ Clasify type of device. Returned value is one of following string:
        NETWORK, KEYBOARD, MOUSE, VIDEO, USB, IDE, SCSI, RAID, MODEM, SCANNER
        CAPTURE, AUDIO, FIREWIRE, SOCKET, CDROM, HD, FLOPPY, TAPE, PRINTER, OTHER
        or None if it is neither PCI nor USB device.
    """
    (base_class, sub_class) = _parse_pci_class(device.get_property('PCI_CLASS'))
    subsystem = device.get_subsystem()

    # network devices
    if base_class == PCI_BASE_CLASS_NETWORK:
        return 'NETWORK'

    # input devices
    # pci
    if base_class == PCI_BASE_CLASS_INPUT:
        if sub_class == PCI_CLASS_INPUT_KEYBOARD:
            return 'KEYBOARD'
        elif sub_class == PCI_CLASS_INPUT_MOUSE:
            return 'MOUSE'
    # usb
    id_serial = device.get_property('ID_SERIAL').lower()
    # KEYBOARD <-- do this before mouse, some keyboards have built-in mice
    if 'keyboard' in id_serial:
        return 'KEYBOARD'
    # MOUSE
    if 'mouse' in id_serial:
        return 'MOUSE'

    if base_class:      # PCI Devices
        if base_class == PCI_BASE_CLASS_INPUT:
            return 'VIDEO'
        elif base_class == PCI_BASE_CLASS_SERIAL:
            if sub_class == PCI_CLASS_SERIAL_USB:
                return 'USB'
            elif sub_class == PCI_CLASS_SERIAL_FIREWIRE:
                return 'FIREWIRE'
        elif base_class == PCI_BASE_CLASS_STORAGE:
            if sub_class == PCI_CLASS_STORAGE_IDE:
                return 'IDE'
            elif sub_class == PCI_CLASS_STORAGE_SCSI:
                return 'SCSI'
            elif sub_class == PCI_CLASS_STORAGE_RAID:
                return 'RAID'
        elif base_class == PCI_BASE_CLASS_COMMUNICATION and sub_class == PCI_CLASS_COMMUNICATION_MODEM:
            return 'MODEM'
        elif base_class == PCI_BASE_CLASS_INPUT and sub_class == PCI_CLASS_INPUT_SCANNER:
            return 'SCANNER'
        elif base_class == PCI_BASE_CLASS_MULTIMEDIA:
            if sub_class == PCI_CLASS_MULTIMEDIA_VIDEO:
                return 'CAPTURE'
            elif sub_class == PCI_CLASS_MULTIMEDIA_AUDIO:
                return 'AUDIO'
        elif base_class == PCI_BASE_CLASS_BRIDGE and (
            sub_class == PCI_CLASS_BRIDGE_PCMCIA or sub_class == PCI_CLASS_BRIDGE_CARDBUS ):
            return 'SOCKET'

    # CDROM, HD, FLOPPY, TAPE
    pass #FIXME

    # PRINTER
    pass  #FIXME

    # Catchall for specific devices, only do this after all the others
    if subsystem == 'pci' or subsystem == 'usb':
        return 'OTHER'

    # No class found
    return None

def _get_device_desc(device):
    """ Return human readable description of device. """
    subsystem = device.get_subsystem()
    command = None
    if subsystem == 'pci':
        command = "lspci -d %s" % device.get_property('PCI_ID')
    elif subsystem == 'usb':
        command = "lsusb -d %s:%s" % ( device.get_property('ID_VENDOR_ID'),
                device.get_property('ID_MODEL_ID') )
    from subprocess import PIPE, Popen
    if command:
        return subprocess.Popen(command, stdout=subprocess.PIPE, shell=True).stdout.read()
    else:
        return ''

def _parse_pci_class(pci_class):
    """ Parse Class Code. Return touple of
        [base class code, sub-class code]
        You are usually interested to only first two.
        The third - "specific register-level programming interface" is ignored.
        For details, see the PCI Local Bus Specification 2.1/2.2 Section 6.2.1 Device Identification
    """
    if pci_class is None:
        return (None, None)
    else:
        return (pci_class[-6:-4], pci_class[-4:-2])

