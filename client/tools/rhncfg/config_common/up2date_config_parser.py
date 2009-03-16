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

"""
This module exposes ConfigFile, a class that can be used to parse up2date's
configuration file format.
"""

import os
import string

class ConfigFileError(Exception):
    pass

class ConfigFileMissingError(ConfigFileError):
    pass

class ConfigFileAccessError(ConfigFileError):
    pass

# a peristent configuration storage class
class ConfigFile:
    "class for handling persistent config options for the client"

    fileName = "/etc/sysconfig/rhn/up2date"
    def __init__(self):
        self.dict = {}
            
    def load(self, filename = None):
        if filename:
            self.fileName = filename

        if not os.path.exists(self.fileName):
            raise ConfigFileMissingError(self.fileName)

        if not os.access(self.fileName, os.R_OK):
            raise ConfigFileAccessError(self.fileName)
        
        f = open(self.fileName, "r")

        for line in f.readlines():
            # strip comments
            if '#' in line:
                line = line[:string.find(line, '#')]
            line = string.strip(line)            
            if not line:
                continue

            value = None
            try:
                (key, value) = map(string.strip, string.split(line, "=", 1))
            except ValueError:
                # Bad directive: not in 'a = b' format
                continue

            # decode a comment line
            comment = None
            pos = string.find(key, "[comment]")
            if pos != -1:
                key = key[:pos]
                comment = value
                value = None

            # figure out if we need to parse the value further
            if value:
                # possibly split value into a list
                values = string.split(value, ";")
                if len(values) == 1:
                    try:
                        #158694 wregglej 5/25/05 turning an option into an int here is causing interpolation problems later
                        #in Python 2.4. This line is a little non-sensical, but changing it anymore would probably require
                        #more changes to the code around it, which doesn't seem necessary.
                        value = value
                    except ValueError:
                        pass
                elif values[0] == "":
                    value = []
                else:
                    if value[-1] != ';':
			value = values
                    else:
                    	value = values[:-1]

            # now insert the (comment, value) in the dictionary
            newval = (comment, value)
            if self.dict.has_key(key): # do we need to update
                newval = self.dict[key]
                if comment is not None: # override comment
                    newval = (comment, newval[1])
                if value is not None: # override value
                    newval = (newval[0], value)
            self.dict[key] = newval
        f.close()

    def save(self):
        if self.fileName == None:
            raise ConfigFileMissingError(self.fileName)
        
        try:
            f = open(self.fileName, "w")
            os.chmod(self.fileName, 0600)
        except (OSError, IOError):
            raise ConfigFileAccessError(self.fileName)

        f.write("# Automatically generated Red Hat Update Agent "
                "config file, do not edit.\n")
        f.write("# Format: 1.0\n")
        f.write("\n")
        for key in self.dict.keys():
            val = self.dict[key]
            f.write("%s[comment]=%s\n" % (key, val[0]))
            if type(val[1]) == type([]):
                f.write("%s=%s;\n" % (key, string.join(map(str, val[1]), ';')))
            else:
                f.write("%s=%s\n" % (key, val[1]))
            f.write("\n")
        f.close()

    # dictionary interface
    def has_key(self, name):
        return self.dict.has_key(name)
    def keys(self):
        return self.dict.keys()
    def values(self):
        return map(lambda a: a[1], self.dict.values())
    def update(self, dict):
        self.dict.update(dict)
    # we return None when we reference an invalid key instead of
    # raising an exception
    def __getitem__(self, name):
        if self.dict.has_key(name):
            return self.dict[name][1]
        return None    
    def __setitem__(self, name, value):
        if self.dict.has_key(name):
            val = self.dict[name]
        else:
            val = (None, None)
        self.dict[name] = (val[0], value)
    # we might need to expose the comments...
    def info(self, name):
        if self.dict.has_key(name):
            return self.dict[name][0]
        return ""

    def __repr__(self):
        return "<%s instance at %s: values=%s>" % (self.__class__, id(self),
            str(self.to_dict()))

    def __str__(self):
        return str(self.to_dict())

    def to_dict(self):
        d = {}
        for k, v in self.dict.items():
            d[k] = v[1]
        return d

if __name__ == '__main__':
    c = ConfigFile()
    c.load()
    print c
