#!/usr/bin/python
"""
Script to :
- create unique channels for given users
- Push Content to the same for each user
"""

import os
import xmlrpclib

# Setup
SATELLITE_HOST = "test10-64.rhndev.redhat.com"
SATELLITE_URL = "http://%s/rpc/api" % SATELLITE_HOST

SATELLITE_LOGIN_HASH ={'prad03':'redhat', 'prad02' : 'redhat'}

SUFFIX_HASH = {'prad03' : '03', 'prad02' : '02'}

CHANNEL_INFO = {'label' : 'channel-',
                'name'  : 'channel-',
		'summary' : 'dummy channel',
		'archLabel' : 'channel-ia32',
		'parentLabel' : ''}

PKG_CONTENT_DIR = '/tmp/upload/'

client = xmlrpclib.Server(SATELLITE_URL, verbose=0)

def getKeys(users):
    """
    Generate session key for each user
    """
    keylist = {}
    for login,password in users.items():
        sessionkey = client.auth.login(login, password)
	keylist[login] = sessionkey
    return keylist

def createChannels(keylist, info):
    """
    Create unique channels per user
    """
    channel_list = {}
    for login,key in keylist.items():
        # create channel under each org
	# Channel label,name should be unique
	label = info['label'] + SUFFIX_HASH[login]
	name  = info['name']  + SUFFIX_HASH[login]
	try:
	    print "Creating Channel: ",label
            client.channel.software.create(key, label, name, \
	                            info['summary'], info['archLabel'], \
		                    info['parentLabel'])
	except xmlrpclib.Fault, e:
	    print e
        channel_list[login] = label
    return channel_list

def pushContent(users, channels):
    """
     Invoke rhnpush to push packages to channels
    """
    for login,password in users.items():
        print "Pushing Content to %s" % channels[login]
        push_cmd = 'rhnpush --server=%s/APP --username=%s --password=%s \
                    --dir=%s --channel=%s -vvvv --tolerant --nosig' % \
                   (SATELLITE_HOST, login, password, PKG_CONTENT_DIR, \
	            channels[login])
        os.system(push_cmd)

def main():
    # Create Session keys
    keys = getKeys(SATELLITE_LOGIN_HASH)
    # Create channels 
    channel_list = createChannels(keys, CHANNEL_INFO)
    # push content to channels
    pushContent(SATELLITE_LOGIN_HASH, channel_list)


if __name__ == '__main__':
    main()


