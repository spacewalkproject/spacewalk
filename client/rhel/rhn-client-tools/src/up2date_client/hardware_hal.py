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

""" Get hardware info using HAL """

from haltree import HalTree, HalDevice
import dbus

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

PCI_BASE_CLASS_INPUT =          9
PCI_CLASS_INPUT_KEYBOARD =      0
PCI_CLASS_INPUT_PEN =           1
PCI_CLASS_INPUT_MOUSE =         2
PCI_CLASS_INPUT_SCANNER =       3
PCI_CLASS_INPUT_GAMEPORT =      4
PCI_CLASS_INPUT_OTHER =         80

PCI_BASE_CLASS_SERIAL =         12
PCI_CLASS_SERIAL_FIREWIRE =     0
PCI_CLASS_SERIAL_ACCESS =       1
PCI_CLASS_SERIAL_SSA =          2
PCI_CLASS_SERIAL_USB =          3
PCI_CLASS_SERIAL_FIBER =        4
PCI_CLASS_SERIAL_SMBUS =        5

# read_hal()
#
# This reads in all the properties for each device from HAL, storing the
# property names & values into a dict.  A list of dicts is returned.
#
# This only works on newer versions of dbus & HAL (as found in RHEL5)
def read_hal():
    ret = []
    bus = dbus.SystemBus()

    hal_manager_obj = bus.get_object('org.freedesktop.Hal',
        '/org/freedesktop/Hal/Manager')
    hal_manager = dbus.Interface(hal_manager_obj,
        'org.freedesktop.Hal.Manager')

    device_list = hal_manager.GetAllDevices()
    hal_tree = HalTree()
    for udi in device_list:
        device_obj = bus.get_object ('org.freedesktop.Hal', udi)
        device = dbus.Interface(device_obj, 'org.freedesktop.Hal.Device')

        properties = device.GetAllProperties()

        haldev = HalDevice(properties)
        hal_tree.add(haldev)

    kudzu_list = process_hal_nodes(hal_tree.head)
    return kudzu_list

    # Recursive function, does all the dirty work for add_hal_hardware
def process_hal_nodes(node):
    kudzu_list = []
    node.classification = classify_hal(node)
    if node.classification:
        parent = node.parent
        dev = {}
        dev['class'] = node.classification
        #get bus
        dev['bus'] = str(get_device_bus(node))

        #get scsi info
        if dev['bus'] == 'scsi':
            if parent.properties.has_key('scsi.host'):
                dev['prop1'] = parent.properties['scsi.host']
            if parent.properties.has_key('scsi.target'):
                dev['prop2'] = parent.properties['scsi.target']
            if parent.properties.has_key('scsi.bus'):
                dev['prop3'] = parent.properties['scsi.bus']
            if parent.properties.has_key('scsi.lun'):
                dev['prop4'] = parent.properties['scsi.lun']


        dev['driver'] = str(get_device_driver(node))

        device_path = get_device_path(node)
        if device_path:
            dev['device'] = str(device_path)

        dev['desc'] = str(get_device_description(node))

        dev['pciType'] = str(get_device_pcitype(node))

        dev['detached'] = 0
        kudzu_list.append(dev)

    for child in node.children:
        child_list = process_hal_nodes(child)
        kudzu_list.extend(child_list)

    return kudzu_list

def classify_hal(node):
    # NETWORK
    if node.properties.has_key('net.interface'):
        return 'NETWORK'

    if node.properties.has_key('info.product') and node.properties.has_key('info.category'):
        if node.properties['info.category'] == 'input':
            # KEYBOARD <-- do this before mouse, some keyboards have built-in mice
            if 'keyboard' in node.properties['info.product'].lower():
                return 'KEYBOARD'
            # MOUSE
            if 'mouse' in node.properties['info.product'].lower():
                return 'MOUSE'

    if node.properties.has_key('pci.device_class'):
        #VIDEO
        if node.properties['pci.device_class'] == PCI_BASE_CLASS_DISPLAY:
            return 'VIDEO'
        #USB
        if (node.properties['pci.device_class'] ==  PCI_BASE_CLASS_SERIAL
                and node.properties['pci.device_subclass'] == PCI_CLASS_SERIAL_USB):
            return 'USB'

        if node.properties['pci.device_class'] == PCI_BASE_CLASS_STORAGE:
            #IDE
            if node.properties['pci.device_subclass'] == PCI_CLASS_STORAGE_IDE:
                return 'IDE'
            #SCSI
            if node.properties['pci.device_subclass'] == PCI_CLASS_STORAGE_SCSI:
                return 'SCSI'
            #RAID
            if node.properties['pci.device_subclass'] == PCI_CLASS_STORAGE_RAID:
                return 'RAID'
        #MODEM
        if (node.properties['pci.device_class'] == PCI_BASE_CLASS_COMMUNICATION
                and node.properties['pci.device_subclass'] == PCI_CLASS_COMMUNICATION_MODEM):
            return 'MODEM'
        #SCANNER
        if (node.properties['pci.device_class'] == PCI_BASE_CLASS_INPUT
                and node.properties['pci.device_subclass'] == PCI_CLASS_INPUT_SCANNER):
            return 'SCANNER'

        if node.properties['pci.device_class'] == PCI_BASE_CLASS_MULTIMEDIA:
            #CAPTURE -- video capture card
            if node.properties['pci.device_subclass'] == PCI_CLASS_MULTIMEDIA_VIDEO:
                return 'CAPTURE'
            #AUDIO
            if node.properties['pci.device_subclass'] == PCI_CLASS_MULTIMEDIA_AUDIO:
                return 'AUDIO'

        #FIREWIRE
        if (node.properties['pci.device_class'] == PCI_BASE_CLASS_SERIAL
                and node.properties['pci.device_subclass'] == PCI_CLASS_SERIAL_FIREWIRE):
            return 'FIREWIRE'
        #SOCKET -- PCMCIA yenta socket stuff
        if (node.properties['pci.device_class'] == PCI_BASE_CLASS_BRIDGE
                and (node.properties['pci.device_subclass'] == PCI_CLASS_BRIDGE_PCMCIA
                or node.properties['pci.device_subclass'] == PCI_CLASS_BRIDGE_CARDBUS)):
            return 'SOCKET'

    if node.properties.has_key('storage.drive_type'):
        #CDROM
        if node.properties['storage.drive_type'] == 'cdrom':
            return 'CDROM'
        #HD
        if node.properties['storage.drive_type'] == 'disk':
            return 'HD'
         #FLOPPY
        if node.properties['storage.drive_type'] == 'floppy':
            return 'FLOPPY'
        #TAPE
        if node.properties['storage.drive_type'] == 'tape':
            return 'TAPE'

    #PRINTER
    if node.properties.has_key('printer.product'):
        return 'PRINTER'

    #Catchall for specific devices, only do this after all the others
    if (node.properties.has_key('pci.product_id') or
            node.properties.has_key('usb.product_id')):
        return 'OTHER'

    # No class found
    return None

def get_device_bus(node):
    if node.properties.has_key('storage.bus'):
        bus = node.properties['storage.bus']
    elif node.properties.has_key('info.bus'):
        if node.properties['info.bus'] == 'platform':
            bus = 'MISC'
        else:
            bus = node.properties['info.bus']
    else:
        bus = 'MISC'

    return bus

def get_device_driver(node):
    if node.properties.has_key('info.linux.driver'):
        driver = node.properties['info.linux.driver']
    elif node.properties.has_key('net.linux.driver'):
        driver = node.properties['net.linux.driver']
    else:
        driver = 'unknown'

    return driver

def get_device_path(node):
    """
    Return the device file path.

    As kudzu did not return a string with the /dev/ prefix,
    this function will not, either.
    RHN's DB has a limit of 16 characters for the device path.
    If the path is longer than that, return None.
    If no device path is found, return None.
    """
    dev = None

    if node.properties.has_key('block.device'):
        dev = node.properties['block.device']
    elif node.properties.has_key('linux.device_file'):
        dev = node.properties['linux.device_file']
    elif (node.classification == 'NETWORK'
            and node.properties.has_key('net.interface')):
        dev = node.properties['net.interface']

    if dev:
        if dev.startswith('/dev/'):
            dev = dev[5:]
        if len(dev) > 16:
            dev = None

    return dev

def get_device_description(node):
    if (node.properties.has_key('info.vendor')
            and node.properties.has_key('info.product')):
        desc = node.properties['info.vendor'] + '|' +  node.properties['info.product']
    elif (node.properties.has_key('info.vendor')):
        desc = node.properties['info.vendor']
    elif node.properties.has_key('info.product'):
        desc =  node.properties['info.product']
    else:
        desc = ""

    return desc

def get_device_pcitype(node):
    PCI_TYPE_PCMCIA = 2
    PCI_TYPE_PCI = 1
    PCI_TYPE_NOT_PCI = -1

    if (node.properties.has_key('info.bus')
            and node.properties['info.bus'] == 'pci'):
        parent = node.parent
        if (parent.properties.has_key('pci.device_class')
                and (parent.properties['pci.device_class'] == 6
                and (parent.properties['pci.device_subclass'] == 5
                or parent.properties['pci.device_subclass'] == 7))):
            pcitype = PCI_TYPE_PCMCIA
        else:
            pcitype = PCI_TYPE_PCI
    else:
        pcitype = PCI_TYPE_NOT_PCI

    return pcitype

def get_device_property(device, property_name):
    """ Return a hal device property, or None if it does not exist. """
    if device.PropertyExists(property_name):
        # Convert from unicode to ascii in case the server can't handle it.
        return str(device.GetProperty(property_name))
    else:
        return None

def get_hal_computer():
    bus = dbus.SystemBus()
    computer_obj = bus.get_object("org.freedesktop.Hal",
        "/org/freedesktop/Hal/devices/computer")
    computer = dbus.Interface(computer_obj, "org.freedesktop.Hal.Device")

    return computer

def check_hal_dbus_status():
    # check if hal and messagebus are running, if not warn the user
    import commands
    hal_status, msg = commands.getstatusoutput('/etc/init.d/haldaemon status')
    dbus_status, msg = commands.getstatusoutput('/etc/init.d/messagebus status')
    return hal_status, dbus_status


