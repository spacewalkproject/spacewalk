#!/usr/bin/python
"""
 " Script to help switching our dev environments between
 " hosted and the various sats that are laying around.
"""

import os
import re
import sys

# Define a list of our envs
### If you are updating this code, you *must* add the environment here
### as well as define a dictionary object for it as is done below.

environments = ['shughes1', 'webdev', 'rhnsat', 'satellite3', 'sputnik', 'rlx310', 'rlx36', 'webqa', 'rlx38', 'rlx218', 'shaggy', 'fjs11', 'fjs12', 'fjs08','rlx324', 'rlx312', 'rlx22','rlx206', 'rlx210','rlx214','joust', 'rlx06']
def usage():
    print "usage: %s [-r] [-l] <env>" % os.path.basename(sys.argv[0])
    print "where <env> is one of the following:"
    for environment in environments:
        print "   - %s" % environment
    sys.exit()

def invalidEnv():
    print "I don't know about %s" % newEnv
    print "Available Environments: "
    for environment in environments:
        print "   - %s" % environment
    sys.exit()

# Make sure we were called correctly
nargs = len(sys.argv)
if not nargs >= 2:
    usage()

# default values for restart and newEnv
restart = None
# newEnv is going to be the environment we're switching to
newEnv = sys.argv[1]
if nargs > 2: #check for -r
    if sys.argv[1] == '-r':
        restart = True
        newEnv = sys.argv[2]
    else:
        usage()


# Make sure newEnv is valid
if (environments.count(newEnv) == 0):
    invalidEnv()

# We were called correctly... time to get busy
print "Switching workstation to %s environment." % newEnv

urlprefix = 'jdbc:log:oracle.jdbc.driver.OracleDriver:oracle:thin:@'

# Define all dictionary objects for each environment here
shughes1 = {'username' : ['hibernate.connection.username', 'shughes1'],
            'password' : ['hibernate.connection.password', 'shughes1'],
            'url' : ['hibernate.connection.url', urlprefix + 'test-db-1.rhndev.redhat.com:1521:shughes1'],
            'satellite' : ['web.satellite', '1'],
            'encrypt' : ['web.encrypted_passwords', '1'],
            'dbstring' : ['web.default_db', 'shughes1/shughes1@shughes1']}

webdev = {'username' : ['hibernate.connection.username', 'rhnuser'],
          'password' : ['hibernate.connection.password', 'rhnuser'],
          'url' : ['hibernate.connection.url', urlprefix + 'db1.back-webdev.redhat.com:1521:webdev'],
          'satellite' : ['web.satellite', '0'],
          'encrypt' : ['web.encrypted_passwords', '0'],
          'dbstring' : ['web.default_db', 'rhnuser/rhnuser@webdev'],
          'oaisync' : ['web.enable_oai_sync', '1']}

rhnsat = {'username' : ['hibernate.connection.username', 'rhnsat'],
          'password' : ['hibernate.connection.password', 'rhnsat'],
          'url' : ['hibernate.connection.url', urlprefix + 'rlx-2-12.rhndev.redhat.com:1521:rhnsat'],
          'satellite' : ['web.satellite', '1'],
          'encrypt' : ['web.encrypted_passwords', '1'],
          'dbstring' : ['web.default_db', 'rhnsat/rhnsat@rhnsat']}

satellite3 = {'username' : ['hibernate.connection.username', 'rhnsat'],
          'password' : ['hibernate.connection.password', 'rhnsat'],
          'url' : ['hibernate.connection.url', urlprefix + 'satellite3.pdx.redhat.com:1521:rhnsat'],
          'satellite' : ['web.satellite', '1'],
          'encrypt' : ['web.encrypted_passwords', '1'],
          'dbstring' : ['web.default_db', 'rhnsat/rhnsat@rhnsat']}

rlx310 = {'username' : ['hibernate.connection.username', 'rhnsat'],
          'password' : ['hibernate.connection.password', 'rhnsat'],
          'url' : ['hibernate.connection.url', urlprefix + 'rlx-3-10.rhndev.redhat.com:1521:rhnsat'],
          'satellite' : ['web.satellite', '1'],
          'encrypt' : ['web.encrypted_passwords', '1'],
          'dbstring' : ['web.default_db', 'rhnsat/rhnsat@rhnsat'],
          'oaisync' : ['web.enable_oai_sync', '0']}

rlx06 = {'username' : ['hibernate.connection.username', 'rhnsat'],
          'password' : ['hibernate.connection.password', 'rhnsat'],
          'url' : ['hibernate.connection.url', urlprefix + 'rlx-0-06.rhndev.redhat.com:1521:rhnsat'],
          'satellite' : ['web.satellite', '1'],
          'encrypt' : ['web.encrypted_passwords', '1'],
          'dbstring' : ['web.default_db', 'rhnsat/rhnsat@rlx06'],
          'oaisync' : ['web.enable_oai_sync', '0']}


rlx312 = {'username' : ['hibernate.connection.username', 'rhnsat'],
          'password' : ['hibernate.connection.password', 'rhnsat'],
          'url' : ['hibernate.connection.url', urlprefix + 'rlx-3-12.rhndev.redhat.com:1521:rhnsat'],
          'satellite' : ['web.satellite', '1'],
          'encrypt' : ['web.encrypted_passwords', '1'],
          'dbstring' : ['web.default_db', 'rhnsat/rhnsat@rlx312'],
          'oaisync' : ['web.enable_oai_sync', '0']}
shaggy = {'username' : ['hibernate.connection.username', 'rhnsat'],
          'password' : ['hibernate.connection.password', 'rhnsat'],
          'url' : ['hibernate.connection.url', urlprefix + 'shaggy.rdu.redhat.com:1521:rhnsat'],
          'satellite' : ['web.satellite', '1'],
          'encrypt' : ['web.encrypted_passwords', '1'],
          'dbstring' : ['web.default_db', 'rhnsat/rhnsat@shaggy'],
          'oaisync' : ['web.enable_oai_sync', '0']}

rlx36 = {'username' : ['hibernate.connection.username', 'rhnsat'],
          'password' : ['hibernate.connection.password', 'rhnsat'],
          'url' : ['hibernate.connection.url', urlprefix + 'rlx-3-06.rhndev.redhat.com:1521:rhnsat'],
          'satellite' : ['web.satellite', '1'],
          'encrypt' : ['web.encrypted_passwords', '1'],
          'dbstring' : ['web.default_db', 'rhnsat/rhnsat@rlx36'],
          'oaisync' : ['web.enable_oai_sync', '0']}

rlx38 = {'username' : ['hibernate.connection.username', 'rhnsat'],
          'password' : ['hibernate.connection.password', 'rhnsat'],
          'url' : ['hibernate.connection.url', urlprefix + 'rlx-3-08.rhndev.redhat.com:1521:rhnsat'],
          'satellite' : ['web.satellite', '1'],
          'encrypt' : ['web.encrypted_passwords', '1'],
          'dbstring' : ['web.default_db', 'rhnsat/rhnsat@rhnsat'],
          'oaisync' : ['web.enable_oai_sync', '0']}

webqa = {'username' : ['hibernate.connection.username', 'rhnuser'],
          'password' : ['hibernate.connection.password', 'rhnuser'],
          'url' : ['hibernate.connection.url', urlprefix + 'db1.back-webqa.redhat.com:1521:webqa'],
          'satellite' : ['web.satellite', '0'],
          'encrypt' : ['web.encrypted_passwords', '0'],
          'dbstring' : ['web.default_db', 'rhnuser/rhnuser@webqa'],
          'oaisync' : ['web.enable_oai_sync', '1']}
rlx22 = {'username' : ['hibernate.connection.username', 'rhnsat'],
          'password' : ['hibernate.connection.password', 'rhnsat'],
          'url' : ['hibernate.connection.url', urlprefix + 'rlx-0-22.rhndev.redhat.com:1521:rhnsat'],
          'satellite' : ['web.satellite', '1'],
          'encrypt' : ['web.encrypted_passwords', '1'],
          'dbstring' : ['web.default_db', 'rhnsat/rhnsat@rlx22'],
          'oaisync' : ['web.enable_oai_sync', '0']}

rlx206 = {'username' : ['hibernate.connection.username', 'rhnsat'],
          'password' : ['hibernate.connection.password', 'rhnsat'],
          'url' : ['hibernate.connection.url', urlprefix + 'rlx-2-06.rhndev.redhat.com:1521:rhnsat'],
          'satellite' : ['web.satellite', '1'],
          'encrypt' : ['web.encrypted_passwords', '1'],
          'dbstring' : ['web.default_db', 'rhnsat/rhnsat@rlx206'],
          'oaisync' : ['web.enable_oai_sync', '0']}

rlx210 = {'username' : ['hibernate.connection.username', 'rhnsat'],
          'password' : ['hibernate.connection.password', 'rhnsat'],
          'url' : ['hibernate.connection.url', urlprefix + 'rlx-2-10.rhndev.redhat.com:1521:rhnsat'],
          'satellite' : ['web.satellite', '1'],
          'encrypt' : ['web.encrypted_passwords', '1'],
          'dbstring' : ['web.default_db', 'rhnsat/rhnsat@rlx210'],
          'oaisync' : ['web.enable_oai_sync', '0']}
rlx214 = {'username' : ['hibernate.connection.username', 'rhnsat'],
          'password' : ['hibernate.connection.password', 'rhnsat'],
          'url' : ['hibernate.connection.url', urlprefix + 'rlx-2-14.rhndev.redhat.com:1521:rhnsat'],
          'satellite' : ['web.satellite', '1'],
          'encrypt' : ['web.encrypted_passwords', '1'],
          'dbstring' : ['web.default_db', 'rhnsat/rhnsat@rlx214'],
          'oaisync' : ['web.enable_oai_sync', '0']}


rlx218 = {'username' : ['hibernate.connection.username', 'rhnsat'],
          'password' : ['hibernate.connection.password', 'rhnsat'],
          'url' : ['hibernate.connection.url', urlprefix + 'rlx-2-18.rhndev.redhat.com:1521:rhnsat'],
          'satellite' : ['web.satellite', '1'],
          'encrypt' : ['web.encrypted_passwords', '1'],
          'dbstring' : ['web.default_db', 'rhnsat/rhnsat@rhnsat'],
          'oaisync' : ['web.enable_oai_sync', '0']}

fjs11 = {'username' : ['hibernate.connection.username', 'rhnsat'],
          'password' : ['hibernate.connection.password', 'rhnsat'],
          'url' : ['hibernate.connection.url', urlprefix + 'fjs-0-11.rhndev.redhat.com:1521:rhnsat'],
          'satellite' : ['web.satellite', '1'],
          'encrypt' : ['web.encrypted_passwords', '1'],
          'dbstring' : ['web.default_db', 'rhnsat/rhnsat@rhnsat'],
          'oaisync' : ['web.enable_oai_sync', '0']}

fjs08 = {'username' : ['hibernate.connection.username', 'rhnsat'],
          'password' : ['hibernate.connection.password', 'rhnsat'],
          'url' : ['hibernate.connection.url', urlprefix + 'fjs-0-08.rhndev.redhat.com:1521:rhnsat'],
          'satellite' : ['web.satellite', '1'],
          'encrypt' : ['web.encrypted_passwords', '1'],
          'dbstring' : ['web.default_db', 'rhnsat/rhnsat@fjs08'],
          'oaisync' : ['web.enable_oai_sync', '0']}

joust = {'username' : ['hibernate.connection.username', 'rhnsat'],
          'password' : ['hibernate.connection.password', 'rhnsat'],
          'url' : ['hibernate.connection.url', urlprefix + 'joust.rhndev.redhat.com:1521:rhnsat'],
          'satellite' : ['web.satellite', '1'],
          'encrypt' : ['web.encrypted_passwords', '1'],
          'dbstring' : ['web.default_db', 'rhnsat/rhnsat@joust'],
          'oaisync' : ['web.enable_oai_sync', '0']}


rlx324 = {'username' : ['hibernate.connection.username', 'rhnsat'],
          'password' : ['hibernate.connection.password', 'rhnsat'],
          'url' : ['hibernate.connection.url', urlprefix + 'rlx-3-24.rhndev.redhat.com:1521:rhnsat'],
          'satellite' : ['web.satellite', '1'],
          'encrypt' : ['web.encrypted_passwords', '1'],
          'dbstring' : ['web.default_db', 'rhnsat/rhnsat@rhnsat'],
          'oaisync' : ['web.enable_oai_sync', '0']}

fjs12 = {'username' : ['hibernate.connection.username', 'rhnsat'],
          'password' : ['hibernate.connection.password', 'rhnsat'],
          'url' : ['hibernate.connection.url', urlprefix + 'fjs-0-12.rhndev.redhat.com:1521:rhnsat'],
          'satellite' : ['web.satellite', '1'],
          'encrypt' : ['web.encrypted_passwords', '1'],
          'dbstring' : ['web.default_db', 'rhnsat/rhnsat@fjs011'],
          'oaisync' : ['web.enable_oai_sync', '0']}

joust = {'username' : ['hibernate.connection.username', 'rhnsat'],
          'password' : ['hibernate.connection.password', 'rhnsat'],
          'url' : ['hibernate.connection.url', urlprefix + 'joust.rhndev.redhat.com:1521:rhnsat'],
          'satellite' : ['web.satellite', '1'],
          'encrypt' : ['web.encrypted_passwords', '1'],
          'dbstring' : ['web.default_db', 'rhnsat/rhnsat@joust'],
          'oaisync' : ['web.enable_oai_sync', '0']}

shaggy = {'username' : ['hibernate.connection.username', 'rhnsat'],
          'password' : ['hibernate.connection.password', 'rhnsat'],
          'url' : ['hibernate.connection.url', urlprefix + 'shaggy.rdu.redhat.com:1521:rhnsat'],
          'satellite' : ['web.satellite', '1'],
          'encrypt' : ['web.encrypted_passwords', '1'],
          'dbstring' : ['web.default_db', 'rhnsat/rhnsat@shaggy'],
          'oaisync' : ['web.enable_oai_sync', '0']}


# Move rhn.conf to rhn.conf.save so we don't totally hose somebody in the
# off chance ;) that this script doesn't work correctly.
print "Backing up rhn.conf..."
os.system('mv /etc/rhn/rhn.conf /etc/rhn/rhn.conf.save')
print "/etc/rhn/rhn.conf saved as /etc/rhn/rhn.conf.save"

# Edit rhn.conf
file = open('/etc/rhn/rhn.conf.save', 'r')
out = open('/etc/rhn/rhn.conf', 'w')

# Keep a list of keys we have edited
edited = []

# Get a list of the keys
keys = eval(newEnv + '.keys()')

# Search through and edit any existing lines
for line in file.xreadlines():
    newline = line #set the default
    # Go through our keys and see if they match
    for key in keys:
        keystring = eval(newEnv + '[\'' + key + '\']')[0]
        keyvalue = keystring + '=' + eval(newEnv + '[\'' + key + '\']')[1] + '\n'
        #keystring should end up being something like 'hibernate.connection.username'
        #keyvalue should end up being something like 'hibernate.connection.username=rhnuser'
        if re.match(keystring, line):
            newline = keyvalue
            edited.append(key)

    out.write(newline) #write it out to rhn.conf

# Make sure that we didn't miss any... this happened to me since some values in default/rhn_web.conf
# weren't overridden in rhn.conf yet
if (len(keys) > len(edited)): #argh... gotta find the missing ones
    # Go through our keys and see if they are in the edited list we've been keeping
    # track of. If not, append it to the end here
    for key in keys:
        if (edited.count(key) == 0):
            keystring = eval(newEnv + '[\'' + key + '\']')[0]
            keyvalue = keystring + '=' + eval(newEnv + '[\'' + key + '\']')[1] + '\n'
            out.write(keyvalue) #append to the end of the file

print "Switch to %s environment complete." % newEnv

# Restart our servers so we start with clean slate
if restart:
    print "*** httpd restarting ***"
    #for some reason restart is flakey... start/stop separately
    os.system('/sbin/service httpd stop')
    os.system('/sbin/service httpd start')

    print "*** tomcat5 restarting ***"
    os.system('/sbin/service tomcat5 restart')
