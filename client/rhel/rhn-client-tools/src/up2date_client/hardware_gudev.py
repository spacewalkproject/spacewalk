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
	pass

def get_computer_info:
	""" Return dictionaries with keys (values are provided as example):
		'system.formfactor': 'unknown'
		'system.kernel.version': '2.6.18-128.1.6.el5xen'
           	'system.kernel.machine': 'i686'
		'system.kernel.name': 'Linux'
	"""
	pass
