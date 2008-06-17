#!/usr/bin/python


# a dict with "capability name" as the key, and the version
# as the value.

import UserDict
import os
import sys
import config
import rhnErrors
import rpcServer
import string
from translate import _

neededCaps = {"caneatCheese": {'version':"21"},
              "supportsAutoUp2dateOption": {'version': "1"},
              "registration.finish_message": {'version': "1"},
              "xmlrpc.packages.extended_profile": {'version':"1"}}
              #"registration.extendedPackageProfile": {'version':"1"}}

def parseCap(capstring):
    value = None
    caps = string.split(capstring, ',')

    capslist = []
    for cap in caps:
        try:
            (key_version, value) = map(string.strip, string.split(cap, "=", 1))
        except ValueError:
            # Bad directive: not in 'a = b' format
            continue
            
        # parse out the version
        # lets give it a shot sans regex's first...
        (key,version) = string.split(key_version, "(", 1)
        
        # just to be paranoid
        if version[-1] != ")":
            print "something broke in parsing the capabilited headers"
        #FIXME: raise an approriate exception here...

        # trim off the trailing paren
        version = version[:-1]
        data = {'version': version, 'value': value}

        capslist.append((key, data))

    return capslist

class Capabilities(UserDict.UserDict):
    def __init__(self):
        UserDict.UserDict.__init__(self)
        self.missingCaps = {}
        #self.populate()
#        self.validate()
        self.neededCaps = neededCaps
        self.cfg = config.initUp2dateConfig()


    def populate(self, headers):
        for key in headers.keys():
            if key == "x-rhn-server-capability":
                capslist = parseCap(headers[key])

                for (cap,data) in capslist:
                    self.data[cap] = data

    def parseCapVersion(self, versionString):
        index = string.find(versionString, '-')
        # version of "-" is bogus, ditto for "1-"
        if index > 0:
            rng = string.split(versionString, "-")
            start = rng[0]
            end = rng[1]
            versions = range(int(start), int(end)+1)
            return versions

        vers = string.split(versionString, ':')
        if len(vers) > 1:
            versions = map(lambda a:int(a), vers)
            return versions

        return [int(versionString)]

    def validateCap(self, cap, capvalue):
        if not self.data.has_key(cap):
            errstr = _("This client requires the server to support %s, which the current " \
                       "server does not support") % cap
            self.missingCaps[cap] = None
        else:
            data = self.data[cap]
            # DOES the server have the version we need
            if int(capvalue['version']) not in self.parseCapVersion(data['version']):
                self.missingCaps[cap] =  self.neededCaps[cap]


    def validate(self):
        for key in self.neededCaps.keys():
            self.validateCap(key, self.neededCaps[key])

        self.workaroundMissingCaps()

    def workaroundMissingCaps(self):
        # if we have caps that we know we want, but we can
        # can work around, setup config variables here so
        # that we know to do just that
        tmpCaps = self.missingCaps

# this is an example of how to work around it
        key = 'caneatCheese'
        if tmpCaps.has_key(key):
            # do whatevers needed to workaround
            del tmpCaps[key]
        else:
            # we support this, set a config option to
            # indicate that possibly
            pass


        key = 'supportsAutoUp2dateOption'
        if tmpCaps.has_key(key):
            self.cfg['supportsAutoUp2dateOption'] = 0
            del tmpCaps[key]
        else:
            self.cfg['supportsAutoUp2dateOption'] = 1

        key = 'registration.finish_message'
        if tmpCaps.has_key(key):
            self.cfg['supportsFinishMessage'] = 0
            del tmpCaps[key]
        else:
            self.cfg['supportsFinishMessage'] = 1

        key = "xmlrpc.packages.extended_profile"
        if tmpCaps.has_key(key):
            self.cfg['supportsExtendedPackageProfile'] = 0
            # We can't work around this on Solaris
        else:
            self.cfg['supportsExtendedPackageProfile'] = 1

        #print "self.cfg['supportsExtendedPackageProfile']: %s" % self.cfg['supportsExtendedPackageProfile']
        #print tmpCaps
            
        # if we want to blow up on missing caps we cant eat around
        missingCaps = []
        wrongVersionCaps = []

        if len(tmpCaps):
            for cap in tmpCaps:
                capInfo = tmpCaps[cap]
                if capInfo == None:
                    # it's completly mssing
                    missingCaps.append((cap, capInfo))
                else:
                    wrongVersionCaps.append((cap, capInfo))


        errString = ""
        errorList = []
        if len(wrongVersionCaps):
            for (cap, capInfo) in wrongVersionCaps:
                errString = errString + "Needs %s of version: %s but server has version: %s\n" % (cap,
                                                                                    capInfo['version'],
                                                                                    self.data[cap]['version'])
                errorList.append({"capName":cap, "capInfo":capInfo, "serverVersion":self.data[cap]})

        if len(missingCaps):
            for (cap, capInfo) in missingCaps:
                errString = errString + "Needs %s but server does not support that capability\n" % (cap)
                errorList.append({"capName":cap, "capInfo":capInfo, "serverVersion":""})

        if len(errString):
#            print errString
            # raise this once we have exception handling code in place to support it
            raise rhnErrors.ServerCapabilityError(errString, errorList)
