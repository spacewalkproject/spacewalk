#
# Copyright (c) 2008 Red Hat, Inc.
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
# This module exposes the SatelliteCert class, used for parsing a satellite
# certificate
#

import string
from xml.dom.minidom import parseString
from xml.sax import SAXParseException

class ParseException(Exception):
    pass

# Generic class to represent items (like channel families)
class Item:
    # Name to be displayed by repr()
    pretty_name = None
    # Attribute name in the parent class
    attribute_name = None
    # Mapping from XML to local storage
    attributes = {}
    def __init__(self, node=None):
        if not node:
            return
        for attr_name, storage_name in self.attributes.items():
            attr = node.getAttribute(attr_name)
            # Make sure we stringify the attribute - it may get out as unicode
            setattr(self, storage_name, attr)

    def __repr__(self):
        return "<%s; %s>" % (self.pretty_name,
            string.join(
                map(lambda x, s=self: '%s="%s"' % (x, getattr(s, x)), 
                    self.attributes.values()),
                ', '
            )
        )
        
        
class ChannelFamily(Item):
    pretty_name = "channel family"
    attribute_name = 'channel_families'
    attributes = {'family' : 'name', 'quantity' : 'quantity', 'flex' : 'flex' }

class Slots:
    _db_label = None
    _slot_name = None
    def __init__(self, quantity):
        self.quantity = quantity

    def get_quantity(self):
        return self.quantity

    def get_db_label(self):
        "Returns the label of this type of slot in the database"
        return self._db_label

    def get_slot_name(self):
        """Returns the name of the slot, used by
        rhn_entitlements.modify_org_service"""
        return self._slot_name

class UpdateSlots(Slots):
    _db_label = 'sw_mgr_entitled'

class ManagementSlots(Slots):
    _db_label = 'enterprise_entitled'
    _slot_name = 'enterprise'

class ProvisioningSlots(Slots):
    _db_label = 'provisioning_entitled'
    _slot_name = 'provisioning'

# Slots for virt entitlements support

class VirtualizationSlots(Slots):
    _db_label = 'virtualization_host'
    _slot_name = 'virtualization'

class VirtualizationPlatformSlots(Slots):
    _db_label = 'virtualization_host_platform'
    _slot_name = 'virtualization_platform'

# NonLinux slots are gone - misa 20050527

class MonitoringSlots(Slots):
    _db_label = 'monitoring_entitled'
    _slot_name = 'monitoring'

class SatelliteCert:

    """Satellite certificate class
    Usage: 
    c = SatelliteCert()
    c.load('<rhn-cert><rhn-cert-field name="owner">John Doe</rhn-cert-field></rhn-cert>')
    print c.owner
    """

    fields_scalar = ['product', 'owner', 'issued', 'expires', 'slots',
                     'provisioning-slots', 'nonlinux-slots',
                     'monitoring-slots', 'virtualization_host', 
                     'virtualization_host_platform', 'satellite-version',
                     'generation', ]
    fields_list = { 'channel-families' : ChannelFamily }

    #datesFormat_cert = '%a %b %d %H:%M:%S %Y' ## OLD CERT FORMAT
    datesFormat_cert = '%Y-%m-%d %H:%M:%S'
    datesFormat_db =   '%Y-%m-%d %H:%M:%S'

    def __init__(self):
        for f in self.fields_scalar:
            setattr(self, f, None)
        for f in self.fields_list.values():
            setattr(self, f.attribute_name, [])
        self.signature = None
        self._slots = {}

    def load(self, s):
        try:
            self._load(s)
        except SAXParseException:
            raise ParseException
        # Now represent the slots in a more meaningful way
        self._slots.clear()
        for slot_name, (slot_attr, factory) in self._slot_maps.items():
            quantity = getattr(self, slot_attr)
            self._slots[slot_name] = factory(quantity)
            
        return self

    def _load(self, s):
        dom_element = parseString(s)
        certs = dom_element.getElementsByTagName("rhn-cert")
        if not certs:
            self._root = None
        else:
            self._root = certs[0]
        for child in self._root.childNodes:
            if child.nodeType != child.ELEMENT_NODE:
                # Probably white space
                continue
            if child.nodeName == 'rhn-cert-field':
                field_name = child.getAttribute("name")
                if not field_name:
                    # XXX Bogus
                    continue
                if field_name in self.fields_scalar:
                    val = get_text(child)
                    if not val:
                        continue
                    setattr(self, field_name, val)
                    continue
                if self.fields_list.has_key(field_name):
                    val = self.fields_list[field_name](child)
                    l = getattr(self, val.attribute_name)
                    l.append(val)
            elif child.nodeName == 'rhn-cert-signature':
                self.signature = get_text(child)
        # Python's docs say: When you are finished with a DOM, you should
        # clean it up. This is necessary because some versions of Python do
        # not support garbage collection of objects that refer to each other
        # in a cycle. Until this restriction is removed from all versions of
        # Python, it is safest to write your code as if cycles would not be
        # cleaned up.
        dom_element.unlink()

    _slot_maps = {
        'management'              : ('slots', ManagementSlots),
        'provisioning'            : ('provisioning-slots', ProvisioningSlots),
        'monitoring'              : ('monitoring-slots', MonitoringSlots),
        'virtualization'          : ('virtualization_host', VirtualizationSlots),
        'virtualization_platform' : ('virtualization_host_platform', VirtualizationPlatformSlots)
    }
    def get_slots(self, slot_type):
        if not self._slots.has_key(slot_type):
            raise AttributeError(slot_type)
        return self._slots[slot_type]

    def get_slot_types(self):
        return self._slot_maps.keys()

    def lookup_slot_by_db_label(self, db_label):
        # Given a string like 'sw_mgr_entitled', returns a string 'management'
        for label, (slot_name, slot_class) in self._slot_maps.items():
            if slot_class._db_label == db_label:
                return label
        return None

def get_text(node):
    return string.join(
        map(lambda x: x.data, 
            filter(lambda x: x.nodeType == x.TEXT_NODE, node.childNodes)
        ), "")

if __name__ == '__main__':
    c = SatelliteCert()
    c.load(open("cert").read())
    print c.issued
