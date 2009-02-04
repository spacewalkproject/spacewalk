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
if hasattr(sys, 'version_info'):
    # Python 2 - Use the platform-wide ConfigParser
    import ConfigParser
else:
    # Python 1.5.2 - use the internal copy
    import _ConfigParser
    ConfigParser = _ConfigParser
    
InterpolationError = ConfigParser.InterpolationError

class ClientConfigParser(ConfigParser.ConfigParser):
    _instance = None
    _global_config_file = "/etc/sysconfig/rhn/osad.conf"

    def __init__(self, section, defaults=None):
        """defaults is either None, or a dictionary of default values which can be overridden"""
        ConfigParser.ConfigParser.__init__(self, defaults)
        self.section = section
        self.overrides = {}

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
        return [
            self._global_config_file,
        ]

    def get_option(self, option, defval=None):
        try:
            return self.get(self.section, option, vars=self.overrides)
        except (ConfigParser.NoOptionError, ConfigParser.NoSectionError), e:            
            pass

        defaults = self.defaults()
        
        if defaults.has_key(option):
            return defaults[option]

        return defval

    def has_key(self, option):
        return self.has_option(self.section, option)

    def keys(self):
        return self.options(self.section)

    def __getitem__(self, item):
        return self.get_option(item)

class UserPassConfigParser(ClientConfigParser):
    _global_config_file = "/etc/sysconfig/rhn/osad-auth.conf"

def init(section, defaults=None, config_file=None, **overrides):
    cp = ClientConfigParser._instance = ClientConfigParser(section, defaults)
    # Allow for the config file to be changed, if necessary
    if config_file is not None:
        cp._global_config_file = config_file
    cp.read_config_files(overrides)
    return cp
    
def get(var, defval=None):
    return _get_config().get_option(var, defval=defval)

def _get_config():
    if ClientConfigParser._instance is None:
        raise ValueError, "Configuration not initialized"
    return ClientConfigParser._instance

def instance():
    return _get_config()

def keys():
    return _get_config().keys()

def get_auth_info(auth_file, section, force, **defaults):
    _modified = 0
    c = UserPassConfigParser(section)
    if auth_file is not None:
        c._global_config_file = auth_file
    c.read_config_files()
    if not c.has_section(section):
        _modified = 1
        c.add_section(section)
    for k, v in defaults.items():
        if not c.has_option(section, k) or force:
            c.set(section, k, v)
            _modified = 1
    if _modified:
        fd = os.open(c._global_config_file, 
            os.O_CREAT | os.O_TRUNC | os.O_WRONLY, 0600)
        f = os.fdopen(fd, "w")
        f.write("# Automatically generated. Do not edit!\n\n")
        c.write(f)
        f.close()
    return c

def main():
    init('osad')
    print "server_url: %s" % get("server_url")

    auth_file = "/tmp/osad-auth.conf"
    section = "osad-auth"
    c = get_auth_info(auth_file, section, username="aaa", password="bbb")
    print c.keys()

if __name__ == '__main__':
    main()
