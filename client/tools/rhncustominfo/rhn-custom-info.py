#!/usr/bin/python -u
#
# Copyright (c) 2008--2013 Red Hat, Inc.
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
import xmlrpclib

from re import search
from optparse import OptionParser
from rhn import rpclib

sys.path.append("/usr/share/rhn")
from up2date_client import config
from up2date_client import up2dateAuth


def create_server_obj(server_url):

    cfg = config.initUp2dateConfig()

    enable_proxy = cfg['enableProxy']
    proxy_host = None
    proxy_user = None
    proxy_password = None

    if enable_proxy:
        proxy_host = config.getProxySetting()

        if cfg['enableProxyAuth']:
            proxy_user = cfg['proxyUser']
            proxy_password = cfg['proxyPassword']

    ca = cfg['sslCACert']

    if isinstance(ca, basestring):
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


def read_username():
    print("Username: ")
    try:
        username = sys.stdin.readline().rstrip('\n')
    except KeyboardInterrupt:
        print
        sys.exit(0)
    if username is None:
        # EOF
        print
        sys.exit(0)
    return username.strip()


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

    parser.add_option("-d", "--delete-values",
                      action="store_true", dest="delete_values", default=0,
                      help="delete one or multiple custom keys from the system")

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

    if not (num_args % 2 == 0) and not options.list_values and not options.delete_values:
        system_exit(1, "Odd number of arguments; you must provide key/value pairs")

    if not args and not options.list_values and not options.delete_values:
        system_exit(1, "You must provide key/value pairs to store")

    if '' in map(lambda e : e.strip(), args):
        system_exit(1, "Not valid value is provided for key/value pairs")

    if not args and options.delete_values:
        system_exit(1, "You must provide a key to delete")

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
    valuesdel = []

    i = 0
    if not options.delete_values:
        while (i < num_args):
            values[args[i]] = args[i+1]
            i = i + 2
    else:
        while (i < num_args):
            valuesdel.insert(i, args[i])
            i = i + 1

    url = None
    if options.url:
        url = options.url
    else:
        url = munge_server_url(config.getServerlURL()[0])

    s = create_server_obj(url)

    sid = get_sys_id()

    if not sid:
        system_exit(1, "Could not determine systemid")

    try:
        session = s.auth.login(options.username, options.password)

        if options.list_values:
            ret = s.system.get_custom_values(session, int(sid))
        elif options.delete_values:
            ret = s.system.delete_custom_values(session, int(sid), valuesdel)
        else:
            ret = s.system.set_custom_values(session, int(sid), values)

    except xmlrpclib.Fault, e:
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
