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
# This file contains all the logic necessary to manipulate Hardware
# items - load, reload, instanciate and save
#

import string

from common import UserDictCase, log_debug, log_error, rhnFault, Traceback
from server import rhnSQL

# this is a class we use to get the mapping for a kudzu entry
def kudzu_mapping(dict = None):
    # This is the generic mapping we need    
    mapping = {
        'desc'        : 'description',
        }
    # error handling if we get passed weird stuff.
    if not dict:
        return mapping
    if not type(dict) == type({}) and not isinstance(dict, UserDictCase):
        return mapping   
    hw_bus = dict.get("bus")
    # we need to have a bus type to be able to continue    
    if not hw_bus:
        return mapping
    hw_bus = string.lower(hw_bus)
    extra = {}
    if hw_bus == "ddc":
        extra = {
            "id" : None,
            "horizsyncmin"   : "prop1",
            "horizsyncmax"   : "prop2",
            "vertrefreshmin" : "prop3",
            "vertrefreshmax" : "prop4",
            "modes" : None,
            "mem" : None,
            }
    elif hw_bus == "ide":
        extra = {
            "physical"    : "prop1",
            "logical"     : "prop2",
            }
    elif hw_bus in ["isapnp", "isa"]:
        extra = {
            "pdeviceid" : "prop1",
            "deviceid"  : "prop2",
            "compat"    : "prop3",
            "native"    : None,
            "active"    : None,
            "cardnum"   : None, # XXX: fix me
            "logdev"    : "prop4",
            "io"        : "prop2",
            "irq"       : "prop1",
            "dma"       : "prop3",
            "mem"       : "prop4",
            }
    elif hw_bus == "keyboard":
        extra = {}
    elif hw_bus == "psaux":
        extra = {}
    elif hw_bus == "parallel":
        extra = {
            'pnpmfr'      : 'prop1',
            'pnpdesc'     : 'prop2',
            'pnpmodel'    : 'prop3',
            'pnpmodes'    : 'prop4',
            'pinfo'       : None,
            'pinfo.xres'  : None,
            'pinfo.yres'  : None,
            'pinfo.color' : None,
            'pinfo.ascii' : None,
            }
    elif hw_bus == "pci":
        extra = {
            'vendorid'    : 'prop1',
            'deviceid'    : 'prop2',
            'subvendorid' : 'prop3',
            'subdeviceid' : 'prop4',
            'network.hwaddr'    : None,
            'pcibus'      : None,
            'pcidev'      : None,
            'pcifn'       : None,
            'pcidom'      : None,
        }
    elif hw_bus == "sbus":
        extra = {
            "monitor" : "prop1",
            "width"   : "prop2",
            "height"  : "prop3",
            "freq"    : "prop4",
            }
    elif hw_bus == "scsi":
        extra = {
            'host'        : 'prop1',
            'id'          : 'prop2',
            'channel'     : 'prop3',
            'lun'         : 'prop4',
            'generic'     : None,
            }
    elif hw_bus == "serial":
        extra = {
            'pnpmfr'      : 'prop1',
            'pnpdesc'     : 'prop2',
            'pnpmodel'    : 'prop3',
            'pnpcompat'   : "prop4",
            }
    elif hw_bus == "usb":
        extra = {
            "vendorid"          : "prop1",
            "deviceid"          : "prop2",
            "usbclass"          : "prop3",
            "usbbus"            : "prop4",
            "usblevel"          : "pciType",
            "usbdev"            : None,
            "usbprod"           : None,
            "usbsubclass"       : None,
            "usbprotocol"       : None,
            "usbport"           : None,          
            "usbmfr"            : None,
            "productname"       : None,
            "productrevision"   : None,
            'network.hwaddr'    : None,
            }
    elif hw_bus == "firewire":
        extra = {
            'vendorid'    : 'prop1',
            'deviceid'    : 'prop2',
            'subvendorid' : 'prop3',
            'subdeviceid' : 'prop4',
            }            
    elif hw_bus == 'pcmcia':
        extra = {
            'vendorid'      : 'prop1',
            'deviceid'      : 'prop2',
            'function'      : 'prop3',
            'slot'          : 'prop4',
            'network.hwaddr'    : None,
        }
    mapping.update(extra)
    return mapping

def cleanse_ip_addr(ip_addr):
    # Cleans up things like 127.00.00.01
    if ip_addr is None:
        return None
    # Make sure it's a string
    ip_addr = str(ip_addr)
    # If the ipaddr is empty, jus return empty str
    if not len(ip_addr):
        return ''
    arr = ip_addr.split('.')
    # lstrip will remove all leading zeros; if multiple zeros are present, it
    # would remove too much, hence the or '0' here.
    return '.'.join([ x.lstrip('0') or '0' for x in arr ])
    
# A generic device class
class GenericDevice:
    def __init__(self, table):
        self.id = 0
        self.status = 1 # just added
        self.__table = table
        self.data = {}
        # default to the hardware seq...
        self.sequence = "rhn_hw_dev_id_seq"
    def getid(self):
        if self.id == 0:
            self.id = rhnSQL.Sequence(self.sequence)()
        return self.id
    def must_save(self):
        if self.id == 0 and self.status == 2: # deleted new item
            return 0
        if self.status == 0: # original item, unchanged            
            return 0
        return 1
    # save data in the rhnDevice
    def save(self, sysid):
        log_debug(4, self.__table, self.status, self.data)
        if not self.must_save():
            return 0
        t = rhnSQL.Table(self.__table, "id")
        # check if we have to delete
        if self.status == 2 and self.id:
            # delete the entry
            del t[self.id]
            return 0
        # make sure we have a device id
        devid = self.getid()
        for k in self.data.keys():
            if self.data[k] is None:
                del self.data[k]
        self.data["server_id"] = sysid
        t[devid] = self.data
        self.status = 0 # now it is saved        
        return 0
    # reload from rhnDevice based on devid
    def reload(self, devid):
        if not devid:
            return -1
        self.__init__(self.__table)
        t = rhnSQL.Table(self.__table, "id")
        self.data = t[devid]
        # clean up fields we don't want
        for k in ["created", "modified"]:
            if self.data.has_key(k):
                del self.data[k]
        self.id = devid
        self.status = 0
        return 0

# This is the base Device class that supports instantiation from a
# dictionarry. the __init__ takes the dictionary as its argument,
# together with a list of valid fields to recognize and with a mapping
# for dictionary keys into valid field names for self.data
#
# The fields are required to know what fields we have in the
# table. The mapping allows transformation from whatever comes in to
# valid fields in the table Looks complicated but it isn't -- gafton
class Device(GenericDevice):
    def __init__(self, table, fields, dict = None, mapping = None):
        GenericDevice.__init__(self, table)
        x = {}
        for k in fields:
            x[k] = None
        self.data = UserDictCase(x)
        if dict is None:
            return
        # make sure we get a UserDictCase to work with
        if type(dict) == type({}):
            dict = UserDictCase(dict)
        if mapping is None or type(mapping) == type({}):
            mapping = UserDictCase(mapping)
        if not isinstance(dict, UserDictCase) or \
           not isinstance(mapping, UserDictCase):
            log_error("Argument passed is not a dictionary", dict, mapping)
            raise TypeError("Argument passed is not a dictionary",
                            dict, mapping)
        # make sure we have a platform       
        for k in dict.keys():                        
            if self.data.has_key(k):
                self.data[k] = dict[k]
                continue
            if mapping.has_key(k):
                # the mapping dict might tell us to lose some fields
                if mapping[k] is not None:
                    self.data[mapping[k]] = dict[k]
            else:
                log_error("Unknown HW key =`%s'" % k,
                          dict.dict(), mapping.dict())
                # The try-except is added just so that we can send e-mails
                try:
                    raise KeyError("Don't know how to parse key `%s''" % k,
                                   dict.dict())
                except:
                    Traceback(mail=1)
                    # Ignore this key
                    continue
        # clean up this data
        try:
            for k in self.data.keys():
                if type(self.data[k]) == type("") and len(self.data[k]):
                    self.data[k] = string.strip(self.data[k])
                    if not len(self.data[k]):
                        continue
                    if self.data[k][0] == '"' and self.data[k][-1] == '"':
                        self.data[k] = self.data[k][1:-1]
        except IndexError:
            raise IndexError, "Can not process data = %s, key = %s" % (
                repr(self.data), k)
                
                                
# A more specific device based on the Device class
class HardwareDevice(Device):
    def __init__(self, dict = None):
        fields = ['class', 'bus', 'device', 'driver', 'detached',
                  'description', 'pcitype', 'prop1', 'prop2',
                  'prop3', 'prop4']
        # get a processed mapping
        mapping = kudzu_mapping(dict)
        # ... and do little to no work
        Device.__init__(self, "rhnDevice", fields, dict, mapping)
        # use the hardware id sequencer
        self.sequence = "rhn_hw_dev_id_seq"
        
# A class for handling CPU - mirrors the rhnCPU structure
class CPUDevice(Device):
    def __init__(self, dict = {}):
        fields = ['cpu_arch_id',  'architecture', 'bogomips', 'cache',
                  'family', 'mhz', 'stepping', 'flags', 'model',
                  'version', 'vendor', 'nrcpu', 'acpiVersion',
                  'apic', 'apmVersion', 'chipset']
        mapping = {
            "bogomips" : "bogomips",
            "cache" : "cache",
            "model" : "model",
            "platform" : "architecture",
            "type" : "vendor",
            "model_rev" : "stepping",
            "model_number" : "family",
            "model_ver" : "version",
            "model_version" : "version",
            "speed" : "mhz",
            "count" : "nrcpu",
            "other" : "flags",
            "desc" : None,
            'class' : None,
            }
        # now instantiate this class
        Device.__init__(self, "rhnCPU", fields, dict, mapping)
        if self.data.get("cpu_arch_id") is not None:
            return # all fine, we have the arch
        # if we don't have an architecture, guess it        
        if not self.data.has_key("architecture"):
            log_error("hash does not have a platform member: %s" % dict)
            raise AttributeError, "Expected a hash value for member `platform'"
        # now extract the arch field, which has to come out of rhnCpuArch 
        arch = self.data["architecture"]
        row = rhnSQL.Table("rhnCpuArch", "label")[arch]
        if row is None or not row.has_key("id"):
            log_error("Can not find arch %s in rhnCpuArch" % arch)
            raise AttributeError, "Invalid architecture for CPU: `%s'" % arch
        self.data["cpu_arch_id"] = row["id"]
        del self.data["architecture"]
        # use our own sequence
        self.sequence = "rhn_cpu_id_seq"
        if self.data.has_key("nrcpu"): # make sure this is a number
            try:
                self.data["nrcpu"] = int(self.data["nrcpu"])
            except:
                self.data["nrcpu"] = 1
            if self.data["nrcpu"] == 0:
                self.data["nrcpu"] = 1
                
# This is a wrapper class for the Network Information (rhnServerNetwork)
class NetworkInformation(Device):
    def __init__(self, dict = None):
        fields = ["hostname", "ipaddr"]
        mapping = { 'class' : None }
        Device.__init__(self, "rhnServerNetwork", fields, dict, mapping)
        # use our own sequence
        self.sequence = "rhn_server_net_id_seq"
        # bugzilla: 129840 kudzu (rhpl) will sometimes pad octets
        # with leading zeros, causing confusion; clean those up
        self.data['ipaddr'] = cleanse_ip_addr(self.data['ipaddr'])


class NetIfaceInformation(Device):
    key_mapping = {
        'ipaddr'    : 'ip_addr',
        'hwaddr'    : 'hw_addr',
        'module'    : 'module',
        'netmask'   : 'netmask',
        'broadcast' : 'broadcast',
    }
    def __init__(self, dict=None):
        self.ifaces = {}
        self.db_ifaces = []
        if not dict:
            return
        for name, info in dict.items():
            if name == 'class':
                # Ignore it
                continue
            if not isinstance(info, type({})):
                raise rhnFault(53, "Unexpected format for interface %s" %
                    name)
            vdict = {}
            for key, mapping in self.key_mapping.items():
                # Look at the mapping first; if not found, look for the key
                if info.has_key(mapping):
                    k = mapping
                else:
                    k = key
                if not info.has_key(k):
                    raise rhnFault(53, "Unable to find required field %s"
                            % key)
                val = info[k]
                if mapping in ['ip_addr', 'netmask', 'broadcast']:
                    # bugzilla: 129840 kudzu (rhpl) will sometimes pad octets
                    # with leading zeros, causing confusion; clean those up
                    val = cleanse_ip_addr(val)
                vdict[mapping] = val
            self.ifaces[name] = vdict

    def save(self, server_id):
        log_debug(4, self.ifaces)
        self.reload(server_id)
        log_debug(4, "Interfaces in DB", self.db_ifaces)

        # Compute updates, deletes and inserts
        inserts = []
        updates = []
        deletes = []

        ifaces = self.ifaces.copy()
        for iface in self.db_ifaces:
            name = iface['name']
            if not self.ifaces.has_key(name):
                # To be deleted
                deletes.append({'server_id' : server_id, 'name' : name})
                continue

            uploaded_iface = ifaces[name]
            del ifaces[name]
            if _hash_eq(uploaded_iface, iface):
                # Same value
                continue
            uploaded_iface.update({'name' : name, 'server_id' : server_id})
            updates.append(uploaded_iface)

        # Everything else in self.ifaces has to be inserted
        for name, iface in ifaces.items():
            iface['name'] = name
            iface['server_id'] = server_id
            inserts.append(iface)

        log_debug(4, "Deletes", deletes)
        log_debug(4, "Updates", updates)
        log_debug(4, "Inserts", inserts)

        self._delete(deletes)
        self._update(updates)
        self._insert(inserts)

        return 0

    def _insert(self, params):
        q = """insert into rhnServerNetInterface
            (%s) values (%s)"""

        columns = self.key_mapping.values() + ['server_id', 'name']
        columns.sort()
        bind_params = string.join(map(lambda x: ':' + x, columns), ", ")
        h = rhnSQL.prepare(q % (string.join(columns, ", "), bind_params))
        return self._dml(h, params)

    def _delete(self, params):
        q = """delete from rhnServerNetInterface
            where %s"""

        columns = ['server_id', 'name']
        wheres = map(lambda x: '%s = :%s' % (x, x), columns) 
        h = rhnSQL.prepare(q % string.join(wheres, " and "))
        return self._dml(h, params)

    def _update(self, params):
        q = """update rhnServerNetInterface
            set %s
            where %s"""

        wheres = ['server_id', 'name']
        wheres = map(lambda x: '%s = :%s' % (x, x), wheres) 
        wheres = string.join(wheres, " and ")

        updates = self.key_mapping.values()
        updates.sort()
        updates = map(lambda x: '%s = :%s' % (x, x), updates) 
        updates = string.join(updates, ", ")
        
        h = rhnSQL.prepare(q % (updates, wheres))
        return self._dml(h, params)

    def _dml(self, statement, params):
        log_debug(5, params)
        if not params:
            return 0
        params = _transpose(params)
        rowcount = apply(statement.executemany, (), params)
        log_debug(5, "Affected rows", rowcount)
        return rowcount
            
    def reload(self, server_id):
        h = rhnSQL.prepare("""
            select * 
            from rhnServerNetInterface 
            where server_id = :server_id
        """)
        h.execute(server_id=server_id)
        self.db_ifaces = []
        while 1:
            row = h.fetchone_dict()
            if not row:
                break
            hval = { 'name' : row['name'], 'server_id' : server_id }
            for key in self.key_mapping.values():
                hval[key] = row[key]
            self.db_ifaces.append(hval)

        self.status = 0
        return 0

# Compares two hashes and return 1 if the first is a subset of the second
def _hash_eq(h1, h2):
    log_debug(5, h1, h2)
    for k, v in h1.items():
        if not h2.has_key(k):
            return 0
        if h2[k] != v:
            return 0
    return 1

# Transpose the array of hashes into a hash of arrays
def _transpose(hasharr):
    if not hasharr:
        return {}
    keys = hasharr[0].keys()
    result = {}
    for k in keys:
        result[k] = []

    for hval in hasharr:
        for k in keys:
            result[k].append(hval[k])

    return result

# Memory information
class MemoryInformation(Device):
    def __init__(self, dict = None):
        fields = ["ram", "swap"]
        mapping = { "class" : None }
        Device.__init__(self, "rhnRAM", fields, dict, mapping)
        # use our own sequence
        self.sequence = "rhn_ram_id_seq"
        # Sometimes we get sent a NNNNL number and we need to strip the L
        for k in fields:
            if not self.data.has_key(k):
                continue
            if self.data[k] in [None, "None", ""]:
                self.data[k] = -1
            self.data[k] = str(self.data[k])
            if self.data[k][-1] == 'L':
                self.data[k] = self.data[k][:-1]

# DMI information
class DMIInformation(Device):
    def __init__(self, dict = None):
        fields = ["vendor", "system", "product", "asset", "board",
                  "bios_vendor", "bios_version", "bios_release"]
        mapping = { "class" : None }
        Device.__init__(self, "rhnServerDMI", fields, dict, mapping)
        # use our own sequence
        self.sequence = "rhn_server_dmi_id_seq"

        # deal with hardware with insanely long dmi strings...
        for key, value in self.data.items():
            # Some of the values may be None
            if value and isinstance(value, type("")):
                self.data[key] = value[:256]

# Install information
class InstallInformation(Device):
    def __init__(self, dict = None):
        fields = ['install_method', 'iso_status', 'mediasum']
        mapping = { 
            'class'         : None,
            'installmethod' : 'install_method', 
            'isostatus'     : 'iso_status',
            'mediasum'      : 'mediasum',
        }
        Device.__init__(self, "rhnServerInstallInfo", fields, dict, mapping)
        self.sequence = 'rhn_server_install_info_id_seq'

#### Support for the hardware items
class Hardware:
    def __init__(self):
        self.__hardware = {}
        self.__loaded = 0
        self.__changed = 0

    def hardware_by_class(self, device_class):
        return self.__hardware[device_class]
    
    # add new hardware
    def add_hardware(self, hardware):
        log_debug(4, hardware)
        if not hardware:
            return -1
        if type(hardware) == type({}):
            hardware = UserDictCase(hardware)
        if not isinstance(hardware, UserDictCase):
            log_error("argument type is not  hash: %s" % hardware)
            raise TypeError, "This function requires a hash as an argument"
        # validation is important
        hw_class = hardware.get("class")
        if hw_class is None:
            return -1
        hw_class = string.lower(hw_class)

        class_type = None
        
        if hw_class in ["video", "audio", "audio_hd", "usb", "other", "hd", "floppy",
                        "mouse", "modem", "network", "cdrom", "scsi",
                        "unspec", "scanner", "tape", "capture", "raid",
                        "socket", "keyboard", "printer", "firewire", "ide"]:
            class_type = HardwareDevice
        elif hw_class == "cpu":
            class_type = CPUDevice
        elif hw_class == "netinfo":
            class_type = NetworkInformation
        elif hw_class == "memory":
            class_type = MemoryInformation
        elif hw_class == "dmi":
            class_type = DMIInformation
        elif hw_class == "installinfo":
            class_type = InstallInformation
        elif hw_class == "netinterfaces":
            class_type = NetIfaceInformation
        else:
            log_error("UNKNOWN CLASS TYPE `%s'" % hw_class)
            # Same trick: try-except and raise the exception so that Traceback
            # can send the e-mail
            try:
                raise KeyError, "Unknwon class type `%s' for hardware '%s'" % (
                    hw_class, hardware)
            except:
                Traceback(mail=1)
                return

        # create the new device
        new_dev = class_type(hardware)
        
        if self.__hardware.has_key(class_type):
            _l = self.__hardware[class_type]
        else:
            _l = self.__hardware[class_type] = []
        _l.append(new_dev)
        self.__changed = 1
        return 0
    
    # This function deletes all hardware
    def delete_hardware(self, sysid = None):        
        log_debug(4, sysid)
        if not self.__loaded:
            self.reload_hardware_byid(sysid)            
        hardware = self.__hardware
        if hardware == {}:
            # nothing to delete
            return 0
        self.__changed = 1

        for device_type in hardware.keys():
            for hw in hardware[device_type]:
                hw.status = 2 # deleted
                
            # filter out the hardware that was just added and then
            # deleted before saving
            hardware[device_type] = filter(lambda a: 
                not (a.status == 2 and hasattr(a, "id") and a.id == 0),
                hardware[device_type])
        return 0

    # save the hardware list
    def save_hardware_byid(self, sysid):
        log_debug(3, sysid, "changed = %s" % self.__changed)
        hardware = self.__hardware
        if hardware == {}: # nothing loaded
            return 0
        if not self.__changed:
            return 0
        for device_type, hw_list in hardware.items():
            for hw in hw_list:
                hw.save(sysid)
        self.__changed = 0
        return 0

    # Load a certain hardware class from the database
    def __load_from_db(self, db, DevClass, sysid):
        if not self.__hardware.has_key(DevClass):
            self.__hardware[DevClass] = []
        
        h = rhnSQL.prepare("select * from %s where server_id = :sysid" % db)
        h.execute(sysid = sysid)
        rows = h.fetchall_dict() or []
        
        for device in rows:
            dev_id = device['id']
                
            # get rid of the keys we do not support
            for k in ["server_id", "created", "modified", "id"]:
                if device.has_key(k):
                    del device[k]
            dev = DevClass(device)

            # we know better
            dev.id = dev_id
            dev.status = 0
            self.__hardware[DevClass].append(dev)
        return 0
    
    # load all hardware devices for a server
    def reload_hardware_byid(self, sysid):
        log_debug(4, sysid)
        if not sysid:
            return -1
        self.__hardware = {} # discard what was already loaded
        # load from all hardware databases
        self.__load_from_db("rhnDevice", HardwareDevice, sysid)
        self.__load_from_db("rhnCPU", CPUDevice, sysid)
        self.__load_from_db("rhnServerDMI", DMIInformation, sysid)        
        self.__load_from_db("rhnServerNetwork", NetworkInformation, sysid)        
        self.__load_from_db("rhnRAM", MemoryInformation, sysid)        
        self.__load_from_db("rhnServerInstallInfo", InstallInformation, sysid)

        net_iface_info = NetIfaceInformation()
        net_iface_info.reload(sysid)
        
        self.__hardware[NetIfaceInformation] = []
        self.__hardware[NetIfaceInformation].append(net_iface_info)
        
        # now set the flag
        self.__changed = 0
        self.__loaded = 1
        return 0
