#!/usr/bin/python -u
#
# Copyright (c) 2008 Red Hat, Inc.
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


import sys
import os
import string
import getpass

from re import search
from optparse import OptionParser
from rhn import rpclib

sys.path.append("/usr/share/rhn")
from up2date_client import config
from up2date_client import up2dateAuth

_config = None

def get_config():
    """send back a cross platform structure containing cfg info"""
    global _config
    if not _config:
        _config = config.initUp2dateConfig()
        
    return _config


def create_server_obj(server_url):

    cfg = get_config()
    
    enable_proxy = read_cfg_val(cfg, 'enableProxy')
    enable_proxy_auth = read_cfg_val(cfg, 'enableProxyAuth')
    proxy_host = None
    proxy_user = None
    proxy_password = None
    
    if enable_proxy:
        proxy_host = read_cfg_val(cfg, 'httpProxy')
                                                                                       
        if enable_proxy_auth:
            proxy_user = read_cfg_val(cfg, 'proxyUser')
            proxy_password = read_cfg_val(cfg, 'proxyPassword')
                                                                                       
    ca = read_cfg_val(cfg, 'sslCACert')
        
    if type(ca) == type(""):
        ca = [ca]
 
    ca_certs = ca or ["/usr/share/rhn/RHNS-CA-CERT"]

    lang = None
    for env in 'LANGUAGE', 'LC_ALL', 'LC_MESSAGES', 'LANG':
        if os.environ.has_key(env):
            if not os.environ[env]:
                # sometimes unset
                continue
            lang = string.split(os.environ[env], ':')[0]
            lang = string.split(lang, '.')[0]
            break


    server = rpclib.Server(server_url,
                           proxy=proxy_host,
                           username=proxy_user,
                           password=proxy_password)
                                                                                       
    if lang:
        server.setlang(lang)
                                                                                       
    for ca_cert in ca_certs:
        if not os.access(ca_cert, os.R_OK):
            raise "could not find cert %s" % ca_cert
                                                                                       
        server.add_trusted_cert(ca_cert)

    return server


def read_cfg_val(obj, key):
    """given up2date's rhel 2.1 vs 3 config 'obj', return the value"""
    if hasattr(obj, 'readEntry'):
        # rhel 2.1 style, obj.readEntry("serverURL")
        return obj.readEntry(key)
    elif hasattr(obj, "__setitem__"):
        # rhel 3 style, obj['serverURL']
        if obj.has_key(key):
            return obj[key]
        else:
            raise "unknown config option:  %s" % key
    else:
        raise "unknown up2date config object"


def read_username():
    tty = open("/dev/tty", "r+")
    tty.write("Red Hat Network username: ")
    try:
        username = tty.readline()
    except KeyboardInterrupt:
        tty.write("\n")
        sys.exit(0)
    if username is None:
        # EOF
        tty.write("\n")
        sys.exit(0)
    return string.strip(username)
    


def system_exit(code, msgs=None):
    "Exit with a code and optional message(s). Saved a few lines of code."
 
    if msgs:
        if type(msgs) not in [type([]), type(())]:
            msgs = (msgs, )
        for msg in msgs:
            sys.stderr.write(str(msg)+'\n')
    sys.exit(code)


def parse_args():
    parser = OptionParser()
    parser.set_usage("rhncustominfo [options] key1 value1 key2 value2 ...")
    parser.add_option("-u", "--username",
                      action="store", type="string", dest="username",
                      help="your RHN username", metavar="RHN_LOGIN")

    parser.add_option("-p", "--password",
                      action="store", type="string", dest="password",
                      help="your RHN password", metavar="RHN_PASSWD")

    parser.add_option("-s", "--server-url",
                      action="store", type="string", dest="url",
                      help="use the rhn api at URL", metavar="URL")

    parser.add_option("-l", "--list-values",
                      action="store_true", dest="list_values", default=0,
                      help="list the custom keys and values for the system",
                      )


    return parser.parse_args()


def verify_command_line():

    (options, args) = parse_args()
    num_args = len(args)

    if not options.username:
        options.username = read_username()

    if not options.password:
        options.password = getpass.getpass()

    if not (num_args % 2 == 0) and not options.list_values:
        system_exit(1, "Odd number of arguments; you must provide key/value pairs")

    if not args and not options.list_values:
        system_exit(1, "You must provide key/value pairs to store")

    return (options, args, num_args)


def get_sys_id():
    sysid_xml = up2dateAuth.getSystemId()

    if not sysid_xml:
        system_exit(1, "Could not get RHN systemid")
    
    m = search('ID-(?P<sysid>[0-9]+)', sysid_xml)

    if m:
        return m.group('sysid')
    else:
        return

def munge_server_url(u2d_server_url):
    m = search('(?P<prot_and_host>http[s]?://.*?/)XMLRPC', u2d_server_url)

    if m:
        return m.group('prot_and_host') + 'rpc/api'

def main():

    (options, args, num_args) = verify_command_line()

    values = {}

    i = 0
    while (i < num_args):
        values[args[i]] = args[i+1]
        i = i + 2

    url = None
    if options.url:
        url = options.url
    else:
        cfg = get_config()
        url = munge_server_url(read_cfg_val(cfg, 'serverURL'))

    s = create_server_obj(url)
    
    sid = get_sys_id()

    if not sid:
        system_exit(1, "Could not determine systemid")
    
    try:
        session = s.auth.login(options.username, options.password)

        if options.list_values:
            ret = s.system.get_custom_values(session, int(sid))
        else:
            ret = s.system.set_custom_values(session, int(sid), values)

    except rpclib.Fault, e:
        if e.faultCode == -1:
            system_exit(1, "Error code:  %s\nInvalid login information.\n" % e.faultCode)
        else:
            system_exit(1, "Error code:  %s\n%s\n" % (e.faultCode, e.faultString))


    # handle list and set modes for output...
    if options.list_values:

        if not ret:
            system_exit(0, "No custom values set for this system.\n")

        for key in ret.keys():
            print "%s\t%s" % (key, ret[key])

        system_exit(0, None)
        
    else:
        if ret:
            system_exit(0, None);
        else:
            system_exit(1, "Unknown failure!\n")
        
if __name__ == "__main__":
    main()
