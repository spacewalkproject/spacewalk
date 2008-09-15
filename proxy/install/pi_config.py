# installer configuration object and routines.
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
#------------------------------------------------------------------------------
# $Id: pi_config.py,v 1.22 2004/06/18 19:28:43 taw Exp $

import os
import sys
import pwd

from pi_lib import DEFAULT_CONFIG_FILE, fetchTraceback, rotateFile

# up2date needs to be installed
# Need to use its config parser
sys.path.append("/usr/share/rhn/")
from up2date_client import config


class ProxyConfig:

    def __init__(self):
        # configuration dictionaries:
        # { key: setting, ... }
        # { key: comment, ... }
        self._confDict = {
            'traceback_mail': '',
            'proxy.pkg_dir': '/var/up2date/packages',

            # http proxies should all point to the same thing.
            'proxy.http_proxy': '',
            'proxy.http_proxy_username': '',
            'proxy.http_proxy_password': '',

            'proxy.rhn_parent': 'xmlrpc.rhn.redhat.com',
            'proxy.ca_chain': '/usr/share/rhn/RHNS-CA-CERT',
        }
        self._confCommentDict = {
            'traceback_mail': "Destination of all tracebacks, etc.",
            'proxy.pkg_dir': "Location of locally built, custom packages",

            # http proxies should all point to the same thing.
            'proxy.http_proxy': "Corporate HTTP proxy, format: corp_gateway.example.com:8080",
            'proxy.http_proxy_username': "Username for that corporate HTTP proxy",
            'proxy.http_proxy_password': "Password for that corporate HTTP proxy",

            'proxy.rhn_parent': 'Hostname of RHN Server or RHN Satellite',
            'proxy.ca_chain': 'SSL CA certificate location',
        }

    def set(self, key, setting, comment=None):
        """ set (setting, comment) tuple. """

        if comment is None:
            comment = ""
            if self._confCommentDict.has_key(key):
                comment = self._confCommentDict[key]
        self._confDict[key] = setting
        self._confCommentDict[key] = comment

    def get(self, key):
        """ return (setting, comment) tuple. """
        return self._confDict[key], self._confCommentDict[key]

    def write(self):
        """ dump to /etc/rhn/rhn.conf """

        # rotate the file
        if os.path.exists(DEFAULT_CONFIG_FILE):
            rotateFile(DEFAULT_CONFIG_FILE)

        dirname = os.path.dirname(DEFAULT_CONFIG_FILE)
        if not os.path.exists(dirname):
            os.makedirs(dirname, 0750)
            apacheGID = pwd.getpwnam('apache')[3]
            # chown root.apache ...
            os.chown(dirname, 0, apacheGID)

        fo = open(DEFAULT_CONFIG_FILE, 'w')
        os.chmod(DEFAULT_CONFIG_FILE, 0640)

        try:
            msg = "# Automatically generated RHN Management " +\
                  "Proxy Server configuration file."
            msg = msg+'\n# ' + '-'*len(msg) + '\n\n'
            fo.write(msg)
            print msg,
            keys = self._confDict.keys()
            keys.sort()
            for k in keys:
                v = self._confDict[k]
                cv = self._confCommentDict[k]
                print "# %s\n" % cv,
                print "%s = %s\n\n" % (k, v),
                fo.write("# %s\n" % cv)
                fo.write("%s = %s\n\n" % (k, v))
            # rhn.conf needs to be accessible by apache
            apacheGID = pwd.getpwnam('apache')[3]
            # chown root.apache ...
            os.chown(DEFAULT_CONFIG_FILE, 0, apacheGID)
        except IOError, e:
            print 'ERROR writing to %s: %s' % (DEFAULT_CONFIG_FILE, repr(e))
            raise e
        except Exception, e:
            print 'ERROR writing to %s: %s' % (DEFAULT_CONFIG_FILE, repr(e))
            raise e
        fo.close()
        return None


class RhnRegisterConfig(config.Config):
    def __init__(self):
        config.Config.__init__(self)
        self.fileName = "/etc/sysconfig/rhn/rhn_register"


up2dateCfg = config.Up2dateConfig()
registerCfg = RhnRegisterConfig()


def _test():
    """ TEST CODE ONLY! """
    
    print 'Testing print_config.py'
    #foo = generateSessionSecrets()
    #print foo
    foo = ProxyConfig()
    #foo.brokenload()
    print foo
    #for i in foo.keys():
    #    print "%s=%s" % (i, foo.readEntry(i))

    #print
    #foo.brokensave()
#    print foo[2]
#    deployConfigs()
if __name__ == "__main__":
    _test()

