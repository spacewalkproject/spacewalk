#
# Copyright (c) 1999--2015 Red Hat, Inc.
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

# This thing gets the hardware configuraion out of a system
"""Used to read hardware info from kudzu, /proc, etc"""
from socket import gethostname, getaddrinfo, AF_INET, AF_INET6
import socket
import re
import os
import sys
import config
import rhnserver

try:
    import ethtool
    ethtool_present = True
except ImportError:
    sys.stderr.write("Warning: information about network interfaces could not be retrieved on this platform.\n")
    ethtool_present = False

import gettext
t = gettext.translation('rhn-client-tools', fallback=True)
_ = t.ugettext

import dbus
import dmidecode
import up2dateLog

try: # F13 and EL6
    from hardware_gudev import get_devices, get_computer_info
    using_gudev = 1
except ImportError:
    from hardware_hal import check_hal_dbus_status, get_hal_computer, read_hal
    using_gudev = 0

# Some systems don't have the _locale module installed
try:
    import locale
except ImportError:
    locale = None

sys.path.append("/usr/share/rhsm")
try:
    from subscription_manager.hwprobe import Hardware as SubManHardware
    subscription_manager_available = True
except ImportError:
    subscription_manager_available = False

# this does not change, we can cache it
_dmi_data           = None
_dmi_not_available  = 0

def dmi_warnings():
    if not hasattr(dmidecode, 'get_warnings'):
        return None

    return dmidecode.get_warnings()

dmi_warn = dmi_warnings()
if dmi_warn:
    dmidecode.clear_warnings()
    log = up2dateLog.initLog()
    log.log_debug("Warnings collected during dmidecode import: %s" % dmi_warn)

def _initialize_dmi_data():
    """ Initialize _dmi_data unless it already exist and returns it """
    global _dmi_data, _dmi_not_available
    if _dmi_data is None:
        if _dmi_not_available:
            # do not try to initialize it again and again if not available
            return None
        else :
            dmixml = dmidecode.dmidecodeXML()
            dmixml.SetResultType(dmidecode.DMIXML_DOC)
            # Get all the DMI data and prepare a XPath context
            try:
                data = dmixml.QuerySection('all')
                dmi_warn = dmi_warnings()
                if dmi_warn:
                    dmidecode.clear_warnings()
                    log = up2dateLog.initLog()
                    log.log_debug("dmidecode warnings: " % dmi_warn)
            except:
                # DMI decode FAIL, this can happend e.g in PV guest
                _dmi_not_available = 1
                dmi_warn = dmi_warnings()
                if dmi_warn:
                    dmidecode.clear_warnings()
                return None
            _dmi_data = data.xpathNewContext()
    return _dmi_data

def get_dmi_data(path):
    """ Fetch DMI data from given section using given path.
        If data could not be retrieved, returns empty string.
        General method and should not be used outside of this module.
    """
    dmi_data = _initialize_dmi_data()
    if dmi_data is None:
        return ''
    data = dmi_data.xpathEval(path)
    if data != []:
        return data[0].content
    else:
        # The path do not exist
        return ''

def dmi_vendor():
    """ Return Vendor from dmidecode bios information.
        If this value could not be fetch, returns empty string.
    """
    return get_dmi_data('/dmidecode/BIOSinfo/Vendor')

def dmi_system_uuid():
    """ Return UUID from dmidecode system information.
        If this value could not be fetch, returns empty string.
    """
    # if guest was created manualy it can have empty UUID, in this
    # case dmidecode set attribute unavailable to 1
    uuid = get_dmi_data("/dmidecode/SystemInfo/SystemUUID[not(@unavailable='1')]")
    if not uuid:
        uuid = ''
    return uuid

def read_installinfo():
    if not os.access("/etc/sysconfig/installinfo", os.R_OK):
        return {}
    installinfo = open("/etc/sysconfig/installinfo", "r").readlines()
    installdict = {}
    installdict['class'] = "INSTALLINFO"
    for info in installinfo:
        if not len(info):
            continue
        vals = info.split('=')
        if len(vals) <= 1:
            continue
        strippedstring = vals[0].strip()
        vals[0] = strippedstring

        installdict[vals[0]] = ''.join(vals[1:]).strip()
    return installdict

def cpu_count():
    """ returns number of CPU in system

    Beware that it can be different from number of active CPU (e.g. on s390x architecture
    """
    try:
        cpu_dir = os.listdir('/sys/devices/system/cpu/')
    except OSError:
        cpu_dir = []

    re_cpu = re.compile(r"^cpu[0-9]+$")
    return len([i for i in cpu_dir if re_cpu.match(i)])

# get the number of sockets available on this machine
def __get_number_sockets():
    try:
        if subscription_manager_available:
            return SubManHardware().getCpuInfo()['cpu.cpu_socket(s)']
    except:
        pass # something went wrong, let's figure it out ourselves

    number_sockets = 0
    # Try lscpu command if available
    if os.access("/usr/bin/lscpu", os.X_OK):
        try:
            lines = os.popen("/usr/bin/lscpu -p").readlines()
            max_socket_index = -1
            for line in lines:
                if line.startswith('#'):
                    continue
                # get the socket index from the output
                socket_index = int(line.split(',')[2])
                if socket_index > max_socket_index:
                    max_socket_index = socket_index
            if max_socket_index > -1:
                return 1 + max_socket_index
        except:
            pass

    # Next try parsing /proc/cpuinfo
    if os.access("/proc/cpuinfo", os.R_OK):
        try:
            lines = open("/proc/cpuinfo", 'r').readlines()
            socket_ids = set()
            for line in lines:
                if 'physical id' in line:
                    socket_index = int(line.split(':')[1].strip())
                    socket_ids.add(socket_index)
            if len(socket_ids) > 0:
                return len(socket_ids)
        except:
            pass

    # Next try dmidecode
    if os.access("/usr/sbin/dmidecode", os.X_OK):
        try:
            lines = os.popen("/usr/sbin/dmidecode -t processor").readlines()
            count = 0
            for line in lines:
                if 'Processor Information' in line:
                    count += 1
            if count > 0:
                return count
        except:
            pass

    return None

# This has got to be one of the ugliest fucntions alive
def read_cpuinfo():
    def get_entry(a, entry):
        e = entry.lower()
        if not a.has_key(e):
            return ""
        return a[e]

    # read cpu list and return number of cpus and list as dictionary
    def get_cpulist_as_dict(cpulist):
        count = 0
        tmpdict = {}
        for cpu in cpulist.split("\n\n"):
            if not len(cpu):
                continue
            count = count + 1
            if count > 1:
                break # no need to parse rest
            for cpu_attr in cpu.split("\n"):
                if not len(cpu_attr):
                    continue
                vals = cpu_attr.split(":")
                if len(vals) != 2:
                    # XXX: make at least some effort to recover this data...
                    continue
                name, value = vals[0].strip(), vals[1].strip()
                tmpdict[name.lower()] = value
        return tmpdict

    if not os.access("/proc/cpuinfo", os.R_OK):
        return {}

    # Okay, the kernel likes to give us the information we need in the
    # standard "C" locale.
    if locale:
        # not really needed if you don't plan on using atof()
        locale.setlocale(locale.LC_NUMERIC, "C")

    cpulist = open("/proc/cpuinfo", "r").read()
    uname = os.uname()[4].lower()
    count = cpu_count()

    # This thing should return a hwdict that has the following
    # members:
    #
    # class, desc (required to identify the hardware device)
    # count, type, model, model_number, model_ver, model_rev
    # bogomips, platform, speed, cache

    hwdict = { 'class': "CPU",
               "desc" : "Processor",
               }
    if uname[0] == "i" and uname[-2:] == "86" or (uname == "x86_64"):
        # IA32 compatible enough
        tmpdict = get_cpulist_as_dict(cpulist)

        if uname == "x86_64":
            hwdict['platform'] = 'x86_64'
        else:
            hwdict['platform'] = "i386"

        hwdict['count']         = count
        hwdict['type']          = get_entry(tmpdict, 'vendor_id')
        hwdict['model']         = get_entry(tmpdict, 'model name')
        hwdict['model_number']  = get_entry(tmpdict, 'cpu family')
        hwdict['model_ver']     = get_entry(tmpdict, 'model')
        hwdict['model_rev']     = get_entry(tmpdict, 'stepping')
        hwdict['cache']         = get_entry(tmpdict, 'cache size')
        hwdict['bogomips']      = get_entry(tmpdict, 'bogomips')
        hwdict['other']         = get_entry(tmpdict, 'flags')
        mhz_speed               = get_entry(tmpdict, 'cpu mhz')
        if mhz_speed == "":
            # damn, some machines don't report this
            mhz_speed = "-1"
        try:
            hwdict['speed']         = int(round(float(mhz_speed)) - 1)
        except ValueError:
            hwdict['speed'] = -1
    elif uname in["alpha", "alphaev6"]:
        # Treat it as an an Alpha
        tmpdict = get_cpulist_as_dict(cpulist)

        hwdict['platform']      = "alpha"
        hwdict['count']         = get_entry(tmpdict, 'cpus detected')
        hwdict['type']          = get_entry(tmpdict, 'cpu')
        hwdict['model']         = get_entry(tmpdict, 'cpu model')
        hwdict['model_number']  = get_entry(tmpdict, 'cpu variation')
        hwdict['model_version'] = "%s/%s" % (get_entry(tmpdict, 'system type'),
                                             get_entry(tmpdict,'system variation'))
        hwdict['model_rev']     = get_entry(tmpdict, 'cpu revision')
        hwdict['cache']         = "" # pitty the kernel doesn't tell us this.
        hwdict['bogomips']      = get_entry(tmpdict, 'bogomips')
        hwdict['other']         = get_entry(tmpdict, 'platform string')
        hz_speed                = get_entry(tmpdict, 'cycle frequency [Hz]')
        # some funky alphas actually report in the form "462375000 est."
        hz_speed = hz_speed.split()
        try:
            hwdict['speed']         = int(round(float(hz_speed[0]))) / 1000000
        except ValueError:
            hwdict['speed'] = -1
    elif uname in ["ia64"]:
        tmpdict = get_cpulist_as_dict(cpulist)

        hwdict['platform']      = uname
        hwdict['count']         = count
        hwdict['type']          = get_entry(tmpdict, 'vendor')
        hwdict['model']         = get_entry(tmpdict, 'family')
        hwdict['model_ver']     = get_entry(tmpdict, 'archrev')
        hwdict['model_rev']     = get_entry(tmpdict, 'revision')
        hwdict['bogomips']      = get_entry(tmpdict, 'bogomips')
        mhz_speed = tmpdict['cpu mhz']
        try:
            hwdict['speed'] = int(round(float(mhz_speed)) - 1)
        except ValueError:
            hwdict['speed'] = -1
        hwdict['other']         = get_entry(tmpdict, 'features')

    elif uname in ['ppc64']:
        tmpdict = get_cpulist_as_dict(cpulist)

        hwdict['platform'] = uname
        hwdict['count'] = count
        hwdict['model'] = get_entry(tmpdict, "cpu")
        hwdict['model_ver'] = get_entry(tmpdict, 'revision')
        hwdict['bogomips'] = get_entry(tmpdict, 'bogomips')
        hwdict['type'] = get_entry(tmpdict, 'machine')
        # strings are postpended with "mhz"
        mhz_speed = get_entry(tmpdict, 'clock')[:-3]
        try:
            hwdict['speed'] = int(round(float(mhz_speed)) - 1)
        except ValueError:
            hwdict['speed'] = -1

    elif uname in ['s390', 's390x']:
        tmpdict = {}
        for cpu in cpulist.split("\n"):
            vals = cpu.split(": ")
            if len(vals) != 2:
                continue
            tmpdict[vals[0].strip()] = vals[1].strip()

        hwdict['platform']      = uname
        hwdict['type']          = get_entry(tmpdict,'vendor_id')
        hwdict['model']         = uname
        hwdict['count']         = count
        hwdict['bogomips']      = get_entry(tmpdict, 'bogomips per cpu')
        hwdict['model_number']  = ""
        hwdict['model_ver']     = ""
        hwdict['model_rev']     = ""
        hwdict['cache']         = ""
        hwdict['other']         = get_entry(tmpdict, 'features')
        hwdict['speed']         = 0


    else:
        # XXX: expand me. Be nice to others
        hwdict['platform']      = uname
        hwdict['count']         = count
        hwdict['type']          = uname
        hwdict['model']         = uname
        hwdict['model_number']  = ""
        hwdict['model_ver']     = ""
        hwdict['model_rev']     = ""
        hwdict['cache']         = ""
        hwdict['bogomips']      = ""
        hwdict['other']         = ""
        hwdict['speed']         = 0

    # make sure we get the right number here
    if not hwdict["count"]:
        hwdict["count"] = 1
    else:
        try:
            hwdict["count"] = int(hwdict["count"])
        except:
            hwdict["count"] = 1
        else:
            if hwdict["count"] == 0: # we have at least one
                hwdict["count"] = 1

    # Network communication doesn't really belong in here. Sadly though
    # this is the only single place we can put this check. If it's not
    # here then it would need to be in five or six other places, which
    # is not good from a DRY and quality-assurance perspective.
    s = rhnserver.RhnServer()
    if s.capabilities.hasCapability('cpu_sockets'):
        # If we know it add in the number of sockets
        number_sockets = __get_number_sockets()
        if number_sockets:
            hwdict['socket_count'] = number_sockets

    # This whole things hurts a lot.
    return hwdict

def read_memory():
    un = os.uname()
    kernel = un[2]
    if kernel[:3] >= "2.6":
        return read_memory_2_6()
    if kernel[:3] == "2.4":
        return read_memory_2_4()

def read_memory_2_4():
    if not os.access("/proc/meminfo", os.R_OK):
        return {}

    meminfo = open("/proc/meminfo", "r").read()
    lines = meminfo.split("\n")
    curline = lines[1]
    memlist = curline.split()
    memdict = {}
    memdict['class'] = "MEMORY"
    megs = int(long(memlist[1])/(1024*1024))
    if megs < 32:
        megs = megs + (4 - (megs % 4))
    else:
        megs = megs + (16 - (megs % 16))
    memdict['ram'] = str(megs)
    curline = lines[2]
    memlist = curline.split()
    # otherwise, it breaks on > ~4gigs of swap
    megs = int(long(memlist[1])/(1024*1024))
    memdict['swap'] = str(megs)
    return memdict

def read_memory_2_6():
    if not os.access("/proc/meminfo", os.R_OK):
        return {}
    meminfo = open("/proc/meminfo", "r").read()
    lines = meminfo.split("\n")
    meminfo_dict = {}
    for line in lines:
        blobs = line.split(":", 1)
        key = blobs[0]
        if len(blobs) == 1:
            continue
        #print blobs
        value = blobs[1].strip()
        meminfo_dict[key] = value

    memdict = {}
    memdict["class"] = "MEMORY"

    total_str = meminfo_dict['MemTotal']
    blips = total_str.split(" ")
    total_k = long(blips[0])
    megs = long(total_k/(1024))

    swap_str = meminfo_dict['SwapTotal']
    blips = swap_str.split(' ')
    swap_k = long(blips[0])
    swap_megs = long(swap_k/(1024))

    memdict['ram'] = str(megs)
    memdict['swap'] = str(swap_megs)
    return memdict


def findHostByRoute():
    """ returns [hostname, intf, intf6]

        Where hostname is you FQDN of this machine.
        And intf is numeric IPv4 address. And intf6 is IPv6 address.
    """
    cfg = config.initUp2dateConfig()
    sl = config.getServerlURL()

    st = {'https':443, 'http':80}
    hostname = None
    intf = None
    intf6 = None
    for serverUrl in sl:
        server = serverUrl.split('/')[2]
        servertype = serverUrl.split(':')[0]
        port = st[servertype]

        for family in (AF_INET6, AF_INET):
            try:
                s = socket.socket(family)
            except socket.error:
                continue

            if cfg['enableProxy']:
                server_port = config.getProxySetting()
                (server, port) = server_port.split(':')
                port = int(port)

            try:
                s.settimeout(5)
                s.connect((server, port))
                intf_tmp = s.getsockname()[0]
                if family == AF_INET:
                    intf = intf_tmp
                else:
                    intf6 = intf_tmp
                hostname_tmp = socket.getfqdn(intf_tmp)
                if hostname_tmp != intf_tmp:
                    hostname = hostname_tmp
            except socket.error:
                s.close()
                continue
            s.close()

    # Override hostname with the value from /etc/hostname
    if os.path.isfile("/etc/hostname") and os.access("/etc/hostname", os.R_OK):
        hostnameinfo = open("/etc/hostname", "r").readlines()

        for info in hostnameinfo:
            if not len(info):
                continue
            hostname = info.strip()

    # Override hostname with the one in /etc/sysconfig/network
    # for bz# 457953
    elif os.path.isfile("/etc/sysconfig/network") and os.access("/etc/sysconfig/network", os.R_OK):
        networkinfo = open("/etc/sysconfig/network", "r").readlines()

        for info in networkinfo:
            if not len(info):
                continue
            vals = info.split('=')
            if len(vals) <= 1:
                continue
            strippedstring = vals[0].strip()
            vals[0] = strippedstring
            if vals[0] == "HOSTNAME":
                hostname = ''.join(vals[1:]).strip()
                break

    if hostname == None or hostname == 'localhost.localdomain':
        hostname = "unknown"
    return hostname, intf, intf6

def get_slave_hwaddr(master, slave):
    hwaddr = ""
    try:
        bonding = open('/proc/net/bonding/%s' % master, "r")
    except:
        return hwaddr

    slave_found = False
    for line in bonding.readlines():
        if slave_found and line.find("Permanent HW addr: ") != -1:
            hwaddr = line.split()[3]
            break

        if line.find("Slave Interface: ") != -1:
            ifname = line.split()[2]
            if ifname == slave:
                slave_found = True

    bonding.close()
    return hwaddr

def read_network():
    netdict = {}
    netdict['class'] = "NETINFO"

    netdict['hostname'], netdict['ipaddr'], netdict['ip6addr'] = findHostByRoute()

    if netdict['hostname'] == "unknown":
        netdict['hostname'] = gethostname()
        if "." not in netdict['hostname']:
            netdict['hostname'] = socket.getfqdn()

    if netdict['ipaddr'] is None:
        try:
            list_of_addrs = getaddrinfo(netdict['hostname'], None)
            ipv4_addrs = filter(lambda x:x[0]==socket.AF_INET, list_of_addrs)
            # take first ipv4 addr
            netdict['ipaddr'] = ipv4_addrs[0][4][0]
        except:
            netdict['ipaddr'] = "127.0.0.1"

    if netdict['ip6addr'] is None:
        try:
            list_of_addrs = getaddrinfo(netdict['hostname'], None)
            ipv6_addrs = filter(lambda x:x[0]==socket.AF_INET6, list_of_addrs)
            # take first ipv6 addr
            netdict['ip6addr'] = ipv6_addrs[0][4][0]
        except:
            netdict['ip6addr'] = "::1"

    if netdict['ipaddr'] is None:
        netdict['ipaddr'] = ''
    if netdict['ip6addr'] is None:
        netdict['ip6addr'] = ''
    return netdict

def read_network_interfaces():
    intDict = {}
    intDict['class'] = "NETINTERFACES"

    if not ethtool_present:
        # ethtool is not available on non-linux platforms (as kfreebsd), skip it
        return intDict

    interfaces = list(set(ethtool.get_devices() + ethtool.get_active_devices()))
    for interface in interfaces:
        try:
            hwaddr = ethtool.get_hwaddr(interface)
        except:
            hwaddr = ""

        # slave devices can have their hwaddr changed
        try:
            master = os.readlink('/sys/class/net/%s/master' % interface)
        except:
            master = None

        if master:
            master_interface = os.path.basename(master)
            hwaddr = get_slave_hwaddr(master_interface, interface)

        try:
            module = ethtool.get_module(interface)
        except:
            if interface == 'lo':
                module = "loopback"
            else:
                module = "Unknown"
        try:
            ipaddr = ethtool.get_ipaddr(interface)
        except:
            ipaddr = ""

        try:
            netmask = ethtool.get_netmask(interface)
        except:
            netmask = ""

        try:
            broadcast = ethtool.get_broadcast(interface)
        except:
            broadcast = ""

        ip6_list = []
        dev_info = ethtool.get_interfaces_info(interface)
        for info in dev_info:
            # one interface may have more IPv6 addresses
            for ip6 in info.get_ipv6_addresses():
                scope = ip6.scope
                if scope == 'global':
                    scope = 'universe'
                ip6_list.append({
                    'scope':   scope,
                    'addr':    ip6.address,
                    'netmask': ip6.netmask
                })
        intDict[interface] = {'hwaddr':hwaddr,
                              'ipaddr':ipaddr,
                              'netmask':netmask,
                              'broadcast':broadcast,
                              'module': module,
                              'ipv6': ip6_list}

    return intDict


# Read DMI information via hal.
def read_dmi():
    dmidict = {}
    dmidict["class"] = "DMI"

    # Try to obtain DMI info if architecture is i386, x86_64 or ia64
    uname = os.uname()[4].lower()
    if not (uname[0] == "i"  and  uname[-2:] == "86") and not (uname == "x86_64"):
        return dmidict

    # System Information
    vendor = dmi_vendor()
    if vendor:
        dmidict["vendor"] = vendor

    product = get_dmi_data('/dmidecode/SystemInfo/ProductName')
    if product:
        dmidict["product"] = product

    version = get_dmi_data('/dmidecode/SystemInfo/Version')
    if version:
        system = product + " " + version
        dmidict["system"] = system

    # BaseBoard Information
    dmidict["board"] = get_dmi_data('/dmidecode/BaseBoardInfo/Manufacturer')

    # Bios Information
    vendor = get_dmi_data('/dmidecode/BIOSinfo/Vendor')
    if vendor:
        dmidict["bios_vendor"] = vendor
    version = get_dmi_data('/dmidecode/BIOSinfo/Version')
    if version:
        dmidict["bios_version"] = version
    release = get_dmi_data('/dmidecode/BIOSinfo/ReleaseDate')
    if release:
        dmidict["bios_release"] = release

    # Chassis Information
    # The hairy part is figuring out if there is an asset tag/serial number of importance
    chassis_serial = get_dmi_data('/dmidecode/ChassisInfo/SerialNumber')
    chassis_tag = get_dmi_data('/dmidecode/ChassisInfo/AssetTag')
    board_serial = get_dmi_data('/dmidecode/BaseBoardInfo/SerialNumber')

    system_serial = get_dmi_data('/dmidecode/SystemInfo/SerialNumber')

    dmidict["asset"] = "(%s: %s) (%s: %s) (%s: %s) (%s: %s)" % ("chassis", chassis_serial,
                                                     "chassis", chassis_tag,
                                                     "board", board_serial,
                                                     "system", system_serial)

    # Clean up empty entries
    for k in dmidict.keys()[:]:
        if dmidict[k] is None:
            del dmidict[k]
            # Finished

    return dmidict

def get_hal_system_and_smbios():
    try:
        if using_gudev:
            props = get_computer_info()
        else:
            computer = get_hal_computer()
            props = computer.GetAllProperties()
    except Exception:
        log = up2dateLog.initLog()
        msg = "Error reading system and smbios information: %s\n" % (sys.exc_info()[1])
        log.log_debug(msg)
        return {}
    system_and_smbios = {}

    for key in props:
        if key.startswith('system'):
            system_and_smbios[unicode(key)] = unicode(props[key])

    system_and_smbios.update(get_smbios())
    return system_and_smbios

def get_smbios():
    """ Returns dictionary with values we are interested for.
        For historical reason it is in format, which use HAL.
        Currently in dictionary are keys:
        smbios.system.uuid, smbios.bios.vendor, smbios.system.serial,
        smbios.system.manufacturer.
    """
    _initialize_dmi_data()
    if _dmi_not_available:
        return {}
    else:
        return {
            'smbios.system.uuid': dmi_system_uuid(),
            'smbios.bios.vendor': dmi_vendor(),
            'smbios.system.serial': get_dmi_data('/dmidecode/SystemInfo/SerialNumber'),
            'smbios.system.manufacturer': get_dmi_data('/dmidecode/SystemInfo/Manufacturer'),
            'smbios.system.product': get_dmi_data('/dmidecode/SystemInfo/ProductName'),
            'smbios.system.skunumber': get_dmi_data('/dmidecode/SystemInfo/SKUnumber'),
            'smbios.system.family': get_dmi_data('/dmidecode/SystemInfo/Family'),
            'smbios.system.version': get_dmi_data('/dmidecode/SystemInfo/Version'),
        }

# this one reads it all
def Hardware():
    if using_gudev:
        allhw = get_devices()
    else:
        hal_status, dbus_status = check_hal_dbus_status()
        hwdaemon = 1
        if hal_status or dbus_status:
            # if status != 0 haldaemon or messagebus service not running.
            # set flag and dont try probing hardware and DMI info
            # and warn the user.
            log = up2dateLog.initLog()
            msg = "Warning: haldaemon or messagebus service not running. Cannot probe hardware and DMI information.\n"
            log.log_me(msg)
            hwdaemon = 0
        allhw = []

        if hwdaemon:
            try:
                ret = read_hal()
                if ret:
                    allhw = ret
            except:
                # bz253596 : Logging Dbus Error messages instead of printing on stdout
                log = up2dateLog.initLog()
                msg = "Error reading hardware information: %s\n" % (sys.exc_type)
                log.log_me(msg)

    # all others return individual arrays

    # cpu info
    try:
        ret = read_cpuinfo()
        if ret: allhw.append(ret)
    except:
        print _("Error reading cpu information:"), sys.exc_type

    # memory size info
    try:
        ret = read_memory()
        if ret: allhw.append(ret)
    except:
        print _("Error reading system memory information:"), sys.exc_type

    cfg = config.initUp2dateConfig()
    if not cfg["skipNetwork"]:
        # minimal networking info
        try:
            ret = read_network()
            if ret:
                allhw.append(ret)
        except:
            print _("Error reading networking information:"), sys.exc_type
    # dont like catchall exceptions but theres not
    # really anything useful we could do at this point
    # and its been trouble prone enough

    # minimal DMI info
    try:
        ret = read_dmi()
        if ret:
            allhw.append(ret)
    except:
        # bz253596 : Logging Dbus Error messages instead of printing on stdout
        log = up2dateLog.initLog()
        msg = "Error reading DMI information: %s\n" % (sys.exc_type)
        log.log_me(msg)

    try:
        ret = read_installinfo()
        if ret:
            allhw.append(ret)
    except:
        print _("Error reading install method information:"), sys.exc_type

    if not cfg["skipNetwork"]:
        try:
            ret = read_network_interfaces()
            if ret:
                allhw.append(ret)
        except:
            print _("Error reading network interface information:"), sys.exc_type

    # all Done.
    return allhw

# XXX: Need more functions here:
#  - filesystems layout (/proc.mounts and /proc/mdstat)
#  - is the kudzu config enough or should we strat chasing lscpi and try to parse that
#    piece of crap output?

#
# Main program
#
if __name__ == '__main__':
    for hw in Hardware():
        for k in hw.keys():
            print "'%s' : '%s'" % (k, hw[k])
        print
