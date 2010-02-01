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
#The configuration file parser for the rhnpush utility.
#The majority of this code is taken from rhncfg/config_common/local_config.py
#
# 11/11/2004 John Wregglesworth
#

import os
import sys
import ConfigParser
import utils

True = 1
False = 0


#Class that contains the options read in from the config file.
#Uses a ConfigParser to create a dictionary of the configuration options.
#That dictionary is then used to add instance variables to the object dynamically.
class rhnpushConfigParser:
    _instance = None

    def __init__(self, filename, ensure_consistency=False):
                
        #Defaults that are used if the ensure_consistency parameter of the constructor is true
        #and the config file that is being read is missing some values.
        self.options_defaults = {
                                'newest'            :   '0',
                                'usage'             :   '0',
                                'header'            :   '0',
                                'test'              :   '0',
                                'nullorg'           :   '0',
                                'source'            :   '0',
                                'stdin'             :   '0',
                                'verbose'           :   '0',
                                'force'             :   '0',
                                'nosig'             :   '0',
                                'list'              :   '0',
                                'exclude'           :   '',
                                'files'             :   '',
                                'orgid'             :   '',
                                'reldir'            :   '',
                                'count'             :   '',
                                'dir'               :   '',
                                'server'            :   'http://rhn.redhat.com/APP',
                                'channel'           :   '',
                                'cache_lifetime'    :   '600',
                                'new_cache'         :   '0',
                                'no_cache'          :   '0',
                                'extended_test'     :   '0',
                                'no_session_caching'     :   '0', 
                                'tolerant'          :   '0',            
                                }

        #Used to parse the config file.
        self.settings = ConfigParser.ConfigParser()
        
        
        if filename is None:
            print "filename not passed to the rhnpushConfigParser constructor."
            sys.exit(1)
        else:
            self.filename = filename
        
        #use options from the rhnpush section.  
        self.section = "rhnpush"

        self.username = None
        self.password = None    
    
        self._read_config_files()

        #Take all of the options read from the configuration file and add them as attributes 
        #(instance variables, member variables, whatever) of this object.
        self._add_config_as_attr(ensure_consistency=ensure_consistency)
    
    #Use the ConfigParser to read in the configuration file.
    def _read_config_files(self):   
        #try:
            #file = open(self.filename, 'r')
        #except IOError:
        #   sys.exit(1)

        try:
            self.settings.read([self.filename])
            #file.close()
        except IOError,e:
            print "Config File Error: line %s, file %s: $s" % (e.lineno, e.filename, e)
            sys.exit(1)

    def write(self, fileobj):
        try:
            self.settings.write(fileobj)
        except IOError, e:
            print "Config File Error: line %s, file %s: $s" % (e.lineno, e.filename, e)
            sys.exit(1)


    #Returns an option read in from the configuration files and specified by the string variable option.
    #This function can probably be safely removed, since all configuration options become attributes
    #of an instantiation of this class.
    def get_option(self, option):
        try:
            return self.settings.get(self.section, option)
        except(ConfigParser.NoOptionError, ConfigParser.NoSectionError), e:
            print "Option/Section Error: line %s, file %s: %s" % (e.lineno, e.filename, e)
            sys.exit(1)

    #Returns the keys of the attributes of the object.
    def keys(self):
        return self.__dict__.keys()

    #Returns the keys of the options read in from the configuration files.
    def _keys(self):
        return self.settings.options(self.section)

    #Returns an option read in from the configuration files.
    def __getitem__(self, item):
        return self.settings.get_option(item)

    #Takes all of the configuration options read in by the ConfigParser and makes them attributes of the object.
    def _add_config_as_attr(self, ensure_consistency=False):
        for k in self._keys():
            self.__dict__[k] = self.settings.get(self.section, k)

        #ensuring consistency only checks for missing configuration option. 
        if ensure_consistency:
            for thiskey in self.options_defaults.keys():
                if not self.__dict__.has_key(thiskey):
                    print "/etc/sysconfig/rhn/rhnpushrc is missing %s option." % (thiskey)
                    print "Option %s is being set to the default value of %s." % (thiskey, self.options_defaults[thiskey])
                    self.__dict__[thiskey] = self.options_defaults[thiskey]

