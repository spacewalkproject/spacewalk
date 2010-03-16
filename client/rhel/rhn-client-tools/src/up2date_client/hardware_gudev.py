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
			'bus': 		subsystem,
			'driver':	device.get_driver(),
			'pciType':  _clasify_pci_type(subsystem),
			'detached':	'0', # always zero?
			'class':	_clasify_class(device)
			'desc':		_get_device_desc(device),
		}
		if subsystem == 'block':
			result_item['device'] = device.get_property('DEVNAME')
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
	return #FIXME

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

