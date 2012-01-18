#!/usr/bin/python
#
# Clonse channels by a particular date
#
# Copyright (c) 2008 Red Hat, Inc.
#
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

import pdb
import json
from optparse import OptionParser



def main():    
    options = merge_config(parse_args());
    
   
def merge_config(options):
    if not options.config:
        options.channels = transform_arg_channels(options.channels)
        return options
    config = json.load(open(options.config))
    
    #if soemthing is in the config and not passed in as an argument
    #   add it to options
    overwrite = ["username", "password", "blacklist", "channels"]
    for key in overwrite:
        if config.has_key(key) and not getattr(options, key):
            setattr(options, key, config[key])
        
    if type(options.channels) == dict:
        options.channels =  [options.channels] 
    return options
   
      
# Using --channels as an argument only supports a single channel 'tree'
#  So we need to convert a 2-tuple list of channel labels into an array with a hash
#  ex:   [ ("rhel-i386-servr-5", "my-rhel-clone"), ('rhel-child', 'clone-child')]
#    should become
# [{
#  "rhel-i386-servr-5" : "my-rhel-clone",
#  'rhel-child': 'clone-child'
#  }]
def transform_arg_channels(chan_list):
    to_ret = {}
    for src, dest in chan_list:
        to_ret[src] = dest
    return [to_ret]   
        
def parse_args():
    parser = OptionParser()
    parser.add_option("-c", "--config", dest="config", help="Config file specifying options")
    parser.add_option("-u", "--username", dest="username", help="Username")
    parser.add_option("-p", "--password", dest="password", help="Password")
    parser.add_option("-l", "--channels", dest="channels", nargs=2, action="append", help="Origianl channel and clone channel labels space seperated (e.g. --channels=rhel-i386-server-5 myclone)")
    parser.add_option("-b", "--blacklist", dest="blacklist", nargs="*", help="Space seperated list of package names")
    (options, args) = parser.parse_args()

    if options.config and options.channels:
        raise Exception("Cannot specify both --channels and --config.")
    
    return options
    