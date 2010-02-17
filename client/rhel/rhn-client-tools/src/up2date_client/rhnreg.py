#
# RHN Registration Client
# Copyright (c) 2000-2002 Red Hat, Inc.
#
# Authors:
#     Adrian Likins <alikins@redhat.com>
#     Preston Brown <pbrown@redhat.com>
#     Daniel Benamy <dbenamy@redhat.com>

import os
import sys

import up2dateUtils
import up2dateErrors
import rhnserver
import rpmUtils
import up2dateLog
import rpcServer
import urlparse
import rhnreg_constants
import hardware
from rhnPackageInfo import convertPackagesFromHashToList

try:
    from rhn import rpclib
except ImportError:
    rpclib = __import__("xmlrpclib")

try:
    from virtualization import support
except ImportError:
    support = None    

import gettext
_ = gettext.gettext


# global variables
#SYSID_DIR = /tmp
SYSID_DIR = "/etc/sysconfig/rhn"
REMIND_FILE = "%s/rhn_register_remind" % SYSID_DIR
# REG_NUM_FILE is the new rhel 5 number.
REG_NUM_FILE = "%s/install-num" % SYSID_DIR

cachedOrgs = None

import config
cfg = config.initUp2dateConfig()
log = up2dateLog.initLog()


def validateEmail(email):
    ret = 1

    if len(email) < 6:
        ret = 0
    if not email.find("@") > 0:
        ret = 0
    if not email.find(".") > 0:
        ret = 0

    return ret

def startRhnsd():
    # successful registration.  Try to start rhnsd if it isn't running.
    if os.access("/usr/sbin/rhnsd", os.R_OK|os.X_OK):
        if os.access("/sbin/chkconfig", os.R_OK|os.X_OK):
            os.system("/sbin/chkconfig rhnsd on > /dev/null");
        else:
            print _("Warning: unable to enable rhnsd with chkconfig")

        rc = os.system("/sbin/service rhnsd status > /dev/null")
        if rc:
            os.system("/sbin/service rhnsd start > /dev/null")

def startRhnCheck():
    if os.access("/usr/sbin/rhn_check", os.R_OK|os.X_OK):
        os.system("/usr/sbin/rhn_check")
    else:
        print _("Warning: unable to run rhn_check")

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
            raise up2dateErrors.OemInfoFileError(i)
        
        info[key] = value.strip()

    return info


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
    
    fd = os.open(secure_file, os.O_WRONLY | os.O_CREAT, 0600)
    regNumFile = os.fdopen(fd, 'w')
    try:
        regNumFile.write(file_contents)
    finally:
        regNumFile.close()
    
    return True

def writeSystemId(systemId):
    res = _write_secure_file(cfg['systemIdPath'], systemId)

    # newer registratio  clients will create a file indicating that
    # we need to remind the user to register, this removes it
    if res:
        removeSystemRegisterRemindFile()
    
    return res

def writeRegNum(regNum):
    """Returns True if the write is successful or False if it fails."""
    file_contents = regNum + '\n'
    return _write_secure_file(REG_NUM_FILE, file_contents)

def readRegNum():
    """
    Returns the first line of the reg num file without the trailing newline
    or None if the file doesn't exist.
    
    Can raise IOError if the file exists but there's an error reading it.
    
    TODO If we wind up with a nice class for reg nums / install nums it would be
    cool to return one of those.
    
    New in RHEL 5.
    
    """
    if not os.access(REG_NUM_FILE, os.F_OK):
        return None
    # There's a race condition here, but it doesn't really matter
    regNumFile = open(REG_NUM_FILE)
    try:
        line = regNumFile.readline()
    finally:
        regNumFile.close()
    return line.strip()

def get_virt_info():
    """
    This function returns the UUID and virtualization type of this system, if
    it is a guest.  Otherwise, it returns None.  To figure this out, we'll
    use a number of heuristics (list in order of precedence):

       1.  Check /proc/xen/xsd_port.  If exists, we know the system is a
           host; exit.
       2.  Check /sys/hypervisor/uuid.  If exists and is non-zero, we know
           the system is a para-virt guest; exit.
       3.  Check SMBIOS.  If vendor='Xen' and UUID is non-zero, we know the
           system is a fully-virt guest; exit.
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

    # This is not a virt host system.  Check if it's a para-virt guest.
    (uuid, virt_type) = get_para_virt_info()
    if uuid is not None:
        return (uuid, virt_type)
        
    # This is not a para-virt guest.  Check if it's a fully-virt guest.
    (uuid, virt_type) = get_fully_virt_info()
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
    return long(uuid) == 0L

def welcomeText():
    s = rhnserver.RhnServer()

    return s.registration.welcome_message()
    

def privacyText():
    s = rhnserver.RhnServer()

    return s.registration.privacy_statement()


def finishMessage(systemId):
    s = rhnserver.RhnServer()
    return  s.registration.finish_message(systemId)

def getCaps():
    s = rhnserver.RhnServer()
    # figure out if were missing any needed caps
    s.capabilities.validate()
    
def termsAndConditions():
    s = rhnserver.RhnServer()

    return s.registration.terms_and_conditionsi()

def reserveUser(username, password):
    s = rhnserver.RhnServer()
    return s.registration.reserve_user(username, password)


def registerUser(username, password, email = None):
    s = rhnserver.RhnServer()

    if not email == None:
        s.registration.new_user(username, password, email)
    else:
        s.registration.new_user(username, password)


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
        return map(self._getSlotDescription, self._systemSlots)
    
    def getFailedSystemSlots(self):
        return self._failedSystemSlots
    
    def getFailedSystemSlotDescriptions(self):
        return map(self._getFailedSlotDescription, self._failedSystemSlots)
    
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
        if slot in ['virtualization_host', 'virtualization_host_platform']:
            return rhnreg_constants.VIRT + " " + rhnreg_constants.VIRT_FAILED
        else:
            return self._getSlotDescription(slot)

    def _getSlotDescription(self, slot):
        if slot == 'enterprise_entitled':
            return rhnreg_constants.MANAGEMENT
        elif slot == 'sw_mgr_entitled':
            return rhnreg_constants.UPDATES
        elif slot == 'provisioning_entitled':
            return rhnreg_constants.PROVISIONING
        elif slot == 'monitoring_entitled':
            return rhnreg_constants.MONITORING
        elif slot == 'virtualization_host':
            return rhnreg_constants.VIRT
        elif slot == 'virtualization_host_platform':
            return rhnreg_constants.VIRT_PLATFORM
        else:
            return slot


def registerSystem(username = None, password = None,
                   profileName = None, packages = None,
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
        auth_dict["smbios"] = hardware.get_smbios()
    
    s = rhnserver.RhnServer()
    if packages == None:
        ret = s.registration.new_system(auth_dict)
    else:
        ret = s.registration.new_system(auth_dict, packages)
    
    return ret


    
      
def getAvailableChannels(username, password):
    s = rhnserver.RhnServer()
    server_arch = up2dateUtils.getArch()
    server_version = up2dateUtils.getVersion()
    server_release = up2dateUtils.getRelease()
    
    availableChannels = None

    try:
        availableChannels = rpcServer.doCall(
                                  s.registration.available_eus_channels,
                                                 username, password,
                                                 server_arch, server_version, 
                                                 server_release)
    except rpclib.Fault, f:
        if f.faultCode == 99:
            raise up2dateErrors.DelayError(f.faultString)
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
        other["smbios"] = hardware.get_smbios()

    s = rhnserver.RhnServer()
    
    if activationKey:
        info = s.registration.new_system_activation_key(profileName,
                                                        up2dateUtils.getOSRelease(),
                                                        up2dateUtils.getVersion(),
                                                        up2dateUtils.getArch(),
                                                        activationKey,
                                                        other)
    else:
        log.log_debug("Calling xmlrpc registration.new_system_user_pass.")
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


def registerProduct(systemId, productInfo, oemInfo={}):
    s = rhnserver.RhnServer()
    s.registration.register_product(systemId, productInfo)

def updateContactInfo(username, password, productInfo):
    s = rhnserver.RhnServer()
    s.registration.update_contact_info(username, password, productInfo)

def server_supports_eus():
    return cfg["supportsEUS"]

def sat_supports_virt_guest_registration():
    s = rhnserver.RhnServer()
    
    if s.capabilities.has_key('registration.remaining_subscriptions'):
        if int(s.capabilities['registration.remaining_subscriptions']['version']) > 1:
            return True
        else:
            return False
    else:
        return False
    
            
def getRemainingSubscriptions(username, password):

    s = rhnserver.RhnServer()
    server_type = getServerType()
    
    # The only point of this function is to determine if we should show the
    # Activate a Subscription screen, which we never do in satellite.
    if server_type == 'satellite':
        return 1

    arch = up2dateUtils.getArch()
    #Intentionally swapping, release/version so it is more in tune
    #with the perspective of release/version used by RHN Hosted.
    #bz: 442694
    release = up2dateUtils.getVersion()
    version = up2dateUtils.getRelease()
    log.log_debug('Calling xmlrpc registration.remaining_subscriptions')
        

    virt_uuid, virt_type = get_virt_info()
    if virt_uuid is not None:
        log.log_debug('Sending up virt_uuid: %s' % str(virt_uuid))
    else:
        virt_uuid = ""

    # If we've gotten this far, we're definitely looking at hosted.
    # Hosted will have to support the sending of the release, and optionally,
    # the virt_uuid.

    if cfg['supportsSMBIOS']:
        smbios = hardware.get_smbios()
        subs = s.registration.remaining_subscriptions(username, password, 
                                                      arch,
                                                      release,
                                                      virt_uuid,
                                                      smbios)
    else:
        subs = s.registration.remaining_subscriptions(username, password, 
                                                      arch,
                                                      release,
                                                      virt_uuid)


    log.log_debug('Server returned %s' % subs)
    return subs

def getAvailableSubscriptions(username, password):
    """Higher level and more convenient version of getRemainingSubscriptions.
    
    Precondition: getCaps() was called.
    
    Returns: -1 for inifinite subscriptions.
    
    Raises:
    * up2dateErrors.ServerCapabilityError
    * up2dateErrors.ValidationError
    probably others
    
    """
    availableSubscriptions = None
    
    log.log_debug('Calling getAvailableSubscriptions')

    if cfg['supportsRemainingSubscriptions'] is None:
        message = "The server doesn't support the " \
                  "registration.remaining_subscriptions call which is needed."
        raise up2dateErrors.ServerCapabilityError(message)
    
    try:
        availableSubscriptions = \
                    getRemainingSubscriptions(username, password)
    except up2dateErrors.NoBaseChannelError, e:
        availableSubscriptions = 0
        log.log_debug('NoBaseChannelError raised.')
    log.log_debug('Returning %s available subscriptions.' % 
                  availableSubscriptions)
    return availableSubscriptions

def sendHardware(systemId, hardwareList):
    s = rhnserver.RhnServer()
    s.registration.add_hw_profile(systemId, hardwareList)
   
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
    print s.registration.list_packages,systemId()

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
    
    If serverUrl is not specified, it is read from the config entry 'serverURL'.
    
    """
    if serverUrl is None:

        # serverURL may be a list in the config file, so by default, grab the
        # first element.
        if type(cfg['serverURL']) == type([]):
            serverUrl = cfg['serverURL'][0]
        else:
            serverUrl = cfg['serverURL']

    serverUrl = makeNiceServerUrl(serverUrl)
    protocol, host, path, parameters, query, fragmentIdentifier = \
            urlparse.urlparse(serverUrl)
            
    hosted_whitelist = cfg['hostedWhitelist']
    
    if host in ['xmlrpc.rhn.redhat.com', 'rhn.redhat.com'] or \
       hosted_whitelist is not None and host in hosted_whitelist:
        return 'hosted'
    else:
        return 'satellite'


def updatePackages(systemId):
    s = rhnserver.RhnServer()
    s.registration.add_packages(systemId, rpmUtils.getInstalledPackageList())

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

def activateRegistrationNumber(username, password, registrationNumber, 
                               orgId=None):
    """Tries to activate a registration/entitlement number.
    
    Returns an ActivationResult.
    Can raise:
        InvalidRegistrationNumberError
        Entitlement number is not entitling - ValidationError TODO change to 
                                              something else so if they type 
                                              one in we can give better feedback
        Communication errors, etc
    
    """
    log.log_debug('Calling xmlrpc activate_registration_number.')
    server = rhnserver.RhnServer()
##    if server.capabilities.hasCapability(
##       'registration.activate_subscription_number'):
##        # TODO Make xmlrpc call
##        pass
##    else:
##        # TODO
##        pass

    other = {}
    if orgId:
        other = {'org_id': orgId}
    
    result = server.registration.activate_registration_number(username, password, registrationNumber, other)
    statusCode = result['status_code']
    regNum = result['registration_number']
    channels = result['channels']
    system_slots = result['system_slots']
    log.log_debug('Server returned status code %s' % statusCode)
    if statusCode == 0:
        return ActivationResult(ActivationResult.ACTIVATED_NOW, regNum,
                                channels, system_slots)
    elif statusCode == 1:
        return ActivationResult(ActivationResult.ALREADY_USED, regNum,
                                channels, system_slots)
    else:
        message = "The server returned unknown status code %s while activating" \
                   " an installation number." % statusCode
        raise up2dateErrors.CommunicationError(message)


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
    log.log_debug('Calling xmlrpc activate_hardware_info.')
    
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


# TODO Move the PossibleOrg stuff to a seperate file
class PossibleOrgsError(Exception):
    pass
class InvalidDefaultError(PossibleOrgsError):
    pass
class NoDefaultError(PossibleOrgsError):
    pass

class PossibleOrgs:
    def __init__(self):
        self._orgs = {}
        self._default = None
    
    def setOrgs(self, orgsDict):
        """orgsDict must be a dict of org ids (as ints or strings that contain 
        ints) to org names (as strings).
        
        """
        self._orgs = {}
        for id, name in orgsDict.items():
            self._orgs[int(id)] = name
        self._default = None
    
    def setDefaultOrg(self, orgId):
        """Must refer to org that's already been added. Can be an int or string
        containing an int.
        
        """
        if int(orgId) not in self._orgs.keys():
            raise InvalidDefaultError("Tried to set default org to %s. Valid "
                                      "values are %s" % (orgId, self._orgs.keys()))
        self._default = int(orgId)
    
    def getOrgs(self):
        """Returns a dict of org ids (ints) to org names (strings). Can return
        an empty dict.
        
        """
        return self._orgs
    
    def getDefaultOrg(self):
        """Returns the org id (int) of the default org.
        Raises NoDefaultError if setDefaultOrg was never called or wasn't called
        after setOrgs.
        
        """
        if self._default is None:
            raise NoDefaultError()
        return self._default

def getPossibleOrgs(username, password, useCache=False):
    """Gets the orgs the user belongs to and the default one.
    
    If useCache is set to true it will not talk to the server and will return 
    the values from the most recent non-cached call. If there is nothing cached, 
    it will get the current value from the server.
    
    Returns a PossibleOrgs.
    
    Can raise:
    * up2dateErrors2.UnknownMethodException if called on a server that doesn't 
      support the necessary xmlrpc (satellites won't, at least for now)
    * The usual 'communication with a server' exceptions
    
    """
    global cachedOrgs
    if useCache and cachedOrgs is not None:
        return cachedOrgs
    s = rhnserver.RhnServer()
    orgsFromServer = s.registration.get_possible_orgs(username, password)
    cachedOrgs = PossibleOrgs()
    cachedOrgs.setOrgs(orgsFromServer['orgs'])
    cachedOrgs.setDefaultOrg(orgsFromServer['default_org'])
    return cachedOrgs


def serverSupportsRhelFiveCalls():
    """This checks for the new calls we added for rhel 5, some of which 
    are required, such as the new system registration calls. I don't know how 
    this will work long term, but for now we wanna put this into a build that 
    people will probably try to use against servers that don't support the new 
    stuff.
    TODO List calls here.
    
    Returns True or False.
    
    """
    # This is a hack. 
    # TODO Call new_system_user_pass instead of getPossibleOrg so it works on sats.
    # TODO Make this use nice capabilities infrastructure or something.
    # We only check for get_possible_orgs but we're really also checking for the
    # other calls that were added at the same time.
    try:
        getPossibleOrgs('sdthzdthz233drgdth', 'ztedhzdth2zdbz')
    except up2dateErrors.ValidationError:
        return True
    except up2dateErrors.UnknownMethodException:
        pass
    except:
        log.log_me("An unexcepted error was raised while checking to see if the"
                   " server supports the required calls:")
        log.log_exception(*sys.exc_info())
    return False

def spawnRhnCheckForUI():
    if os.access("/usr/sbin/rhn_check", os.R_OK|os.X_OK):
        from subprocess import Popen, PIPE
        p = Popen(["/usr/sbin/rhn_check"], stdin=PIPE, stdout=PIPE, \
                  stderr=PIPE)
        map(lambda x:log.log_me(x), p.stdout.readlines() + \
                  p.stderr.readlines())
    else:
        log.log_me("Warning: unable to run rhn_check")

