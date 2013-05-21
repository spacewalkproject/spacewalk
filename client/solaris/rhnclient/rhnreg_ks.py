#!/usr/bin/python
#
# Registration client for the Red Hat Network for useage with kickstart 
# Copyright (c) 1999--2012 Red Hat, Inc.  Distributed under GPL.
#
# Author: Adrian Likins <alikins@redhat.com>
#
#  see the output of "--help" for the valid options. 
#
#  The contact info is in the form or a "key: value" one per line.
#  valid keys are:
#       reg_num, title, first_name, last_name, company,
#       position, address1, address2, city, state, zip,
#       country, phone, fax, contact_email, contact_mail,
#       contact_phone, contact_fax, contact_special,
#       contact_newsletter
#
#
#
import getopt
import sys
import os
import string
from rhn.connections import idn_pune_to_unicode
from spacewalk.common.rhnConfig import CFG, initCFG

PREFIX="/"
modulepath="%s/usr/share/rhn/" % PREFIX
sys.path.append(modulepath)
from rhn.client.translate import _
from rhn.client import hardware
#from rhn.client import packageUtils
from rhn.client import rhnReg
from rhn.client import rhnErrors
from rhn.client import rhnUtils


# XXX: convert to use Optik
def printUsage():
    print _("Usage: rhnreg_ks [options]")
    print ""
    print _("Available command line options:")
    print _("-h, --help                     - this help ")
    print _("    --profilename=<value>      - specify a profilename")
    print _("    --username=<value>         - specify a username ")
    print _("    --password=<value>         - specify a password ")
    print _("    --orgid=<value>            - specify a organizational id ")
    print _("    --orgpassword=<value>      - specify a organizational password")
    print _("    --noSSLServerURL=<url>     - specify a url for a non ssl server")
    print _("    --useNoSSLForPackages      - dont use ssl to download packages")
    print _("    --sslCACert=<path>         - specify a file to use as the ssl CA cert")
    print _("    --serverUrl=<URL>          - specify a url to use as a server") 
    print _("    --email=<value>            - specify a email address ")
    print _("    --activationkey=<value>    - specify an activation key ")
    print _("    --contactinfo              - read contact info from stdin ")
    print _("    --nohardware               - do not probe or upload any hardware info ")
    print _("    --nopackages               - do not profile or upload any package info ")
    print _("    --force                    - register the system even if it is already registered")
    print _("    --version                  - display the version ")
    print _("    --proxy                    - specify an http proxy to use ")
    print _("    --proxyUser=<value>        - specify a username to use with an authenticated http proxy")
    print _("    --proxyPassword=<value>    - specify a password to use with an authenticated http proxy")
    print ""


def showVersion():
        initCFG('web')
        print CFG.PRODUCT_NAME + " Registration Agent "\
              "(Kickstart Version) v%s" % rhnReg.version()
        print "Copyright (c) 1999-2002 Red Hat, Inc."
        print _("Licensed under terms of the GPL.")


def readContactInfo():
    productInfo = [
        "reg_num",
        "title",
        "first_name",
        "last_name",
        "company",
        "position",
        "address1",
        "address2",
        "city",
        "state",
        "zip",
        "country",
        "phone",
        "fax",
        "contact_email",
        "contact_mail",
        "contact_phone",
        "contact_fax",
        "contact_special",
        "contact_newsletter"]
    
    # read a file from standard in or filename if specified
    L = sys.stdin.readlines()

    # parse it and build a dict
    info = {}
    for i in L:
        (key, value) = string.split(i, ':')
        info[key] = string.strip(value)

    #cleanse the hash for just the values we care about
    for i in info.keys():
        if i not in productInfo:
            del info[i]

    return info

def generateProfileName(hardwareList):
    hostname = None
    ipaddr = None
    profileName = None
    for hw in hardwareList:
        if hw['class'] == 'NETINFO':
            hostname = hw.get('hostname')
            ipaddr = hw.get('ipaddr')
            
    if hostname:
        profileName = idn_pune_to_unicode(hostname)
    else:
        if ipaddr:
            profileName = ipaddr
            
    if not profileName:
        print _("A profilename was not specified, "\
                "and hostname and IP address could not be determined "\
                "to use as a profilename, please specify one.")
        sys.exit(-1)

    return profileName


def runRhnCheck():
    if rhnReg.cfg.has_key("rhnCheckPath"):
	rhncheck = rhnReg.cfg['rhnCheckPath']
    else:
	rhncheck = os.path.normpath("%s/usr/sbin/rhn_check" % PREFIX)
    os.system(rhncheck)


def main(arglist=[]):
    
    if not len(arglist):
        arglist = sys.argv[1:]
    try:
        optlist, args = getopt.getopt(arglist,
                                      'h',
                                      ['help',
                                       'version',
                                       'username=','password=',
                                       'cryptedpassword=',
                                       'orgid=','orgpassword=',
                                       'profilename=',
                                       'nopackages',
                                       'nohardware',
                                       'norhnsd',
                                       'activationkey=',
                                       'serialnumber=',
                                       'serverUrl=',
                                       'noSSLServerURL=', 
                                       'useNoSSLForPackages',
                                       'proxy=',
                                       'proxyUser=',
                                       'proxyPassword=',
                                       'sslCACert=', 
                                       'contactinfo',
                                       'email=',"force",])
    except getopt.error, e:
        print _("Error parsing command list arguments: %s") % e
        printUsage()
        sys.exit(1)

    username = password = orgid = orgPassword = profilename = email = None
    force = None
    # for now, default to not sending packageinfo
    nopackages = 0
    nohardware = None
    serialnumber = None
    contactinfo = None
    norhnsd = 0
    oemInfo = {}
    ca_certs = []

    # to indicate we've potentially ran some sort of setup
    # to prevent up2date from asking this on first run in
    # the "rhnregks;up2date -u" case
    rhnReg.cfg.set("networkSetup", 1)
    rhnReg.cfg.save()
    
    save_cfg = 0
    for opt in optlist:
        if opt[0] in ['-h', "--help"]:
            printUsage()
            sys.exit(-1)
        if opt[0] == "--username":
            username = str(opt[1])
        if opt[0] == "--password":
            password = str(opt[1])
        if opt[0] == "--orgid":
            orgid = str(opt[1])
        if opt[0] == "--orgpassword":
            orgPassword = str(opt[1])
        if opt[0] == "--cryptedorgpassword":
            cryptOrgPassword = str(opt[1])
        if opt[0] == "--cryptedpassword":
            cryptPassword = str(opt[1])
        if opt[0] == "--profilename":
            profilename = str(opt[1])
        if opt[0] == "--email":
            email = str(opt[1])
        if opt[0] == "--force":
            force = 1
        if opt[0] == "--nopackages":
            nopackages = 1
        if opt[0] == "--nohardware":
            nohardware = 1
        if opt[0] == "--norhnsd":
            norhnsd = 1  
        if opt[0] == "--serialnumber":
            print "--serialnumber is deprecated, please use --activationkey"
            serialnumber = str(opt[1])
        if opt[0] == "--activationkey":
            serialnumber = str(opt[1])
        if opt[0] == "--serverUrl":
            try:
                rhnReg.cfg.set("serverURL", rhnUtils.fix_url(opt[1]))
            except rhnErrors.InvalidUrlError:
                print "%s specified is not a valid url" % opt[1]
            save_cfg = 1
        if opt[0] == "--noSSLServerURL":
            rhnReg.cfg.set("noSSLServerURL", opt[1])
            save_cfg = 1
        if opt[0] == "--useNoSSLForPackages":
            rhnReg.cfg.set("useNoSSLForPackages", 1)
            save_cfg = 1
        if opt[0] == "--proxy":
            rhnReg.cfg.set("httpProxy", opt[1])
	    rhnReg.cfg.set("enableProxy", 1)
            save_cfg = 1
        if opt[0] == "--proxyUser":            
            rhnReg.cfg.set("proxyUser", opt[1])
            rhnReg.cfg.set("enableProxyAuth", 1)
            save_cfg = 1
        if opt[0] == "--proxyPassword":
            rhnReg.cfg.set("proxyPassword", opt[1])
            rhnReg.cfg.set("enableProxyAuth", 1)
            save_cfg = 1
        if opt[0] == "--sslCACert":
            ca_certs.append(opt[1])
#            rhnReg.cfg.set("sslCACert", opt[1])
            save_cfg = 1
        if opt[0] == "--contactinfo":
            contactinfo = readContactInfo()
        if opt[0] == "--version":
            showVersion()
            sys.exit(-1)

    if ca_certs:
        rhnReg.cfg.set("sslCACert", ca_certs)

    if save_cfg:
        rhnReg.cfg.save()
        
    if rhnReg.registered() and not force:
        print _("This system is already registered. Use --force to override")
        sys.exit(-1)

    if not serialnumber and (not username or not password and not email):
        print _("A username, password and email address are required "\
                "to register a system.")
        sys.exit(-1)

    rhnReg.getCaps()
    
    if not serialnumber:
        # reserver the username
        ret = rhnReg.reserveUser(username, password)
        rhnReg.registerUser(username, password, email, orgid, orgPassword)

#    FIXME (20050422): On Solaris we need call into smartpm for this
#    if not nopackages:
#        getInfo = 0
#        if rhnReg.cfg['supportsExtendedPackageProfile']:
#            getInfo = 1
#        # PORTME, if we care...
#        packageList = packageUtils.getInstalledPackageList()
#    else:
#        packageList = []


    # collect oemInfo 
    oemInfo = rhnReg.getOemInfo()
    
    hardwareList = hardware.Hardware()
    
    if not profilename:
        profilename = generateProfileName(hardwareList)

    try:
        if serialnumber:
            systemId = rhnReg.registerSystem(token = serialnumber,
                                             profileName = profilename)
        else:
            systemId = rhnReg.registerSystem(username, password, profilename)
    except rhnErrors.AuthenticationTicketError, e:
        print "%s" % e.errmsg
        sys.exit(1)
    except rhnErrors.RhnUuidUniquenessError, e:
        print "%s" % e.errmsg
        sys.exit(1)
    except rhnErrors.CommunicationError, e:
        print "%s" % e.errmsg
        sys.exit(1)
        
        
    if serialnumber:
        rhnReg.sendSerialNumber(systemId, serialnumber)

    # collect hardware info, inluding hostname
    if not nohardware:
        # FIXME (20050629): should add i86pc to db
        if hardwareList[0]["platform"] == "i86pc":
            hardwareList[0]["platform"] = "i386"
        rhnReg.sendHardware(systemId, hardwareList)

#    FIXME (20050422): On Solaris we need call into smartpm for this
#    if not nopackages:
#        rhnReg.sendPackages(systemId, packageList)

    if contactinfo:
        rhnReg.registerProduct(systemId, contactinfo)

    if not norhnsd:
        rhnReg.startRhnsd()

    # write out the new id
    rhnReg.writeSystemId(systemId)

    runRhnCheck()


if __name__ == "__main__":
    main()
