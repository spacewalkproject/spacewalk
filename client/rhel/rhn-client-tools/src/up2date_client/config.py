# This file is a portion of the Red Hat Update Agent
# Copyright (c) 1999 - 2002 Red Hat, Inc.  Distributed under GPL
#
# Authors:
#       Cristian Gafton <gafton@redhat.com>
#       Adrian Likins   <alikins@redhat.com>
#
# $Id$
"""
This module includes the Config and Up2date Config classes use by the
up2date agent to hold config info.
"""

import os
import sys

import gettext
_ = gettext.gettext

# XXX: This could be moved in a more "static" location if it is too
# much of an eye sore
Defaults = {
    'enableProxy'       : ("Use a HTTP Proxy",
                           0),
    'serverURL'         : ("Remote server URL",
                           "https://xmlrpc.rhn.redhat.com/XMLRPC"),
    'debug'             : ("Whether or not debugging is enabled",
                           0),
    'systemIdPath'      : ("Location of system id",
                           "/etc/sysconfig/rhn/systemid"),
    'versionOverride'   : ("Override the automatically determined "\
                           "system version",
                           ""),
    'httpProxy'         : ("HTTP proxy in host:port format, e.g. "\
                           "squid.redhat.com:3128",
                           ""),
    'proxyUser'         : ("The username for an authenticated proxy",
                           ""),
    'proxyPassword'     : ("The password to use for an authenticated proxy",
                           ""),
    'enableProxyAuth'   : ("To use an authenticated proxy or not",
                           0),
    'networkRetries'    : ("Number of attempts to make at network "\
                           "connections before giving up",
                           1),
    'sslCACert'         : ("The CA cert used to verify the ssl server",
                           "/usr/share/rhn/RHNS-CA-CERT"),
    'noReboot'          : ("Disable the reboot action",
                           0),
    'disallowConfChanges': ("Config options that can not be overwritten by a config update action",
                            ['sslCACert','serverURL','disallowConfChanges',
                             'noReboot']),
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
#            print "warning: can't access %s" % self.fileName
            return
        
        f = open(self.fileName, "r")

        for line in f.readlines():
            # strip comments
            if '#' in line:
                line = line[:line.find('#')]
            line = line.strip()            
            if not line:
                continue

            split = line.split('=', 1)
            if len(split) != 2:
                # not in 'a = b' format. we should log this
                # or maybe error.
                continue
            key = split[0].strip()
            value = split[1].strip()

            # decode a comment line
            comment = None
            pos = key.find("[comment]")
            if pos != -1:
                key = key[:pos]
                comment = value
                value = None

            # figure out if we need to parse the value further
            if value:
                # possibly split value into a list
                values = value.split(";")
                if key in ['proxyUser', 'proxyPassword']:
                    value = str(value)
                elif len(values) == 1:
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

        # this really shouldn't happen, since it means that the
        # /etc/sysconfig/rhn directory doesn't exist, which is way broken

        # and note the attempted fix breaks useage of this by the applet
        # since it reuses this code to create its config file, and therefore
        # tries to makedirs() the users home dir again (with a specific perms)
        # and fails (see #130391)
        if not os.access(self.fileName, os.R_OK):
            if not os.access(os.path.dirname(self.fileName), os.R_OK):
                print _("%s was not found" % os.path.dirname(self.fileName))
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
                f.write("%s=%s;\n" % (key, ';'.join(map(str, val[1]))))
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
            return True
        if self.stored.has_key(name):
            return True
        return False

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


def getProxySetting():
    cfg = initUp2dateConfig()
    proxy = None
    proxyHost = cfg["httpProxy"]

    if proxyHost:
        if proxyHost[:7] == "http://":
            proxy = proxyHost[7:]
        else:
            proxy = proxyHost

    return proxy


def initUp2dateConfig(cfg_file = "/etc/sysconfig/rhn/up2date"):
    """This function is the right way to get at the up2date config."""
    global cfg
    try:
        cfg = cfg
    except NameError:
        cfg = None
        
    if cfg == None:
        cfg = Config(cfg_file)
        cfg["isatty"] = False
        if sys.stdout.isatty():
            cfg["isatty"] = True
        
    return cfg
