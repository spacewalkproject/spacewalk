#!/usr/bin/python
#
# This file is a portion of the Red Hat Update Agent
# Copyright (c) 1999 - 2002 Red Hat, Inc.  Distributed under GPL
#
# Authors:
#       Cristian Gafton <gafton@redhat.com>
#       Adrian Likins   <alikins@redhat.com>
#
"""
This module includes the Config and Up2date Config classes use by the
up2date agent to hold config info.
""" # " == emacs sucks

import os
import sys
import string
from translate import _

#cfg = None

if sys.platform[:5] == "sunos":
    PREFIX="/opt/redhat/rhn/solaris/"
else:
    PREFIX="/"
RHN_SYSCONFIG_DIR = os.path.normpath("%s/etc/sysconfig/rhn" % PREFIX)
UP2DATE_CONFIG = os.path.join(RHN_SYSCONFIG_DIR, "up2date")
UP2DATE_UUID = os.path.join(RHN_SYSCONFIG_DIR, "up2date-uuid")
UP2DATE_SYSTEMID = os.path.join(RHN_SYSCONFIG_DIR, "systemid")
UP2DATE_OEMINFO = os.path.join(RHN_SYSCONFIG_DIR, "oeminfo")
UP2DATE_KEYRING = os.path.join(RHN_SYSCONFIG_DIR, "up2date-keyring.gpg")
CA_CERT = os.path.normpath("%s/usr/share/rhn/RHNS-CA-CERT" % PREFIX)
SPOOL_DIR = os.path.normpath("%s/var/spool/up2date" % PREFIX)

# XXX: This could be moved in a more "static" location if it is too
# much of an eye sore
Defaults = {
    'enableProxy'       : ("Use a HTTP Proxy",
                           0),
    'serverURL'         : ("Remote server URL",
                           "https://xmlrpc.rhn.redhat.com/XMLRPC"),
    'noSSLServerURL'    : ("Remote server URL without SSL",
                           "http://xmlrpc.rhn.redhat.com/XMLRPC"),
    'debug'             : ("Whether or not debugging is enabled",
                           0),
    'systemIdPath'      : ("Location of system id",
                           UP2DATE_SYSTEMID),
    'adminAddress'      : ("List of e-mail addresses for update agent "\
                           "to communicate with when run in batch mode",
                           ["root@localhost"]),
    'storageDir'        : ("Where to store packages and other data when "\
                           "they are retrieved",
                           SPOOL_DIR),
    'pkgSkipList'       : ("A list of package names, optionally including "\
                           "wildcards, to skip",
                           ["kernel*"]),
    'pkgsToInstallNotUpdate' : ("A list of provides names or package names of packages "\
                                "to install not update",
                           ["kernel", "kernel-unsupported"]),
    'removeSkipList'    : ("A list of package names, optionally including "\
                           "wildcards, that up2date will not remove",
                           ["kernel*"]),
    'fileSkipList'      : ("A list of file names, optionally including "\
                           "wildcards, to skip",
                           []),
    'noReplaceConfig'   : ("When selected, no packages that would change "\
                           "configuration data are automatically installed",
                           1),
    'retrieveOnly'      : ("Retrieve packages only",
                           0),
    'retrieveSource'    : ("Retrieve source RPM along with binary package",
                           0),
    'keepAfterInstall'  : ("Keep packages on disk after installation",
                           0),
    'versionOverride'   : ("Override the automatically determined "\
                           "system version",
                           ""),
    'useGPG'            : ("Use GPG to verify package integrity",
                           1),
    'headerCacheSize'   : ("The maximum number of rpm headers to cache in ram",
                           40),
    'headerFetchCount'  : ("The maximimum number of rpm headers to "\
                           "fetch at once", 
                           10),
    'forceInstall'      : ("Force package installation, ignoring package, "\
                           "file and config file skip list",
                           0),
    'httpProxy'         : ("HTTP proxy in host:port format, e.g. "\
                           "squid.redhat.com:3128",
                           ""),
    'proxyUser'         : ("The username for an authenticated proxy",
                           ""),
    'proxyPassword'     : ("The password to use for an authenticated proxy",
                           ""),
    'enableProxyAuth'   : ("To use an authenticated proxy or not",
                           0),
    'noBootLoader'      : ("To disable modification of the boot loader "\
                           "(lilo, silo, etc)",
                           0),
    'networkRetries'    : ("Number of attempts to make at network "\
                           "connections before giving up",
                           5),
    'sslCACert'         : ("The CA cert used to verify the ssl server",
                           CA_CERT),
    'gpgKeyRing'        : ("The location of the gpg keyring to use for "\
                           "package checking.",
                           UP2DATE_KEYRING),
    'enableRollbacks'   : ("Determine if up2date should create "\
                           "rollback rpms",
                           0),
    'noReboot'          : ("Disable the reboot action",
                           0),
    'updateUp2date'     : ("Allow up2date to update itself when possible", 1),
    'disallowConfChanges': ("Config options that can not be overwritten by a config update action",
                            ['sslCACert','useNoSSLForPackages','noSSLServerURL',
                             'serverURL','disallowConfChanges', 'noReboot']),
}

# a peristent configuration storage class
class ConfigFile:
    "class for handling persistent config options for the client"
    def __init__(self, filename = None):
	self.dict = {}
	self.fileName = filename
        if self.fileName:
            self.load()
            
    def load(self, filename = None):
        if filename:
            self.fileName = filename
	if self.fileName == None:
	    return
        if not os.access(self.fileName, os.R_OK):
            print "warning: can't access %s" % self.fileName
            return
        
        f = open(self.fileName, "r")

	for line in f.readlines():
            # strip comments
            if '#' in line:
                line = line[:string.find(line, '#')]
            line = string.strip(line)            
            if not line:
		continue

            value = None
	    try:
		(key, value) = map(string.strip, string.split(line, "=", 1))
	    except ValueError:
                # Bad directive: not in 'a = b' format
		continue

            # decode a comment line
            comment = None
	    pos = string.find(key, "[comment]")
	    if pos != -1:
		key = key[:pos]
                comment = value
                value = None

            # figure out if we need to parse the value further
            if value:
		# possibly split value into a list
		values = string.split(value, ";")
		if len(values) == 1:
		    try:
			value = int(value)
		    except ValueError:
			pass
		elif values[0] == "":
                    value = []
		else:
                    value = values[:-1]

            # now insert the (comment, value) in the dictionary
            newval = (comment, value)
            if self.dict.has_key(key): # do we need to update
                newval = self.dict[key]
                if comment is not None: # override comment
                    newval = (comment, newval[1])
                if value is not None: # override value
                    newval = (newval[0], value)
            self.dict[key] = newval
	f.close()

    def save(self):
	if self.fileName == None:
	    return
        
        f = open(self.fileName, "w")
        os.chmod(self.fileName, 0600)

	f.write("# Automatically generated Red Hat Update Agent "\
                "config file, do not edit.\n")
	f.write("# Format: 1.0\n")
	f.write("")
	for key in self.dict.keys():
	    val = self.dict[key]
	    f.write("%s[comment]=%s\n" % (key, val[0]))
	    if type(val[1]) == type([]):
		f.write("%s=%s;\n" % (key, string.join(map(str, val[1]), ';')))
	    else:
		f.write("%s=%s\n" % (key, val[1]))
	    f.write("\n")
	f.close()

    # dictionary interface
    def has_key(self, name):
        return self.dict.has_key(name)
    def keys(self):
	return self.dict.keys()
    def values(self):
        return map(lambda a: a[1], self.dict.values())
    def update(self, dict):
        self.dict.update(dict)
    # we return None when we reference an invalid key instead of
    # raising an exception
    def __getitem__(self, name):
        if self.dict.has_key(name):
            return self.dict[name][1]
        return None    
    def __setitem__(self, name, value):
        if self.dict.has_key(name):
            val = self.dict[name]
        else:
            val = (None, None)
	self.dict[name] = (val[0], value)
    # we might need to expose the comments...
    def info(self, name):
        if self.dict.has_key(name):
            return self.dict[name][0]
        return ""

# a superclass for the ConfigFile that also handles runtime-only
# config values
class Config:
    def __init__(self, filename = None):
        self.stored = ConfigFile()
        self.stored.update(Defaults)
        if filename:
            self.stored.load(filename)
        self.runtime = {}

    # classic dictionary interface: we prefer values from the runtime
    # dictionary over the ones from the stored config
    def has_key(self, name):
        if self.runtime.has_key(name):
            return 1
        if self.stored.has_key(name):
            return 1
        return 0
    def keys(self):
        ret = self.runtime.keys()
        for k in self.stored.keys():
            if k not in ret:
                ret.append(k)
        return ret
    def values(self):
        ret = []
        for k in self.keys():
            ret.append(self.__getitem__(k))
        return ret
    def items(self):
        ret = []
        for k in self.keys():
            ret.append((k, self.__getitem__(k)))
        return ret
    def __len__(self):
        return len(self.keys())
    def __setitem__(self, name, value):
        self.runtime[name] = value
    # we return None when nothing is found instead of raising and exception
    def __getitem__(self, name):
        if self.runtime.has_key(name):
            return self.runtime[name]
        if self.stored.has_key(name):
            return self.stored[name]
        return None
        
    # These function expose access to the peristent storage for
    # updates and saves
    def info(self, name): # retrieve comments
        return self.stored.info(name)    
    def save(self):
        self.stored.save()
    def load(self, filename):
        self.stored.load(filename)
        # make sure the runtime cache is not polluted
        for k in self.stored.keys():
            if not self.runtime.has_key(k):
                continue
            # allow this one to pass through
            del self.runtime[k]
    # save straight in the persistent storage
    def set(self, name, value):
        self.stored[name] = value
        # clean up the runtime cache
        if self.runtime.has_key(name):
            del self.runtime[name]

class UuidConfig(ConfigFile):
    "derived from the ConfigFile class, with prepopulated default values"
    def __init__(self):
        ConfigFile.__init__(self)
        self.fileName = UP2DATE_UUID 


def initUp2dateConfig(file = UP2DATE_CONFIG):
    global cfg
    try:
        cfg = cfg
    except NameError:
        cfg = None
        
    if cfg == None:

        cfg = Config(file)
        cfg["isatty"] = 0 
        if sys.stdout.isatty():
            cfg["isatty"] = 1
                # pull this into the main cfg dict from the
        # seperate config file, so we dont have to munge
        # main config file in a post
        #uuidCfg = UuidConfig()
        #uc =  uuidCfg.load()
        #if uuidCfg['rhnuuid'] == None or uuidCfg['rhnuuid'] == "UNSPECIFIED":
        #    print _("No rhnuuid config option found in %s." % UP2DATE_UUID)
        #    sys.exit(1)
        #cfg['rhnuuid'] = uuidCfg['rhnuuid']


    return cfg

def main():
    source = initUp2dateConfig("foo-test.config")

    print source["serverURL"]
    source["serverURL"] =  "http://hokeypokeyland.com"
    print source["serverURL"]
    print source.set("debug", 100)
    source.save()
    print source["debug"]

if __name__ == "__main__":
    __CFG = None
    main()
