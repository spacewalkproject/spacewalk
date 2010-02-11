#!/usr/bin/python
#
# Copyright (c) 2008--2010 Red Hat, Inc.
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
# Classes and functions needed for handling certificates
# The only really exportable item is the Certificate class
#
# $Id$

import hashlib
import time
import random
import socket    
import string
from rhn.rpclib import xmlrpclib

# Global modules
from common import rhnFault, log_debug, log_error
# local imports
from server_lib import getServerSecret

# Generate a secret
def gen_secret():
    seed = repr(time.time())
    sum = hashlib.new('md5', seed)
    # feed some random numbers
    for k in range(1, random.randint(5,15)):
        sum.update(repr(random.random()))
    sum.update(socket.gethostname())
    ret = ""
    for i in sum.digest()[:]:
        ret = ret + "%02x" % ord(i)
    del sum
    return ret

# Functions for handling system_id strings
class Checksum:
    def __init__(self, secret, *args):
        self.sum = hashlib.new('md5', secret)
        if len(args) > 0:
            apply(self.feed, args)
    def feed(self, arg):        
        #sys.stderr.write("arg = %s, type = %s\n" % (arg, type(arg)))
        if type(arg) == type(()) or type(arg) == type([]):            
            for s in arg:
                self.sum.update(s)
        else:
            if type(arg) == type(0):
                arg = str(arg)
            self.sum.update(arg.encode("utf-8"))
    def __repr__(self):
        t = ""
        for i in self.sum.digest()[:]:
            t = t + "%02x" % ord(i)   
        return t
    __str__ = __repr__

# Main certificate class
class Certificate:
    CheckSumFields = [ "username", "os_release", "operating_system",
                       "architecture", "system_id", "type" ]
    
    def __init__(self):
        # init data
        # normally we include in the attrs:
        # username, os_release, os, arch, system_id and fields
        self.attrs = {}
        for k in Certificate.CheckSumFields:
            self.attrs[k] = None
        self.__fields = []
        self.__secret = None
        self.__checksum = None
        
    # functions that make it look like a dictionary for easy access:
    def __getitem__(self, key):
        return self.attrs.get(key)
    # updates the values of the attributes list with new values    
    def __setitem__(self, name, value):
        self.attrs[name] = value
        if name in Certificate.CheckSumFields:
            if name not in self.__fields:           
                self.__fields.append(name)
        else: # non essential, take None values as ""
            if value is None:
                self.attrs[name] = ""
        return 0        
    # string format
    def __repr__(self):
        return "<Certificate instance>: Attrs: %s, Fields: %s, Secret: %s, Checksum: %s" % (
            self.attrs, self.__fields, self.__secret, self.__checksum)
    __str__ = __repr__
    
    # convert to XML
    def certificate(self):
        dump = self.attrs
        dump["checksum"] = self.__checksum
        dump["fields"] = self.__fields
        try:
            x = xmlrpclib.dumps((dump,))
        except TypeError, e:
            log_error("Could not marshall certificate for %s" % dump)
            e.args = e.args + (dump,) # Carry on the information for the exception reporting
            raise
        return '<?xml version="1.0"?>\n%s' % x
    
    # Update the checksum
    def compute_checksum(self, secret):
        log_debug(4, secret, self.attrs)
        csum = Checksum(secret)
        for f in self.__fields:
            csum.feed(self.attrs[f])
        # feed the fields list last
        csum.feed(self.__fields)
        return str(csum)
        
    # set the secret of the entry and recompute the checksum
    def set_secret(self, secret):
        log_debug(4, "secret", secret)
        self.__secret = secret
        self.__checksum = self.compute_checksum(secret)
        
    # load data from a text certificate passed on by a client
    def reload(self, text):
        log_debug(4)
        text_id = string.strip(text)
        if not text_id:
            return -1
        # Now decode this certificate
        try:
            sysid, junk = xmlrpclib.loads(text_id)
        except:
            return -1
        else:
            s = sysid[0]
            del junk
        if not s.has_key("system_id") or not s.has_key("fields"):
            log_error("Got certificate with missing entries: %s" % s)
            return -1
        # check the certificate some more
        for k in s["fields"]:
            if not s.has_key(k):
                log_error("Certificate lists unknown %s as a checksum field" % k,
                          "cert data: %s" % s)
                return -1
            
        # clear out the state
        self.__init__()

        # at this point we know the certificate is sane enough for the
        # following processing
        for k in s.keys():
            if k == "fields":
                self.__fields = s[k]
                continue
            if k == "checksum":
                self.__checksum = s[k]
                continue
            self.attrs[k] = s[k]
        # okay, the certificate is now loaded
        return 0

    # compute the current checksum against a secret and check it against
    # the current checksum
    def __validate_checksum(self, secret):
        csum = self.compute_checksum(secret)
        if not csum == self.__checksum:
            # fail, current checksum does not match
            log_error("Checksum check failed: %s != %s" % (csum, self.__checksum),
                      "fields = %s" % str(self.__fields), "attrs = %s" % str(self.attrs))
            return 0
        return 1
        
    def valid(self):    
        log_debug(4)
        # check for anonymous
        if self.attrs.has_key('type') and self.attrs['type'] \
        and string.upper(self.attrs['type']) == "ANONYMOUS":
            raise rhnFault(28, """
            You need to re-register your system with Red Hat Network.
            Previously you have chosen to skip the creation of a system profile
            with Red Hat Network and this trial feature is no longer available now.
            """) # we don't support anonymous anymore
        # now we have a real server. Get its secret
        sid = self.attrs["system_id"]
        secret = getServerSecret(sid)
        if secret is None:
            # no secret, can't validate
            log_debug(1, "Server id %s not found in database" % sid)           
            return 0
        return self.__validate_checksum(secret)
