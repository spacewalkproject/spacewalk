#!/usr/bin/python
#
# tests uploads over SSL
#
# $Id$
#
# USAGE:  $0 SERVER SYSTEMID
# OUTPUT: return code = 0


import sys
import httplib
sys.path.append('..')
from rhn.rpclib import Server

SERVER = "xmlrpc.rhn.redhat.com"
HANDLER = "/XMLRPC"
system_id_file = '/etc/sysconfig/rhn/systemid'
try:
    SERVER = sys.argv[1]
    system_id_file = sys.argv[2]
except:
    pass


def get_test_server_https():
    global SERVER, HANDLER
    return Server("https://%s%s" % (SERVER, HANDLER))

if __name__ == '__main__':
    systemid = open(system_id_file).read()

    s = get_test_server_https()

    # Generate a huge list of packages to "delete"
    packages = []
    for i in range(3000):
        packages.append(["package-%d" % i, '1.1', '1', ''])

    result = s.registration.delete_packages(systemid, packages[:1000]);
    sys.exit(result);

    
