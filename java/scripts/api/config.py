#!/usr/bin/python

import xmlrpclib
import unittest
import sys
##### Configuration #####
try:
    from sat_config import *
except ImportError, e:
    print """ Create a file called sat_config.py
        anywhere in your python path with the following values
# Satellite to test against:
SATELLITE_HOST = "localhost" #no protocol prepending just fqdn
                             #Example "spacewalk.foo.com"
SATELLITE_LOGIN = "admin"
SATELLITE_PASSWORD = "redhat" """
    sys.exit(0)

SATELLITE_URL = "http://%s/rpc/api" % SATELLITE_HOST
# ID of a base channel on the satellite you're testing against:
BASE_CHANNEL_ID = 101
CHILD_CHANNEL_ID = 103

BASE_CHANNEL_LABEL = 'rhel-i386-server-5'
CHILD_CHANNEL_LABEL = 'rhn-tools-rhel-i386-server-5'

# ID of a system group on your satellite:
SERVER_GROUP_ID = 7

# ID of a system on your satellite:
SERVER_ID = 1000010000
SERVER_ID_2 = 1000012093

SERVER_NAME = "newman"

# ID of a script action that has been executed and returned output:
SCRIPT_ACTION_ID = 332

#change below to match the info on a system reg'd to your satellite
SYS_SEARCH_NAME_DESCRP = "test"
SYS_SEARCH_IP = "10.11.231.63"
SYS_SEARCH_HOSTNAME = "redhat.com"
SYS_SEARCH_HW_DESCRP = "Vmware"
SYS_SEARCH_HW_DEVICE_DRIVER = "appgart"
SYS_SEARCH_HW_DEVICE_ID = "7113"
SYS_SEARCH_HW_VENDOR_ID = "8086"

##### End Configuration #####

# One xmlrpc client to be used throughout the tests:
client = xmlrpclib.Server(SATELLITE_URL, verbose=0)


def login(name = SATELLITE_LOGIN, password = SATELLITE_PASSWORD):
    sessionkey = client.auth.login(name, password)
    return sessionkey

def logout(session_key):
    client.auth.logout(session_key)

class RhnTestCase (unittest.TestCase):
    def setUp(self):
        self.session_key = login()

    def tearDown(self):
        logout(self.session_key)

