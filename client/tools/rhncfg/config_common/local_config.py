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

import os
import sys
import string
import ConfigParser

import utils

class rhncfgConfigParser(ConfigParser.ConfigParser):
    _local_config_file_name = '.rhncfgrc'
    _instance = None

    def __init__(self, section, defaults=None):
        """defaults is either None, or a dictionary of default values which can be overridden"""
        ConfigParser.ConfigParser.__init__(self, defaults)
        self.section = section
        self.overrides = {}
        self.mydefaults = self.defaults()

    def read_config_files(self, overrides={}):
        self.overrides.clear()
        self.overrides.update(overrides)

        try:
            self.read(self._get_config_files())
        except ConfigParser.MissingSectionHeaderError, e:
            print "Config error: line %s, file %s: %s" % (e.lineno, 
                e.filename, e)
            sys.exit(1)

    def _get_config_files(self):
        if string.find(sys.platform, 'sunos') > -1:
            return [ 
                "/opt/redhat/rhn/solaris/etc/sysconfig/rhn/%s.conf" % self.section,
                os.path.join(utils.get_home_dir(), self._local_config_file_name),
                self._local_config_file_name,
            ]
        else:
            return [
                "/etc/sysconfig/rhn/%s.conf" % self.section,
                os.path.join(utils.get_home_dir(), self._local_config_file_name),
                self._local_config_file_name,
            ]

    def get_option(self, option):
        #6/29/05 wregglej 152388
        # server_list is always in the defaults, never in the rhncfg config file. It's formed when there
        # are more than one server in up2date's serverURL setting.
        if option == 'server_list':
            if self.mydefaults.has_key('server_list'):
                if type(self.mydefaults['server_list']) is type([]):
                    return self.mydefaults['server_list']
                
        try:
            ret = self.get(self.section, option, vars=self.overrides)

            #5/25/05 wregglej - 158694
            #Move the cast to an int to here from the up2date_config_parser, that way the stuff that needs to get interpolated
            #gets interpolated, the stuff that should be an int ends up and int, and the stuff that's neither doesn't get 
            #messed with.
            try:
                if type(ret) != type([]):
                    ret = int(ret)
            except ValueError:
                pass
            return ret 
        except (ConfigParser.NoOptionError, ConfigParser.NoSectionError), e:            
            pass

        defaults = self.defaults()
        
        if defaults.has_key(option):
            return defaults[option]
        else:
            return None

    def keys(self):
        return self.options(self.section)

    def __getitem__(self, item):
        return self.get_option(item)

def init(section, defaults=None, **overrides):
    cp = rhncfgConfigParser._instance = rhncfgConfigParser(section, defaults)
    cp.read_config_files(overrides)
    
def get(var):
    return _get_config().get_option(var)

def _get_config():
    if rhncfgConfigParser._instance is None:
        raise ValueError, "Configuration not initialized"
    return rhncfgConfigParser._instance

def instance():
    return _get_config()

def keys():
    return _get_config().keys()

def main():
    init('rhncfgcli')
    print "repository: %s" % get("repository")
    print "useGPG: %s" % get("useGPG")
    print "serverURL: %s" % get("serverURL")

if __name__ == '__main__':
    main()
