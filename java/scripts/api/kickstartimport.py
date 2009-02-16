#!/usr/bin/python

import xmlrpclib
import sys

SATELLITE_URL = "http://rlx-3-12.rhndev.redhat.com/rpc/api"
SATELLITE_LOGIN = "admin"
SATELLITE_PASSWORD = "spacewalk"

client = xmlrpclib.Server(SATELLITE_URL, verbose=0)
session_key = client.auth.login(SATELLITE_LOGIN, SATELLITE_PASSWORD)

if len(sys.argv) != 5:
    print "Usage: %s [label] [virt type] [tree label] [kickstart_file]" \
        % sys.argv[0]
    sys.exit(1)

ks_label = sys.argv[1]
virt_type = sys.argv[2]
ks_tree_label = sys.argv[3]
ks_file = sys.argv[4]

f = open(ks_file)
file_contents = f.read()

print "Importing kickstart file: "
print "   label: %s" % ks_label
print "   virtualization type: %s" % virt_type
print "   kickstart tree label: %s" % ks_tree_label
print "   kickstart file: %s" % ks_file

client.kickstart.importKickstartFile(session_key, ks_label, virt_type, 
    ks_tree_label, True, file_contents)


