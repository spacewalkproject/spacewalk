#!/usr/bin/python
""" config parse/generator for sat-install, used to
    read/generate satellite-rules.conf that is then used
    by satcon-deploy.pl

    Copyright (c) 2002-2005, Red Hat, Inc.
    All rights reserved.
"""
# $Id: satConfig.py,v 1.56 2005-07-05 17:50:13 wregglej Exp $

import os
import sys
import md5
import string
from types import ListType, TupleType

from satLog import log_me
from satErrors import SatelliteConfigDeploymentError
from satLib import myPopen, DEFAULT_RHN_PARENT, DEFAULT_RHN_HANDLER, \
  DEFAULT_RHN_TRUSTED_SSL_CERT, DEFAULT_MOUNT_POINT, \
  DEFAULT_UP2DATE_CONFIG_LOCATION, DEFAULT_CONFIG_FILE

# importing satLib set up paths to allow the import of common
from common import rhnConfig
from common.rhnLib import rotateFile, getStringMD5


PREP_DIR   = "/etc/sysconfig/rhn-satellite-prep"
SCHEMA_DIR = "/etc/sysconfig/rhn-satellite-schema"


# up2date needs to be installed, might as well use
# it's config parser
DEFAULT_UP2DATE_PATH = "/usr/share/rhn/"
if DEFAULT_UP2DATE_PATH not in sys.path:
    sys.path.append(DEFAULT_UP2DATE_PATH)
from up2date_client import config


def generateSessionSecrets():
    blips = []
    for i in range(9):
        blipfd = open("/dev/urandom", "r")
        blips.append(getStringMD5(blipfd.read(4096)))
        blipfd.close()
    return blips


class SatConfig:
    def __init__(self):
        self._dict = {}
        self.fileName = "%s/satellite-rules.conf" % PREP_DIR

    def __setitem__(self, name, value):
        self._dict[name] = value

    def __getitem__(self, name):
        return self._dict[name]

    def keys(self):
        return self._dict.keys()

    def items(self):    
        return self._dict.items()

    def genSessionSecrets(self):
        secs = generateSessionSecrets()
        for index in range(1, 4+1):
            secret = secs.pop()
            self["session_swap_secret_%s" % index] = (
                "session_swap_secret", secret)
        for index in range(1, 4+1):
            secret = secs.pop()
            self["session_secret_%s" % index] = ("session_secret", secret)
        secret = secs.pop()
        self['server_secret_key'] = ('server_secret_key', secret)

    # FIXME: This should really die if we change the default rules.conf
    def brokenload(self):
        if self.fileName == None:
            return

        if not os.access(self.fileName, os.R_OK):
            print "warning: can't access %s" % self.fileName
            return

        f = open(self.fileName, "r")

        key = ""
        comment = ""
        value = ""
        for line in f.readlines():
            line = string.strip(line)
            if not line:
                continue
            if line[0] == "#":
                continue
            try:
                (key, value) = string.split(line, "=", 1)
            except ValueError:
                continue

            key = string.strip(key)
            value = string.strip(value)

            # for some reason I dont understand, chip decided to call
            # this "prompt" instead of "comment"
            pos = string.find(key, "[prompt]")
            if pos == -1:
                pos = string.find(key, "[comment]")
            if pos != -1:
                key = key[:pos]
                comment = value
                continue

            # possibly split value into a list
            values = string.split(value, ";")
            if len(values) == 1:
                try:
                    value = int(value)
                except ValueError:
                    pass
                self[key] = (comment, value)
            elif values[0] == "":
                self[key] = (comment, [])
            else:
                self[key] = (comment, values[:-1])
            comment = ""

        f.close()

    def brokensave(self):
        if self.fileName == None:
            return

        f = open(self.fileName, "w")
        os.chmod(self.fileName, 0600)

        f.write("# Red Hat Network Satellite Installer.\n")
        f.write("# Config file automagically generated. Do not edit.\n")
        f.write("# Format: 1.0\n")
        f.write("")
        for key, val in self.items():
            f.write("%s[prompt]=%s\n" % (key, val[0]))
            if type(val[1]) == type([]):
                f.write("%s=%s;\n" % (key, string.join(map(str, val[1]), ';')))
            else:
                f.write("%s=%s\n" % (key, val[1]))
            f.write("\n")

        f.close()


class SatSchemaConfig(SatConfig):
    def __init__(self):
        global SCHEMA_DIR
        SatConfig.__init__(self)
        self.fileName = "%s/satellite-schema-rules.conf" % SCHEMA_DIR


class ClientConfig:
    if hasattr(config.Config, 'writeEntry'):
        has_rhn_register = 1
    else:
        # New-style up2date
        has_rhn_register = 0


class DuplexClientConfig:
    if hasattr(config.Config, 'writeEntry'):
        has_rhn_register = 1
    else:
        # New-style up2date
        has_rhn_register = 0

    def __init__(self):
        if self.has_rhn_register:
            self.up2date_config = config.Config()
            self.up2date_config.fileName = '/etc/sysconfig/rhn/up2date'
            self.rhn_register_config = config.Config()
            self.rhn_register_config.fileName = '/etc/sysconfig/rhn/up2date'
        else:
            self.up2date_config = config.Config('/etc/sysconfig/rhn/up2date')

    def __setitem__(self, name, value):
        if self.has_rhn_register:
            self.rhn_register_config.writeEntry(name, value)
            if name != 'networkSetup':
                self.up2date_config.writeEntry(name, value)
        else:
            self.up2date_config[name] = value

    def save(self):
        self.up2date_config.save()
        if self.has_rhn_register:
            self.rhn_register_config.save()


class ConfigSingleton:
    __config_instance = None
    def get_instance(self):
        if self.__config_instance is None:
            ConfigSingleton.__config_instance = DuplexClientConfig()
        return self.__config_instance

def get_client_config():
    return ConfigSingleton().get_instance()
    

def writeSatDeployEntries(datahash):
    """ pass in a hash of key, value """

    satCfg = SatConfig()
    satCfg.brokenload()
    satCfg.genSessionSecrets()
    for key in datahash.keys():
        satCfg[key] = (key, datahash[key])
    satCfg.brokensave()


def __stringify_traceback_mail(traceback_mail):
    """ traceback_mail may return as a list/tuple... stringify it! """

    tm = traceback_mail
    if type(tm) in [ListType, TupleType]:
        tm = string.join(traceback_mail, ', ')
    return tm or ''


def getSatConfig():
    """ fetch all important config data from the /etc/rhn/rhn.conf file """

    cfg = rhnConfig.RHNOptions()
    cfg._init('server.satellite')
    cfg.parse()

    datahash = {
        'traceback_mail': '',
        'mount_point': '',
        'kickstart_mount_point': '',
        'default_db': '',
        'rhn_parent': '',
        'http_proxy': '',
        'http_proxy_username': '',
        'http_proxy_password': '',
        'ca_chain': '',
    }

    # populate the hash
    for k in datahash.keys():
        datahash[k] = getattr(cfg, k, '') or ''
    datahash['traceback_mail'] = __stringify_traceback_mail(datahash['traceback_mail'])

    return datahash


def writeSatConfig(options):
    """ write sat configs via the satConfig.deployConfigs() route """

    if os.path.exists(DEFAULT_CONFIG_FILE):
        print "* backing up %s" % DEFAULT_CONFIG_FILE
        rotateFile(DEFAULT_CONFIG_FILE, depth=5)
    cfg = rhnConfig.RHNOptions()
    cfg._init('server.satellite')
    cfg.parse()

    # satcon-deploy-tree.pl mappings
    # each of these has an entry in a rule-set
    # file (/etc/sysconfig/rhn-satellite-prep/etc/rhn/rhn.conf). The mapping
    # keys are abitrary, but cannot have a '.' hence the DOT :)
    datahash = {
        'traceback_mail':                   options.email or cfg.TRACEBACK_MAIL,
        'mount_point':                      options.mount_point or cfg.MOUNT_POINT or DEFAULT_MOUNT_POINT,
        'kickstart_mount_point':            options.mount_point or cfg.MOUNT_POINT or DEFAULT_MOUNT_POINT,
        'default_db':                       options.db or cfg.DEFAULT_DB,
        'serverDOTsatelliteDOTrhn_parent':  options.server or cfg.RHN_PARENT or DEFAULT_RHN_PARENT,
        'serverDOTsatelliteDOThttp_proxy':  options.http_proxy or cfg.HTTP_PROXY,
        'serverDOTsatelliteDOThttp_proxy_username': options.http_proxy_username or cfg.HTTP_PROXY_USERNAME,
        'serverDOTsatelliteDOThttp_proxy_password': options.http_proxy_password or cfg.HTTP_PROXY_PASSWORD,
        'serverDOTsatelliteDOTca_chain':    options.ca_cert or cfg.CA_CHAIN or DEFAULT_RHN_TRUSTED_SSL_CERT,
        'encrypted_passwords':              '1',
        'webDOTssl_available':              '0',
    }
    
    # clean out the Nones/''s so that the defaults are used:
    # NOTE: didn't use map/filter/lambda cuz I am lazy
    for k in datahash.keys():
        if not datahash[k]:
            del datahash[k]

    # will throw a SatelliteConfigDeploymentError upon error
    print "* writing /etc/rhn/rhn.conf"
    writeSatConfigDeploy(datahash)


def populateUp2dateServerConfigs(options):
    # IOErrors are possible
    cfg = getSatConfig()
    server = options.server or cfg['rhn_parent'] or DEFAULT_RHN_PARENT
    server = server + DEFAULT_RHN_HANDLER
    ca_chain = options.ca_cert or cfg['ca_chain'] or DEFAULT_RHN_TRUSTED_SSL_CERT
    
    client_config = get_client_config()
    if ca_chain:
        client_config["sslCACert"] = ca_chain
    if server:
        client_config["noSSLServerURL"] = 'http://'+server
        client_config["serverURL"] = 'https://'+server

    client_config["networkSetup"] = 1
    client_config.save()


def disableHttpProxy():
    "used to turn off use of an http proxy for both rhn_register and up2date"
    
    client_config = get_client_config()
    client_config["enableProxy"] = 0
    client_config["enableProxyAuth"] = 0
    client_config["networkSetup"] = 1


def populateUp2dateHttpProxyConfigs(options):
    # IOErrors are possible
    disableHttpProxy()
    client_config = get_client_config()
    if options.http_proxy:
        # yeah yeah, these two should be combined. I know...
        client_config["enableProxy"] = 1
        client_config["httpProxy"] =  options.http_proxy

        if options.http_proxy_username:
            client_config["enableProxyAuth"] = 1
            client_config["proxyUser"] = options.http_proxy_username

        if options.http_proxy_password:
            client_config["proxyPassword"] = options.http_proxy_password

    client_config["networkSetup"] = 1

    client_config.save()


def populateUp2dateConfigs(options):
    # rhn_register backed up in satInstall.registerSystem()

    if os.path.exists(DEFAULT_UP2DATE_CONFIG_LOCATION):
        print "* backing up %s" % DEFAULT_UP2DATE_CONFIG_LOCATION
        rotateFile(DEFAULT_UP2DATE_CONFIG_LOCATION, depth=5)
    populateUp2dateHttpProxyConfigs(options)
    populateUp2dateServerConfigs(options)
    

def writeSatConfigDeploy(datahash):
    """ write out the proper rules.conf, run the script to deploy it, raise
        useful exceptions for the failure cases
    """

    writeSatDeployEntries(datahash)

    # run the perl script that runs the configs
    cmdLine = ["/usr/bin/satcon-deploy-tree.pl", 
        "--conf", "%s/satellite-rules.conf" % PREP_DIR,
        "--source", "%s/etc/" % PREP_DIR, 
        "--dest", "/etc/"]

    ret, out_stream, err_stream = myPopen(cmdLine)

    log_me("config file deployment:\n %s" % out_stream.read())
    log_me("config tool deployment exited with status: %s" % ret)

    if ret:
        raise SatelliteConfigDeploymentError(
            "Satellite configuration deployment failure, exited: %s\n%s" % (ret, err_stream.read()))


def redeploy():
    """ deploy current settings using new context
        example: a migration of one RHN Satellite to a new version of RHN Satellite
    """
    from optparse import Option, OptionParser
        
    from satLog import initLog
    initLog()

    def g(key, default='', component="server.satellite"):
        from common.rhnConfig import CFG, initCFG
        initCFG(component)
        # instead of returning None, we return ''
        return CFG.get(key, default)

    pam_filename_str = g('PAM_AUTH_CONFIG',None,'web')
    if not pam_filename_str:
        pam_filename_str = 'not set'

    options = [
        Option('--traceback-mail', action='store', default=g('TRACEBACK_MAIL'), help='traceback_mail setting: default is %s' % g('TRACEBACK_MAIL')),
        Option('--mount-point', action='store', default=g('MOUNT_POINT',''), help='mount_point setting: default is %s' % g('MOUNT_POINT')),
        Option('--kickstart-mount-point', action='store', default=g('KICKSTART_MOUNT_POINT', g('MOUNT_POINT')), help='kickstart_mount_point setting: default is %s' % g('KICKSTART_MOUNT_POINT', g('MOUNT_POINT'))),
        Option('--default-db', action='store', default=g('DEFAULT_DB'), help='default_db setting: default is %s' % g('DEFAULT_DB')),
        Option('--rhn-parent', action='store', default=g('RHN_PARENT'), help='rhn_parent setting: default is %s' % g('RHN_PARENT')),
        Option('--http-proxy', action='store', default=g('HTTP_PROXY'), help='http_proxy setting: default is %s' % g('HTTP_PROXY')),
        Option('--http-proxy-username', action='store', default=g('HTTP_PROXY_USERNAME'), help='http_proxy setting: default is %s' % g('HTTP_PROXY_USERNAME')),
        Option('--http-proxy-password', action='store', default=g('HTTP_PROXY_PASSWORD'), help='http_proxy setting: default is %s' % g('HTTP_PROXY_PASSWORD')),
        Option('--ca-chain', action='store', default=g('CA_CHAIN'), help='ca_chain setting: default is %s' % g('CA_CHAIN')),
        Option('--encrypted-passwords', action='store', type='string', default=g('ENCRYPTED_PASSWORDS','1'), help='encrypted passwords setting (1 or 0). Default is "%s"' % g('ENCRYPTED_PASSWORDS','1')),
        Option('--ssl-available', action='store', type='string', default=g('SSL_AVAILABLE','0','web'), help='(use SSL for web UI) set ssl_available (1 or 0). Default is "%s"' % g('SSL_AVAILABLE','0','web')),
        Option('--pam-filename', action='store', default=g('PAM_AUTH_CONFIG',None,'web'), help='filename for PAM settings web.pam_auth_service = <FILENAME> (default is "%s").' % pam_filename_str),
        Option('--commit', action='store_true', help='not a dry run. I.e., commit!'),
        Option('-v','--verbose', action='count', help='be verbose (accumulable: -vvv means "be *really* verbose").'),
              ]

    values, args = OptionParser(option_list=options).parse_args()

    # we take no extra commandline arguments that are not linked to an option
    if args:
        msg = "ERROR: these arguments make no sense in this context (try --help): %s\n" % repr(args)
        raise ValueError(msg)

    # satcon-deploy-tree.pl mappings
    # each of these has an entry in a rule-set
    # file (/etc/sysconfig/rhn-satellite-prep/etc/rhn/rhn.conf). The mapping
    # keys are abitrary, but cannot have a '.' hence the DOT :)
    datahash = {
        'traceback_mail':                   values.traceback_mail or '',
        'mount_point':                      values.mount_point or '',
        'kickstart_mount_point':            values.kickstart_mount_point or '',
        'default_db':                       values.default_db or '',
        'serverDOTsatelliteDOTrhn_parent':  values.rhn_parent or '',
        'serverDOTsatelliteDOThttp_proxy':  values.http_proxy or '',
        'serverDOTsatelliteDOThttp_proxy_username': values.http_proxy_username or '',
        'serverDOTsatelliteDOThttp_proxy_password': values.http_proxy_password or '',
        'serverDOTsatelliteDOTca_chain':    values.ca_chain or '',
        'encrypted_passwords':              values.encrypted_passwords or '1',
        'webDOTssl_available':              values.ssl_available or '0',
    }
    if values.pam_filename:
        datahash['webDOTpam_auth_service'] = values.pam_filename

    print 'datahash for mappings:'
    for k, v in datahash.items():
        print ' '*3, k, '=', v
    if values.commit:
        print "Writing and deploying configuration files..."
        writeSatConfigDeploy(datahash)
        print "...deployed. Please restart the httpd and taskomatic services"
    else:
        print
        print ('Changes are not commited by default. '
               'Add --commit to commit your changes.')


def _test():
    print 'XXXXXXXXXXXXXXX: test code only!'

    from satLog import initLog
    from satLib import systemExit
    try:
        initLog()
    except (OSError, IOError), e:
        msg = "initLog(): Unable to open log file. The error was: %s" % e
        systemExit(1, msg)

    #foo = generateSessionSecrets()
    #print foo
    foo = SatConfig()
    foo.brokenload()
    foo.genSessionSecrets()
    print foo
    for i in foo.keys():
	print "%s=%s" % (i, foo[i])
    print
    foo.brokensave()
    datahash = {
        'traceback_mail':                   'taw-test@redhat.com',
        'mount_point':                      '/pub/',
        'kickstart_mount_point':            '/pub/',
        'default_db':                       'testdb/testpass@sid',
        'serverDOTsatelliteDOTrhn_parent':  'xmlrpc.rhn.redhat.com',
        'serverDOTsatelliteDOThttp_proxy':  '',
        'serverDOTsatelliteDOThttp_proxy_username': '',
        'serverDOTsatelliteDOThttp_proxy_password': '',
        'serverDOTsatelliteDOTca_chain':    '/usr/share/rhn/RHNS-CA-CERT',
        'encrypted_passwords':              '1',
        'webDOTssl_available':              '1',
    }
    writeSatConfigDeploy(datahash)


if __name__ == "__main__":
    _test()
        

