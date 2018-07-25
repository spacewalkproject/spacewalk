# Copyright (c) 2010--2016 Red Hat, Inc.
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

import pyudev
import os
import re

from hwdata import PCI, USB

def get_devices():
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
    context = pyudev.Context()
    devices = context.list_devices()

    result = []
    for device in devices.match_subsystem("pci").match_subsystem("usb").match_subsystem("block").match_subsystem("ccw").match_subsystem("scsi"):
        subsystem = device.subsystem
        result_item = {
            'bus':      subsystem,
            'driver':   device.driver,
            'pciType':  _clasify_pci_type(subsystem),
            'detached': '0', # always zero?
            'class':    _clasify_class(device),
            'desc':     _get_device_desc(device),
        }
        if result_item['class'] is None:
            result_item['class'] = 'OTHER'
        if result_item['driver'] is None:
            result_item['driver'] = 'unknown'
        if subsystem == 'block':
            if _get_device_property(device, 'ID_BUS'):
                result_item['bus'] = _get_device_property(device, 'ID_BUS')
            result_item['device'] = device.sys_name
            if device.device_type == 'partition':
                # do not report partitions, just whole disks
                continue
            if _get_device_property(device, 'DM_NAME'):
                # LVM device
                continue
            if _get_device_property(device, 'MAJOR') == '1':
                # ram device
                continue
            if _get_device_property(device, 'MAJOR') == '7':
                # character devices for virtual console terminals
                continue
            # This is interpreted as Physical. But what to do with it?
            # result_item['prop1'] = ''
            # This is interpreted as Logical. But what to do with it?
            # result_item['prop2'] = ''
        elif subsystem == 'pci':
            pci_class = _get_device_property(device, 'PCI_ID')
            if pci_class:
                (result_item['prop1'], result_item['prop2']) = pci_class.split(':')
            pci_subsys = _get_device_property(device, 'PCI_SUBSYS_ID')
            if pci_subsys:
                (result_item['prop3'], result_item['prop4']) = pci_subsys.split(':')
        elif subsystem == 'usb':
           if _get_device_property(device, 'ID_VENDOR_ID'):
                result_item['prop1'] = _get_device_property(device, 'ID_VENDOR_ID')
           if _get_device_property(device, 'ID_MODEL_ID'):
                result_item['prop2'] = _get_device_property(device, 'ID_MODEL_ID')
        if _get_device_property(device, 'ID_BUS') and _get_device_property(device, 'ID_BUS') == 'scsi':
            if _get_device_property(device, 'ID_PATH') or _get_device_property(device, 'DEVPATH'):
                if _get_device_property(device, 'ID_PATH'):
                    path = _get_device_property(device, 'ID_PATH')
                    m = re.search('.*scsi-(\d+):(\d+):(\d+):(\d+)', path)
                else: # device.has_property('DEVPATH')
                    path = _get_device_property(device, 'DEVPATH')
                    m = re.search('.*/(\d+):(\d+):(\d+):(\d+)/block/', path)
                if m: # do not fail, if regexp did not match
                    result_item['prop1'] = m.group(1) # DEV_HOST
                    result_item['prop2'] = m.group(2) # DEV_ID
                    result_item['prop3'] = m.group(3) # DEV_CHANNEL
                    result_item['prop4'] = m.group(4) # DEV_LUN
        result.append(result_item)
    return result

def get_computer_info():
    """ Return dictionaries with keys (values are provided as example):
        'system.formfactor': 'unknown'
        'system.kernel.version': '2.6.18-128.1.6.el5xen'
            'system.kernel.machine': 'i686'
        'system.kernel.name': 'Linux'
    """
    uname = os.uname()
    result = {
        'system.kernel.name': uname[0],
        'system.kernel.version': uname[2],
        'system.kernel.machine': uname[4],
    }
    return result

#PCI DEVICE DEFINES
# These are taken from pci_ids.h in the linux kernel source and used to
# properly identify the hardware
PCI_BASE_CLASS_STORAGE =        '1'
PCI_CLASS_STORAGE_SCSI =        '00'
PCI_CLASS_STORAGE_IDE =         '01'
PCI_CLASS_STORAGE_FLOPPY =      '02'
PCI_CLASS_STORAGE_IPI =         '03'
PCI_CLASS_STORAGE_RAID =        '04'
PCI_CLASS_STORAGE_OTHER =       '80'

PCI_BASE_CLASS_NETWORK =        '2'
PCI_CLASS_NETWORK_ETHERNET =    '00'
PCI_CLASS_NETWORK_TOKEN_RING =  '01'
PCI_CLASS_NETWORK_FDDI =        '02'
PCI_CLASS_NETWORK_ATM =         '03'
PCI_CLASS_NETWORK_OTHER =       '80'

PCI_BASE_CLASS_DISPLAY =        '3'
PCI_CLASS_DISPLAY_VGA =         '00'
PCI_CLASS_DISPLAY_XGA =         '01'
PCI_CLASS_DISPLAY_3D =          '02'
PCI_CLASS_DISPLAY_OTHER =       '80'

PCI_BASE_CLASS_MULTIMEDIA =     '4'
PCI_CLASS_MULTIMEDIA_VIDEO =    '00'
PCI_CLASS_MULTIMEDIA_AUDIO =    '01'
PCI_CLASS_MULTIMEDIA_PHONE =    '02'
PCI_CLASS_MULTIMEDIA_OTHER =    '80'

PCI_BASE_CLASS_BRIDGE =         '6'
PCI_CLASS_BRIDGE_HOST =         '00'
PCI_CLASS_BRIDGE_ISA =          '01'
PCI_CLASS_BRIDGE_EISA =         '02'
PCI_CLASS_BRIDGE_MC =           '03'
PCI_CLASS_BRIDGE_PCI =          '04'
PCI_CLASS_BRIDGE_PCMCIA =       '05'
PCI_CLASS_BRIDGE_NUBUS =        '06'
PCI_CLASS_BRIDGE_CARDBUS =      '07'
PCI_CLASS_BRIDGE_RACEWAY =      '08'
PCI_CLASS_BRIDGE_OTHER =        '80'

PCI_BASE_CLASS_COMMUNICATION =  '7'
PCI_CLASS_COMMUNICATION_SERIAL = '00'
PCI_CLASS_COMMUNICATION_PARALLEL = '01'
PCI_CLASS_COMMUNICATION_MULTISERIAL = '02'
PCI_CLASS_COMMUNICATION_MODEM = '03'
PCI_CLASS_COMMUNICATION_OTHER = '80'

PCI_BASE_CLASS_INPUT =          '9'
PCI_CLASS_INPUT_KEYBOARD =      '00'
PCI_CLASS_INPUT_PEN =           '01'
PCI_CLASS_INPUT_MOUSE =         '02'
PCI_CLASS_INPUT_SCANNER =       '03'
PCI_CLASS_INPUT_GAMEPORT =      '04'
PCI_CLASS_INPUT_OTHER =         '80'

PCI_BASE_CLASS_SERIAL =         'C'
PCI_CLASS_SERIAL_FIREWIRE =     '00'
PCI_CLASS_SERIAL_ACCESS =       '01'
PCI_CLASS_SERIAL_SSA =          '02'
PCI_CLASS_SERIAL_USB =          '03'
PCI_CLASS_SERIAL_FIBER =        '04'
PCI_CLASS_SERIAL_SMBUS =        '05'

def _clasify_pci_type(subsystem):
    """ return 1 if device is PCI, otherwise -1 """
    if subsystem == 'pci':
        return '1'
    else:
        return '-1'

def _get_device_property(device, prop):
    """ return the property of the given device independent of the implementation version """
    try:
        return device.properties.get(prop)
    except AttributeError:
        return device.get(prop)

def _clasify_class(device):
    """ Clasify type of device. Returned value is one of following string:
        NETWORK, KEYBOARD, MOUSE, VIDEO, USB, IDE, SCSI, RAID, MODEM, SCANNER
        CAPTURE, AUDIO, FIREWIRE, SOCKET, CDROM, HD, FLOPPY, TAPE, PRINTER, OTHER
        or None if it is neither PCI nor USB device.
    """
    (base_class, sub_class) = _parse_pci_class(_get_device_property(device, 'PCI_CLASS'))
    subsystem = device.subsystem

    # network devices
    if base_class == PCI_BASE_CLASS_NETWORK:
        return 'OTHER' # if set as 'NETWORK' it will not display in HW tab

    # input devices
    # pci
    if base_class == PCI_BASE_CLASS_INPUT:
        if sub_class == PCI_CLASS_INPUT_KEYBOARD:
            return 'KEYBOARD'
        elif sub_class == PCI_CLASS_INPUT_MOUSE:
            return 'MOUSE'
    # usb
    id_serial = _get_device_property(device, 'ID_SERIAL')
    if id_serial:
        id_serial = id_serial.lower()
        # KEYBOARD <-- do this before mouse, some keyboards have built-in mice
        if 'keyboard' in id_serial:
            return 'KEYBOARD'
        # MOUSE
        if 'mouse' in id_serial:
            return 'MOUSE'

    if base_class:      # PCI Devices
        if base_class == PCI_BASE_CLASS_DISPLAY:
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
            elif sub_class == PCI_CLASS_STORAGE_FLOPPY:
                return 'FLOPPY'
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

    if subsystem == 'block':
        if _get_device_property(device, 'ID_CDROM') or (
            _get_device_property(device, 'ID_TYPE') and _get_device_property(device, 'ID_TYPE') == 'cd'):
            return 'CDROM'
        else:
            return 'HD'
    elif subsystem == 'sound':
        return 'AUDIO'

    if subsystem =='scsi':
        if device.device_type =='scsi_device':
            dev_type = _get_scsi_dev_type(device)
            if dev_type == 0 or dev_type == 14:
                return 'HD'
            elif dev_type == 1:
                return 'TAPE'
            elif dev_type == 5:
                return 'CDROM'
            else:
                return 'OTHER'
    # PRINTER
    m = re.search('.*/lp\d+$', device.sys_path)
    if m:
        return 'PRINTER'

    if subsystem == 'scsi':
        return 'SCSI'

    # Catchall for specific devices, only do this after all the others
    if subsystem == 'pci' or subsystem == 'usb':
        return 'OTHER'

    # No class found
    return None

def _get_device_desc(device):
    """ Return human readable description of device. """
    subsystem = device.subsystem
    command = None
    result = None
    if subsystem == 'pci':
        (vendor_id, device_id) = _get_device_property(device, 'PCI_ID').split(':')
        pci = PCI()
        result = "%s|%s" % (pci.get_vendor(vendor_id), pci.get_device(vendor_id, device_id))
    elif subsystem == 'usb':
        vendor_id = _get_device_property(device, 'ID_VENDOR_ID')
        usb = USB()
        if vendor_id:
            result = "%s|%s" % (usb.get_vendor(vendor_id), usb.get_device(vendor_id, _get_device_property(device, 'ID_MODEL_ID')))
        elif device.device_type == 'usb_interface':
            if device.driver == 'usbhid':
                result = 'USB HID Interface'
            elif device.driver == 'hub':
                result = 'USB Hub Interface'
            else:
                result = 'USB Interface'
        elif device.device_type == 'usb_device' and _get_device_property(device, 'PRODUCT'):
            (vendor_id, model_id) = _get_device_property(device, 'PRODUCT').split('/')[:2]
            # left pad it with 0 to 4 digits
            vendor_id = '%.4x' % int(vendor_id, 16)
            model_id = '%.4x' % int(model_id, 16)
            result = "%s|%s" % (usb.get_vendor(vendor_id), usb.get_device(vendor_id, model_id))
    elif subsystem == 'block':
        result = _get_device_property(device, 'ID_MODEL')
    if result:
        return result
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

def _get_scsi_dev_type(device):
    """ Return SCSI type of device in raw format as presented in /sys/...devpath../type """
    try:
        f = open("%s/type" % device.sys_path, 'r')
    except IOError:
        return -1
    result = f.readline()
    f.close()
    return result
