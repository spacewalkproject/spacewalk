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
#
# generate bootstrap scripts for the various up2date clients
# (namely 2.x, 3.x and 4.x)
#
# Author: Todd Warner <taw@redhat.com>
#
# $Id$

## language imports
import os
import sys
import glob
import string
import socket
import shutil
import urlparse
import operator

from optparse import Option, OptionParser

## local imports
from rhn.common import rhn_rpm
from client_config_update import readConfigFile
from rhn_bootstrap_strings import \
    getHeader, getConfigFilesSh, getUp2dateScriptsSh, getGPGKeyImportSh, \
    getCorpCACertSh, getRegistrationSh, getUp2dateTheBoxSh, \
    getAllowConfigManagement, getAllowRemoteCommands
from sslToolConfig import CA_CRT_NAME, CA_CRT_RPM_NAME
from spacewalk.common.fileutils import make_temp_file, rotateFile, cleanupAbsPath, \
from spacewalk.common.checksum  import getFileChecksum

## GLOBALS
PRODUCT_NAME = 'RHN Server'
if os.path.exists('/usr/share/rhn/proxy') \
  or os.path.exists('/var/www/rhns/proxy'):
    PRODUCT_NAME = 'RHN Proxy Server'
elif os.path.exists('/usr/share/rhn/server') \
  or os.path.exists('/var/www/rhns/server'):
    PRODUCT_NAME = 'RHN Satellite Server'

DEFAULT_CA_CERT_PATH = '/usr/share/rhn/'+CA_CRT_NAME

DEFAULT_APACHE_PUB_DIRECTORY = '/var/www/html/pub'
DEFAULT_OVERRIDES = 'client-config-overrides.txt'
DEFAULT_SCRIPT = 'bootstrap.sh'


# exit codes
errnoSuccess = 0
errnoGeneral = 1
errnoScriptNameClash = 10
errnoBadScriptName = 11
errnoExtraCommandLineArgs = 12
errnoBadHttpProxyString = 13
errnoBadPath = 14
errnoNotFQDN = 15
errnoCANotFound = 16
errnoGPGNotFound = 17


# should come out of common code when we move this code out of
# rhns-certs-tools
def parseUrl(url):
    """ urlparse is more complicated than what we need.

        We make the assumption that the URL has real URL information.
        NOTE: http/https ONLY for right now.

        The normal behavior of urlparse:
            - if no {http[s],file}:// then the string is considered everything
              that normally follows the URL, e.g. /XMLRPC
            - if {http[s],file}:// exists, anything between that and the next /
              is the URL.
              
        The behavior of *this* function:
            - if no {http[s],file}:// then the string is simply assumed to be a
              URL without the {http[s],file}:// attached. The parsed info is
              reparsed as one would think it would be:

            - returns: (addressing scheme, network location, path,
                        parameters, query, fragment identifier).

              NOTE: netloc (or network location) can be HOSTNAME:PORT
    """

    schemes = ('http', 'https')
    if url is None:
        return None
    parsed = list(urlparse.urlparse(url))
    if not parsed[0] or parsed[0] not in schemes:
        url = 'https://' + url
        parsed = list(urlparse.urlparse(url))
        parsed[0] = ''
    return tuple(parsed)


def parseHttpProxyString(httpProxy):
    """ parse HTTP proxy string and check for validity """

    httpProxy = parseUrl(httpProxy)[1]
    tup = string.split(httpProxy, ':')
    if len(tup) != 2:
        sys.stderr.write("ERROR: invalid host:port (%s)\n" % httpProxy)
        sys.exit(errnoBadHttpProxyString)
    try:
        int(tup[1])
    except ValueError:
        sys.stderr.write("ERROR: invalid host:port (%s)\n" % httpProxy)
        sys.exit(errnoBadHttpProxyString)
    return httpProxy


def getExistingOverridesConfig(overrides):
    """ Fetch previously set values from the overrides file.
        These values will be used to set the defaults for the commandline.
        Sensible defaults are chosen for any settings left blank.
        FIXME: I don't use this yet.
    """

    d = {
            'enableProxy':      None,
            'enableProxyAuth':  None,
            'httpProxy':        None,
            'proxyUser':        None,
            'proxyPassword':    None,
            'serverURL':        '',
            'sslCACert':        '',
            'useGPG':           1,
        }
    if os.path.exists(overrides):
        d.update(readConfigFile(overrides))

    # now let's fill in any blanks with sensible defaults.
    if not d['serverURL']:
        d['serverURL'] = 'https://' + socket.gethostname() + '/XMLRPC'

    d['sslCACert'] = d['sslCACert'] or DEFAULT_CA_CERT_PATH

    # http_proxy can be one of None, '' or 'something:port'
    # None means leave the configuration alone.
    # '' or 'something:port' means remap it.
    if d['httpProxy'] == '':
        d['proxyUser'] = ''
        d['enableProxy'] = 0
    elif d['httpProxy'] is None:
        d['proxyUser'] = None
        d['enableProxy'] = None # means no change
    else:
        d['enableProxy'] = 1

    if d['proxyUser'] == '':
        d['proxyPassword'] = ''
        d['enableProxyAuth'] = 0
    elif d['proxyUser'] is None:
        d['proxyPassword'] = None
        d['enableProxyAuth'] = None # means no change
    else:
        d['enableProxyAuth'] = 1

    return d


def processCACertPath(options):
    isRpmYN = 0

    if options.ssl_cert:
        if options.ssl_cert[-4:] == '.rpm':
            isRpmYN = 1

    if not options.ssl_cert:
        # look for the RPM
        isRpmYN = 1
        _cert = os.path.join(options.pub_tree, CA_CRT_RPM_NAME)
        filenames = glob.glob("%s-*.noarch.rpm" % _cert)
        filenames = rhn_rpm.sortRPMs(filenames)
        if filenames:
            options.ssl_cert = filenames[-1]

    if not options.ssl_cert:
        # look for the raw cert
        isRpmYN = 0
        options.ssl_cert = os.path.join(options.pub_tree, CA_CRT_NAME)
        if not os.path.isfile(options.ssl_cert):
            options.ssl_cert = ''

    return isRpmYN


def getDefaultOptions():
    _defopts = {
            'activation-keys': '',
            'overrides': DEFAULT_OVERRIDES,
            'script': DEFAULT_SCRIPT,
            'hostname': socket.gethostname(),
            'ssl-cert': '', # will trigger a search
            'gpg-key': "",
            'http-proxy': "",
            'http-proxy-username': "",
            'http-proxy-password': "",
            'allow-config-actions': 0,
            'allow-remote-commands': 0,
            'no-ssl': 0,
            'no-gpg': 0,
            'no-up2date': 0,
            'force': 0,
            'pub-tree': DEFAULT_APACHE_PUB_DIRECTORY,
            'verbose': 0,
               }
    return _defopts

defopts = getDefaultOptions()


def getOptionsTable():
    """ returns the command line options table """

    def getSetString(value):
        if value:
            return 'SET'
        return 'UNSET'

    # the options
    bsOptions = [
        Option('--activation-keys',
               action='store',
               type='string', default=defopts['activation-keys'],
               help='activation key(s) as defined in the RHN web UI - format is XKEY,YKEY,... (currently: %s)' % repr(defopts['activation-keys'])),
        Option('--overrides',
               action='store',
               type='string', default=defopts['overrides'],
               help='configuration overrides filename (currently: %s)' % defopts['overrides']),
        Option('--script',
               action='store',
               type='string', default=defopts['script'],
               help='bootstrap script filename. (currently: %s)' % defopts['script']),
        Option('--hostname',
               action='store',
               type='string', default=defopts['hostname'],
               help='hostname (FQDN) to which clients connect (currently: %s)' % defopts['hostname']),
        Option('--ssl-cert',
               action='store',
               type='string', default=defopts['ssl-cert'],
               help='path to corporate public SSL certificate - an RPM or a raw certificate. It will be copied to --pub-tree. A value of "" will force a search of --pub-tree.'),
        Option('--gpg-key',
               action='store',
               type='string', default=defopts['gpg-key'],
               help='path to corporate public GPG key, if used. It will be copied to the location specified by the --pub-tree option. (currently: %s)' % repr(defopts['gpg-key'])),
        Option('--http-proxy',
               action='store',
               type='string', default=defopts['http-proxy'],
               help='HTTP proxy setting for the clients - hostname:port. --http-proxy="" disables. (currently: %s)' % repr(defopts['http-proxy'])),
        Option('--http-proxy-username',
               action='store',
               type='string', default=defopts['http-proxy-username'],
               help='if using an authenticating HTTP proxy, specify a username. --http-proxy-username="" disables. (currently: %s)' % repr(defopts['http-proxy-username'])),
        Option('--http-proxy-password',
               action='store',
               type='string', default=defopts['http-proxy-password'],
               help='if using an authenticating HTTP proxy, specify a password. (currently: %s)' % repr(defopts['http-proxy-password'])),
        Option('--allow-config-actions',
               action='store_true',
               help='boolean; allow all configuration actions - requires installing certain rhncfg-* RPMs probably via an activation key. (currently: %s)' % getSetString(defopts['allow-config-actions'])),
        Option('--allow-remote-commands',
               action='store_true',
               help='boolean; allow arbitrary remote commands - requires installing certain rhncfg-* RPMs probably via an activation key. (currently: %s)' % getSetString(defopts['allow-remote-commands'])),
        Option('--no-ssl',
               action='store_true',
               help='(not recommended) boolean; turn off SSL in the clients (currently %s)' % getSetString(defopts['no-ssl'])),
        Option('--no-gpg',
               action='store_true',
               help='(not recommended) boolean; turn off GPG checking by the clients (currently %s)' % getSetString(defopts['no-gpg'])),
        Option('--no-up2date',
               action='store_true',
               help='(not recommended) boolean; will not run the up2date section (full update usually) once bootstrapped (currently %s)' % getSetString(defopts['no-up2date'])),
        Option('--pub-tree',
               action='store',
               type='string', default=defopts['pub-tree'],
               help='(change not recommended) public directory tree where the CA SSL cert/cert-RPM will land as well as the bootstrap directory and scripts. (currently %s)' % defopts['pub-tree']),
        Option('--force',
               action='store_true',
               help='(not recommended) boolean; including this option forces bootstrap script generation despite warnings (currently %s)' % getSetString(defopts['force'])),
        Option('-v','--verbose',
               action='count',
               help='be verbose - accumulable: -vvv means "be *really* verbose" (currently %s)' % defopts['verbose']),
    ]

    return bsOptions


def parseCommandline():
    "parse the commandline/options, sanity checking, et c."

    _progName = os.path.basename(sys.argv[0])
    _usage = """\
%s [options]

Note: for rhn-bootstrap to work, certain files are expected to be
      in /var/www/html/pub/ (the default Apache public directory):
        - the CA SSL public certificate (probably RHN-ORG-TRUSTED-SSL-CERT)
        - the CA SSL public certficate RPM
          (probably rhn-org-trusted-ssl-cert-VER.noarch.rpm)""" % _progName

    # preliminary parse (-h/--help is acted upon during final parse)
    optionList = getOptionsTable()

    optionListNoHelp = optionList[:]
    fake_help = Option("-h", "--help", action="count", help='')
    optionListNoHelp.append(fake_help)
    options, _args = OptionParser(option_list=optionListNoHelp, add_help_option=0).parse_args()

    # we take no extra commandline arguments that are not linked to an option
    if _args:
        sys.stderr.write("\nERROR: these arguments make no sense in this "
                         "context (try --help): %s\n" % repr(_args))
        sys.exit(errnoExtraCommandLineArgs)


    # reset the defaults - I need them on the next pass
    global defopts
    defopts = {
            'activation-keys': options.activation_keys,
            'overrides': options.overrides or DEFAULT_OVERRIDES,
            'script': options.script or DEFAULT_SCRIPT,
            'hostname': options.hostname,
            'ssl-cert': options.ssl_cert,
            'gpg-key': options.gpg_key,
            'http-proxy': options.http_proxy,
            'http-proxy-username': options.http_proxy_username,
            'http-proxy-password': options.http_proxy,
            # "not not" forces the integer value
            'allow-config-actions': not not options.allow_config_actions,
            'allow-remote-commands': not not options.allow_remote_commands,
            'no-ssl': not not options.no_ssl,
            'no-gpg': not not options.no_gpg,
            'no-up2date': not not options.no_up2date,
            'pub-tree': options.pub_tree,
            'force': options.force,
            'verbose': options.verbose or 0,
              }

    processCACertPath(options)
    defopts['ssl-cert'] = options.ssl_cert

    # final parse after defaults have been remapped
    options, _args = OptionParser(option_list=getOptionsTable(), usage=_usage).parse_args()

    return options


def processCommandline():
    options = parseCommandline()

    if options.script[-3:] != '.sh':
        sys.stderr.write("""\
ERROR: value of --script must end in '.sh':
       '%s'\n""" % options.script)
        if not options.force:
            sys.stderr.write("exiting\n")
            sys.exit(errnoBadScriptName)

    options.pub_tree = cleanupAbsPath(options.pub_tree or DEFAULT_APACHE_PUB_DIRECTORY)
    options.overrides = os.path.basename(options.overrides)
    options.script = os.path.basename(options.script)

    if string.find(options.pub_tree, DEFAULT_APACHE_PUB_DIRECTORY) != 0:
        sys.stderr.write("WARNING: it's *highly* suggested that --pub-tree is set to:\n")
        sys.stderr.write("           %s\n" % DEFAULT_APACHE_PUB_DIRECTORY)
        sys.stderr.write("         It is currently set to:\n")
        sys.stderr.write("           %s\n" % options.pub_tree)
        if not options.force:
            sys.stderr.write("exiting\n")
            sys.exit(errnoBadPath)

    if options.overrides == options.script:
        sys.stderr.write("""\
ERROR: the value of --overrides and --script cannot be the same!
       '%s'\n""" % options.script)
        sys.exit(errnoScriptNameClash)

    if len(string.split(options.hostname, '.')) < 3:
        msg = ("WARNING: --hostname (%s) doesn't appear to be a FQDN.\n"
               % options.hostname)
        sys.stderr.write(msg)
        if not options.force:
            sys.stderr.write("exiting\n")
            sys.exit(errnoNotFQDN)

    processCACertPath(options)
    if not options.no_ssl and options.ssl_cert and not os.path.exists(options.ssl_cert):
        sys.stderr.write("ERROR: CA SSL certificate file or RPM not found\n")
        sys.exit(errnoCANotFound)

    if not options.no_gpg and options.gpg_key and not os.path.exists(options.gpg_key):
        sys.stderr.write("ERROR: corporate public GPG key file not found\n")
        sys.exit(errnoGPGNotFound)

    if options.http_proxy != "":
        options.http_proxy = parseHttpProxyString(options.http_proxy)

    if not options.http_proxy:
        options.http_proxy_username = ''

    if not options.http_proxy_username:
        options.http_proxy_password = ''
    
    # forcing numeric values
    for opt in ['allow_config_actions', 'allow_remote_commands', 'no_ssl',
        'no_gpg', 'no_up2date', 'verbose']:
        # operator.truth should return (0, 1) or (False, True) depending on
        # the version of python; passing any of those values through int()
        # will return an int
        val = int(operator.truth(getattr(options, opt)))
        setattr(options, opt, val)

    return options


def copyFiles(options):
    """ copies SSL cert and GPG key to --pub-tree if not in there already
        existence check should have already been done.
    """

    pubDir = cleanupAbsPath(options.pub_tree or DEFAULT_APACHE_PUB_DIRECTORY)

    def copyFile(file0, file1):
        if not os.path.exists(os.path.dirname(file1)):
            sys.stderr.write("ERROR: directory does not exist:\n       %s\n"
                             % os.path.dirname(file1))
            sys.exit(errnoBadPath)
        if not os.path.exists(file0):
            sys.stderr.write("ERROR: file does not exist:\n       %s\n"
                             % file0)
            sys.exit(errnoCANotFound)
        sys.stderr.write("""\
  Coping file into public directory tree:
    %s to
    %s
""" % (file0, file1))
        shutil.copy(file0, file1)

    # CA SSL cert
    if not options.no_ssl and options.ssl_cert:
        writeYN = 1
        dest = os.path.join(pubDir, os.path.basename(options.ssl_cert))
        if os.path.dirname(options.ssl_cert) != pubDir:
            if os.path.isfile(dest) \
              and getFileChecksum('md5', options.ssl_cert) != getFileChecksum('md5', dest):
                rotateFile(dest, options.verbose)
            elif os.path.isfile(dest):
                writeYN = 0
            if writeYN:
                copyFile(options.ssl_cert, dest) 

    # corp GPG key
    if not options.no_gpg and options.gpg_key:
        writeYN = 1
        dest = os.path.join(pubDir, os.path.basename(options.gpg_key))
        if os.path.dirname(options.gpg_key) != pubDir:
            if os.path.isfile(dest) \
              and getFileChecksum('md5', options.gpg_key) != getFileChecksum('md5', dest):
                rotateFile(dest, options.verbose)
            elif os.path.isfile(dest):
                writeYN = 0
            if writeYN:
                copyFile(options.gpg_key, dest) 


def writeClientConfigOverrides(options):
    """ write our "overrides" configuration file
        This generated file is a configuration mapping file that is used
        to map settings in up2date and rhn_register when run through a
        seperate script.
    """

    up2dateConfMap = {
        # some are directly mapped, others are handled more delicately
        'http_proxy':           'httpProxy',
        'http_proxy_username':  'proxyUser',
        'http_proxy_password':  'proxyPassword',
        'hostname':             'serverURL',
        'ssl_cert':             'sslCACert',
        'no_gpg':               'useGPG',
    }

    _bootstrapDir = cleanupAbsPath(os.path.join(options.pub_tree, 'bootstrap'))

    if not os.path.exists(_bootstrapDir):
        print "* creating '%s'" % _bootstrapDir
        os.makedirs(_bootstrapDir) # permissions should be fine

    d = {}
    if options.hostname:
        scheme = 'https'
        if options.no_ssl:
            scheme = 'http'
        d['serverURL'] = scheme + '://' + options.hostname + '/XMLRPC'
        d['noSSLServerURL'] = 'http://' + options.hostname + '/XMLRPC'
    
    # if proxy, enable it
    # if "", disable it
    if options.http_proxy:
        d['enableProxy'] = '1'
        d[up2dateConfMap['http_proxy']] = options.http_proxy
    else:
        d['enableProxy'] = '0'
        d[up2dateConfMap['http_proxy']] = ""

    # if proxy username, enable auth proxy
    # if "", disable it
    if options.http_proxy_username:
        d['enableProxyAuth'] = '1'
        d[up2dateConfMap['http_proxy_username']] = options.http_proxy_username
        d[up2dateConfMap['http_proxy_password']] = options.http_proxy_password
    else:
        d['enableProxyAuth'] = '0'
        d[up2dateConfMap['http_proxy_username']] = ""
        d[up2dateConfMap['http_proxy_password']] = ""

    # CA SSL certificate is a bit complicated. options.ssl_cert may be a file
    # or it may be an RPM or it may be "", which means "try to figure it out
    # by searching through the --pub-tree on your own.
    _isRpmYN = processCACertPath(options)
    if not options.ssl_cert:
        sys.stderr.write("WARNING: no SSL CA certificate or RPM found in %s\n" % options.pub_tree)
        if not options.no_ssl:
            sys.stderr.write("         Fix it by hand or turn off SSL in the clients (--no-ssl)\n")
    _certname = os.path.basename(options.ssl_cert) or CA_CRT_NAME
    _certdir = os.path.dirname(DEFAULT_CA_CERT_PATH)
    if _isRpmYN:
        hdr = rhn_rpm.get_package_header(options.ssl_cert)
        # Grab the first file out of the rpm
        d[up2dateConfMap['ssl_cert']] = hdr[rhn_rpm.RPMTAG_FILENAMES][0] # UGLY!
    else:
        d[up2dateConfMap['ssl_cert']] = os.path.join(_certdir, _certname)
    d[up2dateConfMap['no_gpg']] = int(operator.truth(not options.no_gpg))

    writeYN = 1
    _overrides = cleanupAbsPath(os.path.join(_bootstrapDir, options.overrides))
    if os.path.exists(_overrides):
        if readConfigFile(_overrides) != d:
            # only back it up if different
            backup = rotateFile(_overrides, depth=5, verbosity=options.verbose)
            if backup and options.verbose>=0:
                print """\
* WARNING: if there were hand edits to the rotated (backed up) file,
           some settings may need to be migrated."""
        else:
            # exactly the same... no need to write
            writeYN = 0
            print """\
* client configuration overrides (old and new are identical; not written):
  '%s'\n""" % _overrides

    if writeYN:
        fout = open(_overrides, 'wb')
        # header
        fout.write("""\
# RHN Client (rhn_register/up2date) config-overrides file v4.0
#
# To be used only in conjuction with client_config_update.py
#
# This file was autogenerated.
#
# The simple rules:
#     - a setting explicitely overwrites the setting in
#       /etc/syconfig/rhn/{rhn_register,up2date} on the client system.
#     - if a setting is removed, the client's state for that setting remains
#       unchanged.

""")
        keys = d.keys()
        keys.sort()
        for key in keys:
            if d[key] is not None:
                fout.write("%s=%s\n" % (key, d[key]))
        fout.close()
        print """\
* bootstrap overrides (written):
  '%s'\n""" % _overrides
        if options.verbose>=0:
            print "Values written:"
            for k, v in d.items():
                print k + ' '*(25-len(k)) + repr(v)


def generateBootstrapScript(options):
    "write, copy and place files into /var/www/html/pub/bootstrap/"

    orgCACert = os.path.basename(options.ssl_cert or '')

    # write to /var/www/html/pub/bootstrap/<options.overrides>
    writeClientConfigOverrides(options)

    isRpmYN = processCACertPath(options)
    pubname = os.path.basename(options.pub_tree)

    # generate script
    # In processCommandline() we have turned all boolean values to 0 or 1
    # this means that we can negate those booleans with 1 - their current
    # value (instead of doing not value which can yield True/False, which
    # would print as such)
    newScript = getHeader(PRODUCT_NAME, options.activation_keys,
                  options.gpg_key, options.overrides, options.hostname,
                  orgCACert, isRpmYN, 1 - options.no_ssl, 1 - options.no_gpg,
                  options.allow_config_actions, options.allow_remote_commands,
                  1 - options.no_up2date, pubname)

    writeYN = 1

    # concat all those script-bits
    newScript = newScript + getConfigFilesSh() + getUp2dateScriptsSh()

    
    newScript = newScript + getGPGKeyImportSh() + getCorpCACertSh() + \
                getRegistrationSh(PRODUCT_NAME) 

    #5/16/05 wregglej 159437 - moving stuff that messes with the allowed-action dir to after registration
    if options.allow_config_actions:
        newScript = newScript + getAllowConfigManagement()
    if options.allow_remote_commands:
        newScript = newScript + getAllowRemoteCommands()

    #5/16/05 wregglej 159437 - moved the stuff that up2dates the entire box to after allowed-actions permissions are set.
    newScript = newScript + getUp2dateTheBoxSh()

    _bootstrapDir = cleanupAbsPath(os.path.join(options.pub_tree, 'bootstrap'))
    _script = cleanupAbsPath(os.path.join(_bootstrapDir, options.script))

    if os.path.exists(_script):
        oldScript = open(_script, 'rb').read()
        if oldScript == newScript:
            writeYN = 0
        elif os.path.exists(_script):
            backup = rotateFile(_script, depth=5, verbosity=options.verbose)
            if backup and options.verbose>=0:
                print "* rotating %s --> %s" % (_script, backup)
        del oldScript

    if writeYN:
        fout = open(_script, 'wb')
        fout.write(newScript)
        fout.close()
        print """\
* bootstrap script (written):
    '%s'\n""" % _script
    else:
        print """\
* boostrap script (old and new scripts identical; not written):
    '%s'\n""" % _script


def main():
    """ Main code block:

        o options on commandline take precedence, but if option not set...
        o prepopulate the commandline options from already generated
          /var/www/pub/bootstrap/client-config-overrides.txt if in existance.
          FIXME: isn't done as of yet.
        o set defaults otherwise
    """

    #print "Commandline: %s" % repr(sys.argv)
    options = processCommandline()
    copyFiles(options)
    generateBootstrapScript(options)

    return 0


if __name__ == "__main__":
    """ Exit codes - defined at top of module:
            errnoSuccess = 0
            errnoGeneral = 1
            errnoScriptNameClash = 10
            errnoBadScriptName = 11
            errnoExtraCommandLineArgs = 12
            errnoBadHttpProxyString = 13
            errnoBadPath = 14
            errnoNotFQDN = 15
            errnoCANotFound = 16
            errnoGPGNotFound = 17
    """

    try:
        sys.exit(abs(main() or errnoSuccess))
    except SystemExit:
        # No problem, sys.exit() raises this
        raise
    except KeyboardInterrupt:
        sys.exit(errnoSuccess)
    except ValueError, e:
        raise # should exit with a 1 (errnoGeneral)
    except Exception:
        sys.stderr.write('Unhandled ERROR occured.\n')
        raise # should exit with a 1 (errnoGeneral)

