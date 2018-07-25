#
# RHN Registration Client
# Copyright (c) 2000--2016 Red Hat, Inc.
#
# Authors:
#     Adrian Likins <alikins@redhat.com>
#     Preston Brown <pbrown@redhat.com>
#     Daniel Benamy <dbenamy@redhat.com>

import os
import sys
import dbus

from up2date_client import up2dateUtils
from up2date_client import up2dateErrors
from up2date_client import rhnserver
from up2date_client import pkgUtils
from up2date_client import up2dateLog
from up2date_client import rhnreg_constants
from up2date_client import hardware
from up2date_client.rhnPackageInfo import convertPackagesFromHashToList
from up2date_client.pkgplatform import getPlatform
from rhn.i18n import ustr, sstr
from rhn.tb import raise_with_tb

try: # python2
    import urlparse
    import xmlrpclib
    from types import ListType, TupleType, StringType, UnicodeType, DictType, DictionaryType
except ImportError: # python3
    import urllib.parse as urlparse
    import xmlrpc.client as xmlrpclib
    ListType = list
    TupleType = tuple
    StringType = bytes
    UnicodeType = str
    DictType = dict
    DictionaryType = dict
    long = int

try:
    from virtualization import support
except ImportError:
    support = None

import gettext
t = gettext.translation('rhn-client-tools', fallback=True)
# Python 3 translations don't have a ugettext method
if not hasattr(t, 'ugettext'):
    t.ugettext = t.gettext
_ = t.ugettext

# global variables
#SYSID_DIR = /tmp
SYSID_DIR = "/etc/sysconfig/rhn"
REMIND_FILE = "%s/rhn_register_remind" % SYSID_DIR

HW_CODE_FILE = "%s/hw-activation-code" % SYSID_DIR
RHSM_FILE = "/etc/pki/consumer/cert.pem"

from up2date_client import config
cfg = config.initUp2dateConfig()
log = up2dateLog.initLog()


def startRhnsd():
    # successful registration.  Try to start rhnsd if it isn't running.
    if os.access("/usr/sbin/rhnsd", os.R_OK|os.X_OK):
        # test for UsrMerge systemd environment
        systemd_system_unitdir = "/usr/lib/systemd/system"
        systemd_systemctl = "/usr/bin/systemctl"
        if not os.access(systemd_systemctl, os.R_OK|os.X_OK):
            if os.access("/bin/systemctl", os.R_OK|os.X_OK):
                systemd_systemctl = "/bin/systemctl"
                systemd_system_unitdir = "/lib/systemd/system"
        if os.access("%s/rhnsd.service" % systemd_system_unitdir, os.R_OK):
            # systemd
            if os.access(systemd_systemctl, os.R_OK|os.X_OK):
                os.system("%s enable rhnsd > /dev/null" % systemd_systemctl);
                os.system("%s start rhnsd > /dev/null" % systemd_systemctl);
            else:
                print(_("Warning: unable to enable rhnsd with systemd"))
        else:
            # SysV init scripts
            if os.access("/sbin/chkconfig", os.R_OK|os.X_OK):
                os.system("/sbin/chkconfig rhnsd on > /dev/null");
            else:
                print(_("Warning: unable to enable rhnsd with chkconfig"))

            service_path = "/sbin/service"
            if not os.access(service_path, os.R_OK|os.X_OK):
                if os.access("/usr/sbin/service", os.R_OK|os.X_OK):
                    service_path = "/usr/sbin/service"

            rc = os.system("%s rhnsd status > /dev/null" % service_path)
            if rc:
                os.system("%s rhnsd start > /dev/null" % service_path)

def getOemInfo():
    configFile = cfg["oemInfoFile"] or "/etc/sysconfig/rhn/oeminfo"

    if not os.access(configFile, os.R_OK):
        return {}

    fd = open(configFile, "r")
    L = fd.readlines()

    info = {}
    for i in L:
        i = i.strip()
        if i == "":
            continue
        try:
            (key, value) = i.split(':')
        except ValueError:
            raise_with_tb(up2dateErrors.OemInfoFileError(i))

        info[key] = value.strip()

    return info

def rhsm_registered():
    """ Returns true if system is registred using subscription manager """
    if os.access(RHSM_FILE, os.R_OK):
        statinfo = os.stat(RHSM_FILE)
        return statinfo.st_size > 0
    else:
        return False

def registered():
    return os.access(cfg['systemIdPath'], os.R_OK)

def createSystemRegisterRemindFile():
    if not os.access(REMIND_FILE, os.R_OK):
        # touch the file to tell the applet it needs to remind
        # the user to register
        fd = open(REMIND_FILE, "w+")
        fd.close()

def removeSystemRegisterRemindFile():
    if os.access(REMIND_FILE, os.R_OK):
        os.unlink(REMIND_FILE)

def _write_secure_file(secure_file, file_contents):
    """ Write a file to disk that is not readable by other users. """
    dir_name = os.path.dirname(secure_file)
    if not os.access(dir_name, os.W_OK):
        return False

    if os.access(secure_file, os.F_OK):
        # already have file there; let's back it up
        try:
            os.rename(secure_file, secure_file + '.save')
        except:
            return False

    fd = os.open(secure_file, os.O_WRONLY | os.O_CREAT, int('0600', 8))
    fd_file = os.fdopen(fd, 'w')
    try:
        fd_file.write(sstr(file_contents))
    finally:
        fd_file.close()

    return True

def writeSystemId(systemId):
    res = _write_secure_file(cfg['systemIdPath'], systemId)

    # newer registratio  clients will create a file indicating that
    # we need to remind the user to register, this removes it
    if res:
        removeSystemRegisterRemindFile()

    updateRhsmStatus()

    return res

def writeHWCode(hw_activation_code):
    """Returns True if the write is successful or False if it fails."""
    return _write_secure_file(HW_CODE_FILE, hw_activation_code + '\n')

def get_virt_info():
    """
    This function returns the UUID and virtualization type of this system, if
    it is a guest.  Otherwise, it returns None.  To figure this out, we'll
    use a number of heuristics (list in order of precedence):

       1.  Check /proc/xen/xsd_port.  If exists, we know the system is a
           host; exit.
       2.  Check SMBIOS.  If vendor='Xen' and UUID is non-zero, we know the
           system is a fully-virt guest; exit.
       3.  Check /sys/hypervisor/uuid.  If exists and is non-zero, we know
           the system is a para-virt guest; exit.
       4.  If non of the above checks worked; we know we have a
           non-xen-enabled system; exit.
    """

    # First, check whether /proc/xen/xsd_port exists.  If so, we know this is
    # a host system.
    try:
        if os.path.exists("/proc/xen/xsd_port"):
            # Ok, we know this is *at least* a host system.  However, it may
            # also be a fully-virt guest.  Check for that next.  If it is, we'll
            # just report that instead since we only support one level of
            # virtualization.
            (uuid, virt_type) = get_fully_virt_info()
            return (uuid, virt_type)
    except IOError:
        # Failed.  Move on to next strategy.
        pass

    # This is not a virt host system. Check if it's a fully-virt guest.
    (uuid, virt_type) = get_fully_virt_info()
    if uuid is not None:
        return (uuid, virt_type)

    # This is not a fully virt guest system. Check if it's a para-virt guest.
    (uuid, virt_type) = get_para_virt_info()
    if uuid is not None:
        return (uuid, virt_type)

    # If we got here, we have a system that does not have virtualization
    # enabled.
    return (None, None)

def get_para_virt_info():
    """
    This function checks /sys/hypervisor/uuid to see if the system is a
    para-virt guest.  It returns a (uuid, virt_type) tuple.
    """
    try:
        uuid_file = open('/sys/hypervisor/uuid', 'r')
        uuid = uuid_file.read()
        uuid_file.close()
        uuid = uuid.lower().replace('-', '').rstrip("\r\n")
        virt_type = "para"
        return (uuid, virt_type)
    except IOError:
        # Failed; must not be para-virt.
        pass

    return (None, None)

def get_fully_virt_info():
    """
    This function looks in the SMBIOS area to determine if this is a
    fully-virt guest.  It returns a (uuid, virt_type) tuple.
    """
    vendor = hardware.dmi_vendor()
    uuid = hardware.dmi_system_uuid()
    if vendor.lower() == "xen":
        uuid = uuid.lower().replace('-', '')
        virt_type = "fully"
        return (uuid, virt_type)
    else:
        return (None, None)

def _is_host_uuid(uuid):
    uuid = eval('0x%s' % uuid)
    return long(uuid) == long(0)

def welcomeText():
    s = rhnserver.RhnServer()

    return s.registration.welcome_message()


def getCaps():
    s = rhnserver.RhnServer()
    # figure out if were missing any needed caps
    s.capabilities.validate()

def reserveUser(username, password):
    s = rhnserver.RhnServer()
    return s.registration.reserve_user(username, password)


class RegistrationResult:
    def __init__(self, systemId, channels, failedChannels, systemSlots,
                 failedSystemSlots, universalActivationKey, rawDict=None):
        # TODO Get rid of rawDict
        self._systemId = systemId
        self._channels = channels
        self._failedChannels = failedChannels
        self._systemSlots = systemSlots
        self._failedSystemSlots = failedSystemSlots
        if len(universalActivationKey) > 0:
            self._universalActivationKey = universalActivationKey
        else:
            self._universalActivationKey = None
        self.rawDict = rawDict

    def getSystemId(self):
        return self._systemId

    def getChannels(self):
        return self._channels

    def getFailedChannels(self):
        return self._failedChannels

    def getSystemSlots(self):
        return self._systemSlots

    def getSystemSlotDescriptions(self):
        return [self._getSlotDescription(s) for s in self._systemSlots]

    def getFailedSystemSlotDescriptions(self):
        return [self._getFailedSlotDescription(s) for s in self._failedSystemSlots]

    def getUniversalActivationKey(self):
        """Returns None if no universal activation key was used."""
        return self._universalActivationKey

    def hasBaseAndUpdates(self):
        """Returns True if the system was subscribed to at least one channel
        and was given any type of system slot so it will get updates. In other
        words, returns True if the system will be getting at least basic
        updates.

        """
        # If it was subscribed to at least one channel, that must include a
        # base channel.
        return len(self._channels) > 0 and len(self._systemSlots) > 0

    def _getFailedSlotDescription(self, slot):
        if slot == 'virtualization_host':
            return rhnreg_constants.VIRT + " " + rhnreg_constants.VIRT_FAILED
        else:
            return self._getSlotDescription(slot)

    def _getSlotDescription(self, slot):
        if slot == 'enterprise_entitled':
            return rhnreg_constants.MANAGEMENT
        elif slot == 'virtualization_host':
            return rhnreg_constants.VIRT
        else:
            return slot


def registerSystem(username = None, password = None,
                   profileName = None,
                   token = None, other = None):
    """Wrapper for the old xmlrpc to register a system. Activates subscriptions
    if a reg num is given.

    """
    auth_dict = { "profile_name" : profileName,
                  "os_release" : up2dateUtils.getVersion(),
                  "release_name" : up2dateUtils.getOSRelease(),
                  "architecture" : up2dateUtils.getArch() }
    # dict of other bits to send
    if other:
        for (key, item) in other.items():
            auth_dict[key] = item
    if token:
        auth_dict["token"] = token
    else:
        auth_dict["username"] = username
        auth_dict["password"] = password

    if cfg['supportsSMBIOS']:
        auth_dict["smbios"] = _encode_characters(hardware.get_smbios())

    s = rhnserver.RhnServer()
    ret = s.registration.new_system(auth_dict)

    return ret

def updateRhsmStatus():
    try:
        bus = dbus.SystemBus()
        validity_obj = bus.ProxyObjectClass(bus, 'com.redhat.SubscriptionManager',
              '/EntitlementStatus', introspect=False)
        validity_iface = dbus.Interface(validity_obj,
              dbus_interface='com.redhat.SubscriptionManager.EntitlementStatus')
    except dbus.DBusException:
        # we can't connect to dbus. it's not running, likely from a minimal
        # install. we can't do anything here, so just ignore it.
        return

    try:
        validity_iface.check_status()
    except dbus.DBusException:
        # the call timed out, or something similar. we don't really care
        # about a timely reply or what the result might be, we just want
        # the method to run. So we can safely ignore this.
        pass


def getAvailableChannels(username, password):
    s = rhnserver.RhnServer()
    server_arch = up2dateUtils.getArch()
    server_version = up2dateUtils.getVersion()
    server_release = up2dateUtils.getRelease()

    availableChannels = None

    try:
        availableChannels = s.registration.available_eus_channels(
                                                 username, password,
                                                 server_arch, server_version,
                                                 server_release)
    except xmlrpclib.Fault:
        f = sys.exc_info()[1]
        if f.faultCode == 99:
            raise_with_tb(up2dateErrors.DelayError(f.faultString))
        else:
            raise

    return availableChannels




def registerSystem2(username = None, password = None,
                   profileName = None, packages = None,
                   activationKey = None, other = {}):
    """Uses the new xmlrpcs to register a system. Returns a dict instead of just
    system id.

    The main differences between this and registerSystem and that this doesn't
    do activation and does child channel subscriptions if possible. See the
    documentation for the xmlrpc handlers in backend for more detail.

    If nothing is going to be in other, it can be {} or None.

    New in RHEL 5.

    """
    if other is None:
        other = {}

    if activationKey:
        assert username is None
        assert password is None
        assert activationKey is not None
    else:
        assert username is not None
        assert password is not None
        assert activationKey is None
    for key in other.keys():
        assert key in ['registration_number',
                       'org_id',
                       'virt_uuid',
                       'virt_type',
                       'channel']

    if cfg['supportsSMBIOS']:
        other["smbios"] = _encode_characters(hardware.get_smbios())

    s = rhnserver.RhnServer()

    if activationKey:
        info = s.registration.new_system_activation_key(profileName,
                                                        up2dateUtils.getOSRelease(),
                                                        up2dateUtils.getVersion(),
                                                        up2dateUtils.getArch(),
                                                        activationKey,
                                                        other)
    else:
        info = s.registration.new_system_user_pass(profileName,
                                                   up2dateUtils.getOSRelease(),
                                                   up2dateUtils.getVersion(),
                                                   up2dateUtils.getArch(),
                                                   username,
                                                   password,
                                                   other)
    log.log_debug("Returned:\n%s" % info)
    result = RegistrationResult(info['system_id'],
                                info['channels'], info['failed_channels'],
                                info['system_slots'], info['failed_system_slots'],
                                info['universal_activation_key'],
                                rawDict=info)
    return result

def server_supports_eus():
    return cfg["supportsEUS"]

def sendHardware(systemId, hardwareList):
    def remove_ip6addr(x):
        if x['class'] == 'NETINFO' and 'ip6addr' in x:
            del x['ip6addr']
        return x
    s = rhnserver.RhnServer()
    if not s.capabilities.hasCapability('ipv6', 1):
        hardwareList = [remove_ip6addr(i) for i in hardwareList]
    s.registration.add_hw_profile(systemId, _encode_characters(hardwareList))

def sendPackages(systemId, packageList):
    s = rhnserver.RhnServer()
    if not s.capabilities.hasCapability('xmlrpc.packages.extended_profile', 2):
        # for older satellites and hosted - convert to old format
        packageList = convertPackagesFromHashToList(packageList)
    s.registration.add_packages(systemId, packageList)

def sendVirtInfo(systemId):
    if support is not None:
        support.refresh()

def listPackages(systemId):
    s = rhnserver.RhnServer()
    print(s.registration.list_packages,systemId())

def makeNiceServerUrl(server):
    """Raises up2dateErrors.InvalidProtocolError if the server url has a
    protocol specified and it's not http or https.

    """
    protocol, host, path, parameters, query, fragmentIdentifier = urlparse.urlparse(server)
    if protocol is None or protocol == '':
        server = 'https://' + server
        # We must call it again because if there wasn't a protocol the
        # host will be in path
        protocol, host, path, parameters, query, fragmentIdentifier = urlparse.urlparse(server)
    if protocol not in ['https', 'http']:
        raise up2dateErrors.InvalidProtocolError("You specified an invalid "
                                                 "protocol. Only https and "
                                                 "http are allowed.")
    if path is None or path == '' or path == '/':
        path = '/XMLRPC'
    server = urlparse.urlunparse((protocol, host, path, parameters, query,
                                  fragmentIdentifier))
    # TODO Raise an exception if url isn't valid
    return server

def getServerType(serverUrl=None):
    """Returns 'hosted' if the url points to a known hosted server. Otherwise
    returns 'satellite'.
    """
    return 'satellite'


class ActivationResult:
    ACTIVATED_NOW = 0
    ALREADY_USED = 1

    def __init__(self, status, registrationNumber, channels={}, systemSlots={}):
        """channels and systemSlots are dicts where the key/value pairs are
        label (string) / quantity (int).

        """
        self._status = status
        # TODO Validate reg num
        self._regNum = registrationNumber
        self._channels = channels
        self._systemSlots = systemSlots

    def getStatus(self):
        return self._status

    def getRegistrationNumber(self):
        return self._regNum

    def getChannelsActivated(self):
        """Returns a dict- the key/value pairs are label/quantity."""
        return self._channels

    def getSystemSlotsActivated(self):
        """Returns a dict- the key/value pairs are label/quantity."""
        return self._systemSlots

def _encode_characters(*args):
        """ All the data we gathered from dmi, bios, gudev are in utf-8,
            we need to convert characters beyond ord(127) - e.g \xae to unicode.
        """
        result=[]
        for item in args:
            item_type = type(item)
            if item_type == StringType:
                item = ustr(item)
            elif item_type == TupleType:
                item = tuple(_encode_characters(i) for i in item)
            elif item_type == ListType:
                item = [_encode_characters(i) for i in item]
            elif item_type == DictType or item_type == DictionaryType:
                item = dict([(_encode_characters(name, val)) for name, val in item.items()])
            # else: numbers or UnicodeType - are safe
            result.append(item)
        if len(result) == 1:
            return result[0]
        else:
            return tuple(result)

def _activate_hardware(login, password):

    # Read the asset code from the hardware.
    activateHWResult = None
    hardwareInfo = None
    hw_activation_code = None
    try:
        hardwareInfo = hardware.get_hal_system_and_smbios()
        hardwareInfo = _encode_characters(hardwareInfo)
    except:
        log.log_me("There was an error while reading the hardware "
                   "info from the bios. Traceback:\n")
        log.log_exception(*sys.exc_info())

    if hardwareInfo is not None:
        try:
            activateHWResult = activateHardwareInfo(
                                       login, password, hardwareInfo)
            if activateHWResult.getStatus() == ActivationResult.ACTIVATED_NOW:
                hw_activation_code = activateHWResult.getRegistrationNumber()
                writeHWCode(hw_activation_code)
        except up2dateErrors.NotEntitlingError:
            log.log_debug('There are are no entitlements associated '
                          'with this hardware.')
        except up2dateErrors.InvalidRegistrationNumberError:
            log.log_debug('The hardware id was not recognized as valid.')
    return hw_activation_code

def activateHardwareInfo(username, password, hardwareInfo, orgId=None):
    """Tries to activate an entitlement linked to the hardware info that we
    read from the bios.

    Returns an ActivationResult.
    Can raise:
        Invalid number.
        Hardware info is not entitling.
        Communication errors, etc

    """
##    import pprint
##    pprint.pprint(hardwareInfo)

    other = {}
    if orgId:
        other = {'org_id': orgId}

    server = rhnserver.RhnServer()
    result = server.registration.activate_hardware_info(username, password,
                                                        hardwareInfo, other)
    statusCode = result['status_code']
    regNum = result['registration_number']
    log.log_debug('Server returned status code %s' % statusCode)
    if statusCode == 0:
        return ActivationResult(ActivationResult.ACTIVATED_NOW, regNum)
    elif statusCode == 1:
        return ActivationResult(ActivationResult.ALREADY_USED, regNum)
    else:
        message = "The server returned unknown status code %s while activating" \
                   " the hardware info." % statusCode
        raise up2dateErrors.CommunicationError(message)


def spawnRhnCheckForUI():
    if os.access("/usr/sbin/rhn_check", os.R_OK|os.X_OK):
        from subprocess import Popen, PIPE
        p = Popen(["/usr/sbin/rhn_check"], stdin=PIPE, stdout=PIPE, \
                  stderr=PIPE)
        map(lambda x:log.log_me(x), p.stdout.readlines() + \
                  p.stderr.readlines())
    else:
        log.log_me("Warning: unable to run rhn_check")

if getPlatform() == 'deb':
    def pluginEnable():
        """On Debian no extra action for plugin is needed"""
        return 1, 0
else:
    from up2date_client.pmPlugin import pluginEnable

