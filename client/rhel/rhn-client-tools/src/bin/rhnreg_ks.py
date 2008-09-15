#!/usr/bin/python
#
# Registration client for the Red Hat Network for useage with kickstart 
# Copyright (c) 1999-2006 Red Hat, Inc.  Distributed under GPL.
#
# Authors:
#       Adrian Likins <alikins@redhat.com>
#       James Bowes <jbowes@redhat.com>
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

import sys
import os

from rhpl.translate import _

sys.path.append("/usr/share/rhn/")

from up2date_client import rhnreg
from up2date_client import hardware
from up2date_client import rpmUtils
from up2date_client import up2dateErrors
from up2date_client import rhncli


class RegisterKsCli(rhncli.RhnCli):

    def __init__(self):
        super(RegisterKsCli, self).__init__()

        self.optparser.add_option("--profilename", action="store",
            help=_("Specify a profilename")),
        self.optparser.add_option("--username", action="store",
            help=_("Specify a username")),
        self.optparser.add_option("--password", action="store",
            help=_("Specify a password")),
        self.optparser.add_option("--email", action="store",
            help=_("Specify an email address")),
        self.optparser.add_option("--systemorgid", action="store",
            help=_("Specify an organizational id for this system")),
        self.optparser.add_option("--serverUrl", action="store",
            help=_("Specify a url to use as a server")),
        self.optparser.add_option("--sslCACert", action="store",
            help=_("Specify a file to use as the ssl CA cert")),
        self.optparser.add_option("--activationkey", action="store",
            help=_("Specify an activation key")),
        self.optparser.add_option("--subscription", action="store",
            help=_("Specify a installation number to use")),
        self.optparser.add_option("--use-eus-channel", action="store_true",
            help=_("Subscribe this system to the EUS channel tied to the system's redhat-release")),
        self.optparser.add_option("--contactinfo", action="store_true",
            default=False, help=_("Read contact info from stdin")),
        self.optparser.add_option("--nohardware", action="store_true",
            default=False, help=_("Do not probe or upload any hardware info")),
        self.optparser.add_option("--nopackages", action="store_true",
            default=False, help=_("Do not profile or upload any package info")),
        self.optparser.add_option("--novirtinfo", action="store_true",
            default=False, help=_("Do not upload any virtualization info")),
        self.optparser.add_option("--norhnsd", action="store_true",
            default=False, help=_("Do not start rhnsd after completion")),
        self.optparser.add_option("--force", action="store_true", default=False,
            help=_("Register the system even if it is already registered")),

    def main(self):
        self.__saveSslConfig()

        if not (self.options.activationkey or 
                (self.options.username and self.options.password)):
            print _("A username and password are required "\
                    "to register a system.")
            sys.exit(-1)

        if rhnreg.registered() and not self.options.force:
            print _("This system is already registered. Use --force to override")
            sys.exit(-1)

        rhnreg.getCaps()
        
        if not self.options.activationkey:
            # reserve the username
            ret = rhnreg.reserveUser(self.options.username,
                self.options.password)
            rhnreg.registerUser(self.options.username, self.options.password,
                self.options.email)

        if not self.options.nopackages:
            getInfo = 0
            if rhnreg.cfg['supportsExtendedPackageProfile']:
                getInfo = 1
            packageList = rpmUtils.getInstalledPackageList(getInfo=getInfo)
        else:
            packageList = []

        
        hardwareList = hardware.Hardware()
        
        if self.options.profilename:
            profilename = self.options.profilename
        else:
            profilename = RegisterKsCli.__generateProfileName(hardwareList)

        other = {}
        if self.options.subscription:
            other['registration_number'] = self.options.subscription
        if self.options.systemorgid:
            other['org_id'] = self.options.systemorgid

        # Try to get the virt uuid and put it in "other".
        (virt_uuid, virt_type) = rhnreg.get_virt_info()
        if not virt_uuid is None:
            other['virt_uuid'] = virt_uuid
            other['virt_type'] = virt_type
            
        # If specified, send up the EUS channel label for subscription.
        if self.options.use_eus_channel:
            if self.options.activationkey:
                print _("Usage of --use-eus-channel option with --activationkey is not supported. Please use username and password instead.")
                sys.exit(-1)
            if not rhnreg.server_supports_eus():
                print _("The server you are registering against does not support EUS.")
                sys.exit(-1)
            
            channels = rhnreg.getAvailableChannels(self.options.username,
                                                   self.options.password,
                                                   other)
            other['channel'] = channels['default_channel']

        try:
            if self.options.activationkey:
                systemId = rhnreg.registerSystem(token = self.options.activationkey,
                                                 profileName = profilename,
                                                 other = other)
            else:
                systemId = rhnreg.registerSystem(self.options.username,
                    self.options.password, profilename, other = other)
        except (up2dateErrors.AuthenticationTicketError,
                up2dateErrors.RhnUuidUniquenessError,
                up2dateErrors.CommunicationError), e:
            print "%s" % e.errmsg
            sys.exit(1)
            
        # collect hardware info, inluding hostname
        if not self.options.nohardware:
            rhnreg.sendHardware(systemId, hardwareList)

        if not self.options.nopackages:
            rhnreg.sendPackages(systemId, packageList)

        if self.options.contactinfo:
            contactinfo = RegisterKsCli.__readContactInfo()
            
            # collect oemInfo 
            oemInfo = rhnreg.getOemInfo()
            
            if rhnreg.cfg['supportsUpdateContactInfo']:
                if self.options.username and self.options.password:
                    rhnreg.updateContactInfo(self.options.username,
                        self.options.password, oemInfo)
            else:
                rhnreg.registerProduct(systemId, contactinfo, oemInfo)

        # write out the new id
        rhnreg.writeSystemId(systemId)

        # Send virtualization information to the server.  We must do this
        # *after* writing out the system id.
        if not self.options.novirtinfo:
            rhnreg.sendVirtInfo(systemId)

        # do this after writing out system id, bug #147513
        if not self.options.norhnsd:
            rhnreg.startRhnsd()

        RegisterKsCli.__runRhnCheck()

    def __saveSslConfig(self):
        save_cfg = 0
        if self.options.serverUrl:
            rhnreg.cfg.set("serverURL", self.options.serverUrl)
            save_cfg = 1
        if self.options.sslCACert:
            rhnreg.cfg.set("sslCACert", self.options.sslCACert)
            save_cfg = 1

        if save_cfg:
            rhnreg.cfg.save()
 
    @staticmethod
    def __readContactInfo():
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
            (key, value) = i.split(':')
            info[key] = value.strip()

        #cleanse the hash for just the values we care about
        for i in info.keys():
            if i not in productInfo:
                del info[i]

        return info

    @staticmethod
    def __generateProfileName(hardwareList):
        hostname = None
        ipaddr = None
        profileName = None
        for hw in hardwareList:
            if hw['class'] == 'NETINFO':
                hostname = hw.get('hostname')
                ipaddr = hw.get('ipaddr')
                
        if hostname:
            profileName = hostname
        else:
            if ipaddr:
                profileName = ipaddr
                
        if not profileName:
            print _("A profilename was not specified, "\
                    "and hostname and IP address could not be determined "\
                    "to use as a profilename, please specify one.")
            sys.exit(-1)

        return profileName

    @staticmethod
    def __runRhnCheck():
        os.system("/usr/sbin/rhn_check")


if __name__ == "__main__":
    cli = RegisterKsCli()
    cli.run()
