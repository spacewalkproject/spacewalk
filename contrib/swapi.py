#! /usr/bin/python
#
# Like utils/spacewalk-api, call Spacewalk/RHN RPC API from command line.
#
# Copyright (C) 2010 Satoru SATOH <satoru.satoh@gmail.com>
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#
#
# [Features]
#
# * Can call every Spacewalk/RHN RPC APIs with or without arguments from
#   command line.
#
# * If API needs arguments, you can pass them in comma separated strings or
#   JSON data.
#
# * API call results are output in JSON by default to enable post-processing of
#   that data by this script itself or another program.
#
# * Result outputs are easily customizable in python string format expression
#   as needed.
#
# * Utilize config file to save authentication parameters to cut out the need
#   of typing these parameters every time.
#
# * API call results are cached by default and it will drastically reduce the
#   time to get same resutls next time.
#
# * Can call an API with multiple different arguments sets at once.
#

import ConfigParser as configparser
import cPickle as pickle
import commands
import datetime
import getpass
import logging
import optparse
import os
import random
import re
import simplejson
import sys
import time
import unittest
import xmlrpclib


try:
    import hashlib # python 2.5+
    def hexdigest(s):
        return hashlib.md5(s).hexdigest()
except ImportError:
    import md5
    def hexdigest(s):
        return md5.md5(s).hexdigest()



"""
Examples:

$ ./swapi.py --args=10821 packages.listDependencies
[
  {
    "dependency": "/usr/bin/perl",
    "dependency_modifier": " ",
    "dependency_type": "requires"
  },

    ... (snip) ...

  {
    "dependency": "cvsmapfs",
    "dependency_modifier": "= 1.3-7",
    "dependency_type": "provides"
  }
]
$ ./swapi.py --list-args="10821,10822,10823" packages.getDetails
[
  {
    "package_size": "15653",
    "package_arch_label": "noarch",
    "package_cookie": "porkchop.redhat.com 964488467",
    "package_md5sum": "44971f49f5a521464c70038bd9641a8b",
    "package_summary": "Extension for CVS to handle links\n",
    "package_name": "cvsmapfs",
    "package_epoch": "",
    "package_checksums": {
      "md5": "44971f49f5a521464c70038bd9641a8b"
    },

    ... (snip) ...

  {
    "package_size": "3110234",
    "package_arch_label": "i386",
    "package_cookie": "porkchop.redhat.com 964465421",
    "package_md5sum": "1919a8e06ee5c0916685cd04dff20776",
    "package_summary": "SNNS documents\n",
    "package_name": "SNNS-doc",
    "package_epoch": "",
    "package_checksums": {
      "md5": "1919a8e06ee5c0916685cd04dff20776"
    },
    "package_payload_size": "5475688",
    "package_version": "4.2",
    "package_license": "Free Software",
    "package_vendor": "Red Hat, Inc.",
    "package_release": "7",
    "package_last_modified_date": "2006-08-22 21:56:01.0",
    "package_description": "This package includes the documents in html and postscript for SNNS.\n",
    "package_id": 10823,
    "providing_channels": [
      "redhat-powertools-i386-7.0",
      "redhat-powertools-i386-7.1"
    ],
    "package_build_host": "porky.devel.redhat.com",
    "package_build_date": "2000-07-24 19:07:23.0",
    "package_file": "SNNS-doc-4.2-7.i386.rpm"
  }
]
$ ./swapi.py -vv --args=10821 \
> -F "%(dependency)s:%(dependency_type)s" packages.listDependencies
DEBUG:root: config_file = /home/ssato/.swapi/config
DEBUG:root: profile = 'None'
DEBUG:root: Call: api=packages.listDependencies, args=(10821,)
DEBUG:root: Loading cache: method=packages.listDependencies, args=(10821,)
DEBUG:root: Found query result cache
/usr/bin/perl:requires
cvs:requires
perl:requires
rpmlib(CompressedFileNames):requires
rpmlib(PayloadFilesHavePrefix):requires
cvsmapfs:provides
$
$ ./swapi.py -A '["rhel-i386-server-5","2010-04-01 08:00:00"]' \
> --format "%(package_name)s" channel.software.listAllPackages
kdebase
kdebase-devel
kexec-tools
krb5-devel
krb5-libs
krb5-server
krb5-workstation
lvm2
nss_db
sudo
wireshark
wireshark-gnome
$
$ ./swapi.py -A 10170***** -I 0 system.getDetails
[{"building": "", "city": "", "location_aware_download": "true", "base_entitlement": "enterprise_entitled", "description": "Initial Registration Parameters:\nOS: redhat-release\nRelease: 5Server\nCPU Arch: i686-redhat-linux", "address1": "", "address2": "", "auto_errata_update": "false", "state": "", "profile_name": "rhel-5-3-guest-1.net-1.local", "country": "", "rack": "", "room": ""}]
$ ./swapi.py -A '[10170*****,{"city": "tokyo", "rack": "ep7"}]' system.setDetails
[
  1
]
$ ./swapi.py -A 10170***** -I 0 system.getDetails
[{"building": "", "city": "", "location_aware_download": "true", "base_entitlement": "enterprise_entitled", "description": "Initial Registration Parameters:\nOS: redhat-release\nRelease: 5Server\nCPU Arch: i686-redhat-linux", "address1": "", "address2": "", "auto_errata_update": "false", "state": "", "profile_name": "rhel-5-3-guest-1.net-1.local", "country": "", "rack": "", "room": ""}]
$ ./swapi.py -A 10170***** -I 0 --no-cache system.getDetails
[{"building": "", "city": "tokyo", "location_aware_download": "true", "base_entitlement": "enterprise_entitled", "description": "Initial Registration Parameters:\nOS: redhat-release\nRelease: 5Server\nCPU Arch: i686-redhat-linux", "address1": "", "address2": "", "auto_errata_update": "false", "state": "", "profile_name": "rhel-5-3-guest-1.net-1.local", "country": "", "rack": "ep7", "room": ""}]
$

"""



PROTO = 'https'
TIMEOUT = 900

CONFIG_DIR = os.path.join(os.environ.get('HOME', '.'), '.swapi')
CONFIG = os.path.join(CONFIG_DIR, 'config')

CACHE_DIR = os.path.join(CONFIG_DIR, 'cache')
CACHE_EXPIRING_DATES = 1  # [days]



def str_to_id(s):
    return hexdigest(s)


def object_to_id(obj):
    """Object -> id.

    NOTE: Object must be able to convert to str (i.e. implements __str__).

    >>> object_to_id("test")
    '098f6bcd4621d373cade4e832627b4f6'
    >>> object_to_id({'a':"test"})
    'c5b846ec3b2f1a5b7c44c91678a61f47'
    >>> object_to_id(['a','b','c'])
    'eea457285a61f212e4bbaaf890263ab4'
    """
    return str_to_id(str(obj))


def run(cmd_str):
    return commands.getstatusoutput(cmd_str)



class Cache(object):
    """Pickle module based data caching backend.
    """

    def __init__(self, domain, expire=CACHE_EXPIRING_DATES, cache_topdir=CACHE_DIR):
        """Initialize domain-local caching parameters.

        @domain  a str represents target domain
        @expire  time period to expire cache in date (>= 0).
                 0 indicates disabling cache.
        @cache_topdir  topdir to save cache files
        """
        self.domain = domain
        self.domain_id = str_to_id(domain)
        self.cache_dir = os.path.join(cache_topdir, self.domain_id)
        self.expire_dates = self.set_expire(expire)

    def set_expire(self, dates):
        return (dates > 0 and dates or 0)

    def dir(self, obj):
        """Resolve the dir in which cache file of the object is saved.
        """
        return os.path.join(self.cache_dir, object_to_id(obj))

    def path(self, obj):
        """Resolve path to cache file of the object.
        """
        return os.path.join(self.dir(obj), 'cache.pkl')

    def load(self, obj):
        try:
            return pickle.load(open(self.path(obj), 'rb'))
        except:
            return None

    def save(self, obj, data, protocol=pickle.HIGHEST_PROTOCOL):
        """
        @obj   object of which obj_id will be used as key of the cached data
        @data  data to saved in cache
        """
        cache_dir = self.dir(obj)
        if not os.path.isdir(cache_dir):
            os.makedirs(cache_dir, mode=0700)

        cache_path = self.path(obj)

        try:
            # TODO: How to detect errors during/after pickle.dump.
            pickle.dump(data, open(cache_path, 'wb'), protocol)
            return True
        except:
            return False


    def needs_update(self, obj):
        if self.expire_dates == 0:
            return True

        try:
            mtime = os.stat(self.path(obj)).st_mtime
        except OSError:  # It indicates that the cache file cannot be updated.
            return True  # FIXME: How to handle the above case?

        cur_time = datetime.datetime.now()
        cache_mtime = datetime.datetime.fromtimestamp(mtime)

        delta = cur_time - cache_mtime  # TODO: How to do if it's negative value?

        return (delta >= datetime.timedelta(self.expire_dates))



class RpcApi(object):
    """Spacewalk / RHN XML-RPC API server object.
    """

    def __init__(self, conn_params, enable_cache=True, expire=1):
        """
        @conn_params  Connection parameters: server, userid, password, timeout, protocol.
        @enable_cache Whether to enable query result cache or not.
        @expire  Cache expiration date
        """
        self.url = "%(protocol)s://%(server)s/rpc/api" % conn_params
        self.userid = conn_params.get('userid')
        self.passwd = conn_params.get('password')
        self.timeout = conn_params.get('timeout')

        self.sid = False

        self.cache = (enable_cache and Cache("%s:%s" % (self.url, self.userid), expire) or False)

    def __del__(self):
        self.logout()

    def login(self):
        self.server = xmlrpclib.ServerProxy(self.url)
        self.sid = self.server.auth.login(self.userid, self.passwd, self.timeout)

    def logout(self):
        if self.sid:
            self.server.auth.logout(self.sid)

    def call(self, method_name, *args):
        logging.debug(" Call: api=%s, args=%s" % (method_name, str(args)))
        try:
            if self.cache:
                key = (method_name, args)

                if not self.cache.needs_update(key):
                    ret = self.cache.load(key)
                    logging.debug(" Loading cache: method=%s, args=%s" % (method_name, str(args)))

                    if ret is not None:
                        logging.debug(" Found query result cache")
                        return ret

                    logging.debug(" No query result cache found.")

            if not self.sid:
                self.login()

            method = getattr(self.server, method_name)

            # wait a little to avoid DoS attack to the server if called
            # multiple times.
            time.sleep(random.random())

            # Special cases which do not need session_id parameter:
            # api.{getVersion, systemVersion} and auth.login.
            if re.match(r'^(api.|proxy.|auth.login)', method_name):
                ret = method(*args)
            else:
                ret = method(self.sid, *args)

            if self.cache:
                self.cache.save(key, ret)

            return ret

        except xmlrpclib.Fault, m:
            raise RuntimeError("rpc: method '%s', args '%s'\nError message: %s" % (method_name, str(args), m))

    def multicall(self, method_name, argsets):
        """Quick hack to implement XML-RPC's multicall like function.

        @see xmlrpclib.MultiCall
        """
        return [self.call(method_name, arg) for arg in argsets]



def __parse(arg):
    """
    >>> __parse('1234567')
    1234567
    >>> __parse('abcXYZ012')
    'abcXYZ012'
    >>> __parse('{"channelLabel": "foo-i386-5"}')
    {'channelLabel': 'foo-i386-5'}
    """
    try:
        if re.match(r'[1-9]\d*', arg):
            return int(arg)
        elif re.match(r'{.*}', arg):
            return simplejson.loads(arg)  # retry with simplejson
        else:
            return str(arg)

    except ValueError:
        return str(arg)


def parse_api_args(args, arg_sep=','):
    """
    Simple JSON-like expression parser.

    @args     options.args :: string
    @return   rpc arg objects, [arg] :: [string]

    >>> parse_api_args('')
    []
    >>> parse_api_args('1234567')
    [1234567]
    >>> parse_api_args('abcXYZ012')
    ['abcXYZ012']
    >>> parse_api_args('{"channelLabel": "foo-i386-5"}')
    [{'channelLabel': 'foo-i386-5'}]
    >>> parse_api_args('1234567,abcXYZ012,{"channelLabel": "foo-i386-5"}')
    [1234567, 'abcXYZ012', {'channelLabel': 'foo-i386-5'}]
    >>> parse_api_args('[1234567,"abcXYZ012",{"channelLabel": "foo-i386-5"}]')
    [1234567, 'abcXYZ012', {'channelLabel': 'foo-i386-5'}]
    """
    if not args:
        return []

    try:
        x = simplejson.loads(args)
        if isinstance(x, list):
            ret = x
        else:
            ret = [x]

    except ValueError:
        ret = [__parse(a) for a in args.split(arg_sep)]

    return ret


def results_to_json_str(results, indent=2):
    """
    >>> results_to_json_str([123, 'abc', {'x':'yz'}], 0)
    '[123, "abc", {"x": "yz"}]'
    >>> results_to_json_str([123, 'abc', {'x':'yz'}])
    '[\\n  123, \\n  "abc", \\n  {\\n    "x": "yz"\\n  }\\n]'
    """
    return simplejson.dumps(results, ensure_ascii=False, indent=indent)


def configure_with_configfile(config_file, profile=""):
    """
    @config_file  Configuration file path, ex. '~/.swapi/config'.
    """
    (server,userid,password,timeout,protocol) = ('', '', '', TIMEOUT, PROTO)

    # expand '~/'
    if '~' in config_file:
        config_file = os.path.expanduser(config_file)

    logging.debug(" config_file = %s" % config_file)

    cp = configparser.SafeConfigParser()

    try:
        cp.read(config_file)

        if profile and cp.has_section(profile):
            sect = profile
        else:
            sect = 'DEFAULT'
        logging.debug(" profile = '%s'" % profile)

        server = cp.get(sect, 'server')
        userid = cp.get(sect, 'userid')
        password = cp.get(sect, 'password')
        timeout = int(cp.get(sect, 'timeout'))
        protocol = cp.get(sect, 'protocol')

    except configparser.NoOptionError:
        pass

    return {
        'server': server,
        'userid': userid,
        'password': password,
        'timeout': timeout,
        'protocol': protocol
    }


def configure_with_options(config, options):
    """
    @config   config parameters dict: {'server':, 'userid':, ...}
    @options  optparse.Options
    """
    server = config.get('server') or (options.server or raw_input('Enter server name > '))
    userid = config.get('userid') or (options.userid or raw_input('Enter user ID > '))
    password = config.get('password') or (options.password or getpass.getpass('Enter your password > '))
    timeout = config.get('timeout') or ((options.timeout and options.timeout != TIMEOUT) and options.timeout or TIMEOUT)
    protocol = config.get('protocol') or ((options.protocol and options.protocol != PROTO) and options.protocol or PROTO)

    return {'server':server, 'userid':userid, 'password':password, 'timeout':timeout, 'protocol':protocol}


def configure(options):
    conf = configure_with_configfile(options.config, options.profile)
    conf = configure_with_options(conf, options)

    return conf


def option_parser(cmd=sys.argv[0]):
    p = optparse.OptionParser("""%(cmd)s [OPTION ...] RPC_API_STRING

Examples:
  %(cmd)s --args=10821 packages.listDependencies
  %(cmd)s --list-args="10821,10822,10823" packages.getDetails
  %(cmd)s -vv --args=10821 packages.listDependencies
  %(cmd)s -P MySpacewalkProfile --args=rhel-x86_64-server-vt-5 channel.software.getDetails
  %(cmd)s -C /tmp/s.cfg -A rhel-x86_64-server-vt-5,guest channel.software.isUserSubscribable
  %(cmd)s -A "rhel-i386-server-5","2010-04-01 08:00:00" channel.software.listAllPackages
  %(cmd)s -A '["rhel-i386-server-5","2010-04-01 08:00:00"]' channel.software.listAllPackages
  %(cmd)s --format "%%(label)s" channel.listSoftwareChannels
  %(cmd)s -A 100010021 --no-cache -F "%%(hostname)s %%(description)s" system.getDetails
  %(cmd)s -A '[1017068053,{"city": "tokyo", "rack": "rack-A-1"}]' system.setDetails


Config file example (%(config)s):
--------------------------------------------------------------

[DEFAULT]
server = rhn.redhat.com
userid = xyz********
password =   # it will ask you if password is not set.
timeout = 900
protocol = https

[MySpacewalkProfile]
server = my-spacewalk.example.com
userid = rpcusr
password = secretpasswd

--------------------------------------------------------------
""" % {'cmd': cmd, 'config': CONFIG}
    )

    p.add_option('-C', '--config', help='Config file path [%default]', default=CONFIG)
    p.add_option('-P', '--profile', help='Select profile (section) in config file')
    p.add_option('-v', '--verbose', help='verbose mode', default=0, action="count")
    p.add_option('-T', '--test', help='Test mode', default=False, action="store_true")

    cog = optparse.OptionGroup(p, "Connect options")
    cog.add_option('-s', '--server', help='Spacewalk/RHN server hostname.')
    cog.add_option('-u', '--userid', help='Spacewalk/RHN login user id')
    cog.add_option('-p', '--password', help='Spacewalk/RHN Login password')
    cog.add_option('-t', '--timeout', help='Session timeout in sec [%default]', default=TIMEOUT)
    cog.add_option('',   '--protocol', help='Spacewalk/RHN server protocol.', default=PROTO)
    p.add_option_group(cog)

    caog = optparse.OptionGroup(p, "Cache options")
    caog.add_option('',   '--no-cache', help='Do not use query result cache', action="store_true", default=False)
    caog.add_option('',   '--expire', help='Expiration dates. 0 means refresh cache [%default]', default=1, type="int")
    p.add_option_group(caog)

    oog = optparse.OptionGroup(p, "Output options")
    oog.add_option('-o', '--output', help="Output file [default: stdout]")
    oog.add_option('-F', '--format', help="Output format (non-json)", default=False)
    oog.add_option('-I', '--indent', help="Indent for JSON output. 0 means no indent. [%default]", type="int", default=2)
    p.add_option_group(oog)

    aog = optparse.OptionGroup(p, "API argument options")
    aog.add_option('-A', '--args', default='',
        help='Api args other than session id in comma separated strings or JSON expression [empty]')
    aog.add_option('', '--list-args', help='Specify List of API args')
    p.add_option_group(aog)

    return p


def main(argv):
    loglevel = logging.WARN
    out = sys.stdout
    enable_cache = True

    parser = option_parser()
    (options, args) = parser.parse_args(argv[1:])

    if options.verbose > 0:
        loglevel = logging.INFO

        if options.verbose > 1:
            loglevel = logging.DEBUG

    logging.basicConfig(level=loglevel)

    if options.test:
        test()

    if len(args) == 0:
        parser.print_usage()
        return 0

    if options.no_cache:
        enable_cache = False

    if options.output:
        out = open(options.output, 'w')

    api = args[0]

    conn_params = configure(options)

    rapi = RpcApi(conn_params, enable_cache, options.expire)
    rapi.login()

    if options.list_args:
        list_args = parse_api_args(options.list_args)
        res = rapi.multicall(api, list_args)
    else:
        args = (options.args and parse_api_args(options.args) or [])
        res = rapi.call(api, *args)

    if not isinstance(res, list):
        res = [res]

    if options.format:
        print >> out, '\n'.join((options.format % r for r in res))
    else:
        print >> out, results_to_json_str(res, options.indent)

    return 0



class TestScript(unittest.TestCase):
    """TODO: More test cases.
    """

    def setUp(self):
        self.cmd = sys.argv[0]

    def __helper(self, cfmt):
        cs = cfmt % self.cmd
        (status, _output) = run(cs)

        assert status == 0, "cmdline=%s" % cs

    def test_api_wo_arg_and_sid(self):
        self.__helper("%s api.getVersion")

    def test_api_wo_arg(self):
        self.__helper("%s channel.listSoftwareChannels")

    def test_api_w_arg(self):
        self.__helper("%s --args=rhel-i386-server-5 channel.software.getDetails")

    def test_api_w_arg_and_format_option(self):
        self.__helper("%s -A rhel-i386-server-5 --format '%%(channel_description)s' channel.software.getDetails")

    def test_api_w_arg_multicall(self):
        self.__helper("%s --list-args='rhel-i386-server-5,rhel-x86_64-server-5' channel.software.getDetails")

    def test_api_w_args(self):
        self.__helper("%s -A 'rhel-i386-server-5,2010-04-01 08:00:00' channel.software.listAllPackages")

    def test_api_w_args_as_list(self):
        self.__helper("%s -A '[\"rhel-i386-server-5\",\"2010-04-01 08:00:00\"]' channel.software.listAllPackages")



def unittests():
    suite = unittest.TestLoader().loadTestsFromTestCase(TestScript)
    unittest.TextTestRunner(verbosity=2).run(suite)


def test():
    import doctest

    doctest.testmod(verbose=True)
    unittests()

    sys.exit(0)


if __name__ == '__main__':
    sys.exit(main(sys.argv))


# vim: set sw=4 ts=4 expandtab:
