#!/usr/bin/python
#
# RHN Registration Client
# Copyright (c) 2000--2012 Red Hat, Inc.
#
# Authors:
#     Adrian Likins <alikins@redhat.com>
#     Preston Brown <pbrown@redhat.com>

import os
import string
import rhnUtils
import rhnErrors
import rpcServer
import capabilities
import config

from translate import _

import xmlrpclib

# global variables
SYSID_DIR = config.RHN_SYSCONFIG_DIR
SYSID_FILE = config.UP2DATE_SYSTEMID
SYSID_BU_FILE = SYSID_FILE + ".save"
cfg = config.initUp2dateConfig()

# the config file should have this, but the above is just in case
if cfg.has_key("systemIdPath"):
	SYSID_FILE=cfg['systemIdPath']
	SYSID_BU_FILE="%s.save" % SYSID_FILE

# Where do we keep the CA certificate for RHNS?
# The servers we're talking to need to have their certs
# signed by one of these CA.
rhns_ca_cert = cfg["sslCACert"] or config.CA_CERT

def version():
    # substituted to the real version by the Makefile at installation time.
    return "@VERSION@"

# reload the config in case it's changed on disk
def reloadConfig():
    cfg.load()


def validateEmail(email):
    ret = 1

    if len(email) < 6:
        ret = 0
    if not string.find(email, "@") > 0:
        ret = 0
    if not string.find(email, ".") > 0:
        ret = 0

    return ret

def startRhnsd():
    # PORTME
    # successful registration.  Try to start rhnsd if it isn't running.
    rhnsdpath = "%s/usr/sbin/rhnsd" % config.PREFIX
    if os.access(rhnsdpath, os.R_OK|os.X_OK):
#        if os.access("/sbin/chkconfig", os.R_OK|os.X_OK):
#            os.system("/sbin/chkconfig rhnsd on > /dev/null");
#        else:
#            print _("Warning: unable to enable rhnsd with chkconfig")


        rc = os.system("/etc/init.d/rhnsd status > /dev/null")
        if rc:
            os.system("/etc/init.d/rhnsd start > /dev/null")
	

# product info structure
productInfoHash = {
    "title" : "",
    "first_name" : "",
    "last_name" : "",
    "company" : "",
    "position" : "",
    "address1" : "",
    "address2" : "",
    "city" : "",
    "state" : "",
    "zip" : "",
    "country" : "",
    "phone" : "",
    "fax" : "",
    "contact_email" : 1,
    "contact_mail" : 0,
    "contact_phone" : 0,
    "contact_fax" : 0, 
    "newsletter" : 0,
    "special_offers" : 0
    }


def getOemInfo():
    configFile = cfg["oemInfoFile"] or config.UP2DATE_OEMINFO

    if not os.access(configFile, os.R_OK):
        return {}

    fd = open(configFile, "r")
    L = fd.readlines()

    info = {}
    for i in L:
        i = string.strip(i)
        if i == "":
            continue
        try:
            (key, value) = string.split(i, ':')
        except ValueError:
            raise rhnErrors.OemInfoFileError(i)
        
        info[key] = string.strip(value)

    return info
    

        
def registered():
    global SYSID_FILE
    return os.access(SYSID_FILE, os.R_OK)

def writeSystemId(systemId):
    global SYSID_FILE
    global SYSID_DIR
    
    if not os.access(SYSID_DIR, os.W_OK):
        try:
            os.mkdir(SYSID_DIR)
        except:
            return 0

    if not os.access(SYSID_DIR, os.W_OK):
        return 0

    if os.access(SYSID_FILE, os.F_OK):
	# already have systemid file there; let's back it up
	try:
	    os.rename(SYSID_FILE, SYSID_BU_FILE)
	except:
	    return 0

    f = open(SYSID_FILE, "w")
    f.write(systemId)
    f.close()

    try:
        os.chmod(SYSID_FILE, 0600)
    except:
        return 0
    return 1

def welcomeText():
    s = rpcServer.getServer()

    try:
        return rpcServer.doCall(s.registration.welcome_message)
    except xmlrpclib.Fault, f:
        if f.faultCode == 99:
            raise rhnErrors.DelayError(f.faultString)
        else:
            raise rhnErrors.CommunicationError(f.faultString)
    

def privacyText():
    s = rpcServer.getServer()

    try:
        return rpcServer.doCall(s.registration.privacy_statement)
    except xmlrpclib.Fault, f:
        if f.faultCode == 99:
            raise rhnErrors.DelayError(f.faultString)
        else:
            raise rhnErrors.CommunicationError(f.faultString)

def finishMessage(systemId):

#    ret =  (-1, "blippyFoobar", "this is some text\n\n\nmore\n\ntext\\n\nfoo")
#    return ret

    s = rpcServer.getServer()
    try:
        ret =  rpcServer.doCall(s.registration.finish_message, systemId)
        return ret
    except xmlrpclib.Fault, f:
        if f.faultCode == 99:
            raise rhnErrors.DelayError(f.faultString)
        else:
            raise rhnErrors.CommunicationError(f.faultString)

def getCaps():
    s = rpcServer.getServer()

    
    try:
        rpcServer.doCall(s.registration.welcome_message)
    except xmlrpclib.Fault, f:
        if f.faultCode == 99:
            raise rhnErrors.DelayError(f.faultString)
        else:
            raise f

    caps = capabilities.Capabilities()
    response_headers =  s.get_response_headers()
    caps.populate(response_headers)

    # figure out if were missing any needed caps
    caps.validate()
    
def termsAndConditions():
    s = rpcServer.getServer()

    try:
        return rpcServer.doCall(s.registration.terms_and_conditions)
    except xmlrpclib.Fault, f:
        if f.faultCode == 99:
            raise rhnErrors.DelayError(f.faultString)
        else:
            raise rhnErrors.CommunicationError(f.faultString)

def reserveUser(username, password):
    s = rpcServer.getServer()
    
    try:
        ret = rpcServer.doCall(s.registration.reserve_user, username, password)
    except xmlrpclib.Fault, f:
        if f.faultCode == -3:
            # account already in use
            raise rhnErrors.ValidationError(f.faultString)
        elif f.faultCode == -14:
            # too short password
            raise rhnErrors.ValidationError(f.faultString)
        elif f.faultCode == -15:
            # bad chars in username
            raise rhnErrors.ValidationError(f.faultString)
        elif f.faultCode == 99:
            raise rhnErrors.DelayError(f.faultString)
        else:
            raise rhnErrors.CommunicationError(f.faultString)

    return ret

def validateRegNum(regNum):
    s = rpcServer.getServer()

    try:
        rpcServer.doCall(s.registration.validate_reg_num,regNum)
    except xmlrpclib.Fault, f:
        if f.faultCode == -16:
            # invalid
            raise rhnErrors.ValidationError(f.faultString)
        elif f.faultCode == 99:
            raise rhnErrors.DelayError(f.faultString)
        else:
            raise rhnErrors.CommunicationError(f.faultString)


def registerUser(username, password,
                 email = None, orgid = None, orgpassword = None):
    s = rpcServer.getServer()

    try:
        if not email == None:
            if orgid and orgpassword:
                rpcServer.doCall(s.registration.new_user,
                                 username, password, email, orgid, orgpassword)
            else:
                rpcServer.doCall(s.registration.new_user,
                                 username, password, email)
        else:
                rpcServer.doCall(s.registration.new_user, username, password)
    except xmlrpclib.Fault, f:
        if f.faultCode == 99:
            raise rhnErrors.DelayError(f.faultString)
        else:
            raise rhnErrors.CommunicationError(f.faultString)


def registerSystem(username = None, password = None,
                   profileName = None, packages = None,
                   token = None, other = None):
    s = rpcServer.getServer()

    auth_dict =  { "profile_name" : profileName,
                   "os_release" : rhnUtils.getVersion(),
		   "release_name" : rhnUtils.getOSRelease(),
                   "architecture" : rhnUtils.getArch() };

    # dict of other bits to send up
    if other:
        for (key, item) in other.items():
            auth_dict[key] = item

    if token:
        auth_dict["token"] = token
    else:
        auth_dict["username"] = username
        auth_dict["password"] = password


    auth_dict["uuid"] = cfg["uuid"] or ""
    auth_dict["rhnuuid"] = cfg["rhnuuid"] or ""
    

    try:
        if packages == None:
            ret = rpcServer.doCall(s.registration.new_system,
                         auth_dict)
        else:
            ret = rpcServer.doCall(s.registration.new_system,
                         auth_dict,
                         packages)
    except xmlrpclib.Fault, f:
        if abs(f.faultCode) == 99:
            raise rhnErrors.DelayError(f.faultString)
        elif abs(f.faultCode) == 60:
            raise rhnErrors.AuthenticationTicketError(f.faultString)
        elif abs(f.faultCode) == 105:
            raise rhnErrors.RhnUuidUniquenessError(f.faultString)
        else:
            raise rhnErrors.CommunicationError(f.faultString)

    return ret


def registerProduct(systemId, productInfo):
    s = rpcServer.getServer()

    try:
        rpcServer.doCall(s.registration.register_product,
                         systemId, productInfo)
    except xmlrpclib.Fault, f:
        if f.faultCode == 99:
            raise rhnErrors.DelayError(f.faultString)
        else:
            raise rhnErrors.CommunicationError(f.faultString)


def sendSerialNumber(systemId, num):
    s = rpcServer.getServer()

    try:
        if cfg["oemId"] != None:
            rpcServer.doCall(s.registration.send_serial, systemId, num,
                                       cfg["oemId"])
        else:
            rpcServer.doCall(s.registration.send_serial, systemId, num)
    except xmlrpclib.Fault, f:
        if f.faultCode == 99:
            raise rhnErrors.DelayError(f.faultString)
        else:
            raise rhnErrors.CommunicationError(f.faultString)


def sendHardware(systemId, hardwareList):
    s = rpcServer.getServer()

    try:
        rpcServer.doCall(s.registration.add_hw_profile, systemId, hardwareList)
    except xmlrpclib.Fault, f:
        if f.faultCode == 99:
            raise rhnErrors.DelayError(f.faultString)
        else:
            raise rhnErrors.CommunicationError(f.faultString)

def sendPackages(systemId, packageList):
    s = rpcServer.getServer()

    try:
        rpcServer.doCall(s.registration.add_packages, systemId, packageList)
    except xmlrpclib.Fault, f:
        if f.faultCode == 99:
            raise rhnErrors.DelayError(f.faultString)
        else:
            raise rhnErrors.CommunicationError(f.faultString)

def updatePackages(systemId, packageList):
    s = rpcServer.getServer()

    try:
        rpcServer.doCall(s.registration.update_packages, systemId, packageList)
    except xmlrpclib.Fault, f:
        if f.faultCode == 99:
            raise rhnErrors.DelayError(f.faultString)
        else:
            raise rhnErrors.CommunicationError(f.faultString)

def listPackages(systemId):
    s = rpcServer.getServer()

    try:
        rpcServer.doCall(s.registration.list_packages,systemId)
    except xmlrpclib.Fault, f:
        if f.faultCode == 99:
            raise rhnErrors.DelayError(f.faultString)
        else:
            raise rhnErrors.CommunicationError(f.faultString)


# PORTME

def up2datePackages(systemId):
    pass
#def updatePackages(systemId):
#    s = rpcServer.getServer()
#
#    try:
#        rpcServer.doCall(s.registration.add_packages,
#                         systemId, rpmUtils.getInstalledPackageList())
#    except xmlrpclib.Fault, f:
#        if f.faultCode == 99:
#            raise up2dateErrors.DelayError(f.faultString)
#        else:
#            raise up2dateErrors.CommunicationError(f.faultString)
