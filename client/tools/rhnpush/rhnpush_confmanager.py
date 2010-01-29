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

import rhnpush_config
import utils
import string
import sys
import os, os.path


try:
    from optparse import Option, OptionParser
except ImportError:
    from optik import Option, OptionParser


True = 1
False = 0

class  ConfManager:
    def __init__(self, optionparser, store_true_list):
        sysdir  = '/etc/sysconfig/rhn'
        homedir = utils.get_home_dir()
        default = 'rhnpushrc'
        regular = '.rhnpushrc'
        deffile = os.path.join(sysdir, default)
        regfile = os.path.join(homedir, regular)
        cwdfile = os.path.join(os.getcwd(), regular)

        #Test for the existence of each of the configfiles.
        if not os.access(deffile, os.F_OK):
            print "%s not found." % (deffile)
            sys.exit(1)
        
        if not os.access(deffile, os.R_OK):
            print "rhnpush does not have read permissions on %s" % (deffile)
            sys.exit(1)
        
        #Check to see if the ~/.rhnpushrc exists.
        if os.access(regfile, os.F_OK):
            #Check for read permissions.
            if not os.access(regfile, os.R_OK):
                print "rhnpush does not have read permission on %s" % (regfile,)
                sys.exit(1)
        else:
            #It's not there, don't read it.
            regfile = deffile

        #Check to see if the ./.rhnpushrc file exists.
        if os.access(cwdfile, os.F_OK):
            #Check for read permissions.
            if not os.access(cwdfile, os.R_OK):
                print "rhnpush does not have read permission on %s" % (cwdfile,)
                sys.exit(1)
        else:
            #It's not there, don't read it.
            cwdfile = regfile

        #Create configuration objects, and set the backups for the user and cwd config file.
        #If the cwd config is missing, use the user config for the cwd. 
        #If the user config is missing use the default config for the user config.
        self.defaultconfig = rhnpush_config.rhnpushConfigParser(deffile, ensure_consistency = True)

        if deffile != regfile:
            self.userconfig = rhnpush_config.rhnpushConfigParser(regfile)
        else:
            self.userconfig = self.defaultconfig

        if regfile != cwdfile:
            self.cwdconfig = rhnpush_config.rhnpushConfigParser(cwdfile)
        else:
            self.cwdconfig = self.userconfig

        #Get a reference to the object containing command-line options  
        self.cmdconfig = optionparser
        self.store_true_list = store_true_list

    #1/3/06 wregglej 172376  rhnpush shouldn't gag, choke, and die when trying to write the 
    #local config file on a read-only filesystem. Plus, I redid the writing of the config files
    #to avoid duping code.
    #2/20/06 wregglej, but apparently it didn't occur to me to remove a completely redundant try-catch.
    def _write_config_file(self, cfg_filename, config_obj):
        #Just skip writing the config file if access is denied. rhnpush is probably being run
        #on a read-only filesystem, which is supported. 
        cfg_dir = os.path.split(cfg_filename)[0]
        if os.access(cfg_dir, os.W_OK):
            new_config_file = open(cfg_filename, "w+")
            config_obj.write(new_config_file)
            new_config_file.close()

    #Change the files options of the self.userconfig, self.defaultconfig, and self.cwdconfig to lists.
    #Change the exclude options of the self.userconfig, self.defaultconfig, and self.cwdconfig to lists.
    def _files_to_list(self):
        #Change the files options to lists.
        if self.userconfig.__dict__.has_key('files') and not type(self.userconfig.__dict__['files']) == type([]):
            self.userconfig.files = map(string.strip, string.split(self.userconfig.files, ','))

        if self.cwdconfig.__dict__.has_key('files') and not type(self.userconfig.__dict__['files']) == type([]):
            self.cwdconfig.files = map(string.strip, string.split(self.cwdconfig.files, ','))

        if not type(self.defaultconfig.files) == type([]):
            self.defaultconfig.files = map(string.strip, string.split(self.defaultconfig.files, ','))

        #Change the exclude options to list.
        if self.userconfig.__dict__.has_key('exclude') and not type(self.userconfig.__dict__['exclude']) == type([]):
            self.userconfig.exclude = map(string.strip, string.split(self.userconfig.exclude, ','))
        
        if self.cwdconfig.__dict__.has_key('exclude') and not type(self.cwdconfig.__dict__['exclude']) == type([]):
            self.cwdconfig.exclude = map(string.strip, string.split(self.cwdconfig.exclude, ','))
        
        if not type(self.defaultconfig.files) == type([]):
            self.defaultconfig.exclude = map(string.strip, string.split(self.defaultconfig.exclude, ','))


    #Changes every option in config that is also in store_true_list that is set to '0' to None
    def _zero_to_none(self, config, store_true_list):
        for opt in config.keys():
            for cmd in store_true_list:
                if str(opt) == cmd and config.__dict__[opt] == '0':
                    config.__dict__[opt] = None

    def get_config(self):
        self._files_to_list()
        
        #Cascade the options from self.userconfig and self.cwdconfig into the self.defaultconfig object.
        self.defaultconfig, self.userconfig = utils.make_common_attr_equal(self.defaultconfig, self.userconfig)
        self.defaultconfig, self.cwdconfig = utils.make_common_attr_equal(self.defaultconfig, self.cwdconfig)
        
        #Change the channel string into a list of strings.
        
        if not self.defaultconfig.channel:
            #if no channel then make it null array instead of
            #an empty string array from of size 1 [''] .
            self.defaultconfig.channel = []
        else:
            self.defaultconfig.channel = map(string.strip, string.split(self.defaultconfig.channel, ','))
        
        #Get the command line arguments. These take precedence over the other settings
        argoptions, files = self.cmdconfig.parse_args()
        
        #Makes self.defaultconfig compatible with argoptions by changing all '0' value attributes to None.
        self._zero_to_none(self.defaultconfig, self.store_true_list)
    
        #If verbose isn't set at the command-line, it automatically gets set to zero. If it's at zero, change it to
        #None so the settings in the config files take precedence.
        if argoptions.verbose == 0:
            argoptions.verbose = None   
    
        #Orgid, count, cache_lifetime, and verbose all need to be integers, just like in argoptions.
        if self.defaultconfig.orgid:
            self.defaultconfig.orgid = int(self.defaultconfig.orgid)

        if self.defaultconfig.count:
            self.defaultconfig.count = int(self.defaultconfig.count)
        
        if self.defaultconfig.cache_lifetime:
            self.defaultconfig.cache_lifetime = int(self.defaultconfig.cache_lifetime)

        if self.defaultconfig.verbose:
            self.defaultconfig.verbose = int(self.defaultconfig.verbose)

        #Copy the settings in argoptions into self.defaultconfig.
        self.defaultconfig, argoptions = utils.make_common_attr_equal(self.defaultconfig, argoptions)
        
        #Make sure files is in the correct format.
        if self.defaultconfig.files != files:
            self.defaultconfig.files = files

        return self.defaultconfig   
            
