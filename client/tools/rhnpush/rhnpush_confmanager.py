#
# Copyright (c) 2008--2016 Red Hat, Inc.
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

import sys
import os
from rhnpush import rhnpush_config
from rhnpush import utils


class ConfManager:

    def __init__(self, optionparser, store_true_list):
        sysdir = '/etc/sysconfig/rhn'
        homedir = utils.get_home_dir()
        default = 'rhnpushrc'
        regular = '.rhnpushrc'
        deffile = os.path.join(sysdir, default)
        regfile = os.path.join(homedir, regular)
        cwdfile = os.path.join(os.getcwd(), regular)

        self.cfgFileList = [deffile, regfile, cwdfile]
        self.defaultconfig = rhnpush_config.rhnpushConfigParser(ensure_consistency=True)

        # Get a reference to the object containing command-line options
        self.cmdconfig = optionparser
        self.store_true_list = store_true_list

    # Change the files options of the self.userconfig
    # Change the exclude options of the self.userconfig
    def _files_to_list(self):
        # Change the files options to lists.
        if ('files' in self.defaultconfig.__dict__ and
                not isinstance(self.defaultconfig.files, type([]))):
            self.defaultconfig.files = [x.strip() for x in
                                        self.defaultconfig.files.split(',')]

        # Change the exclude options to list.
        if ('exclude' in self.defaultconfig.__dict__ and
                not isinstance(self.defaultconfig.__dict__['exclude'], type([]))):
            self.defaultconfig.exclude = [x.strip() for x in
                                          self.defaultconfig.exclude.split(',')]

    def get_config(self):
        for f in self.cfgFileList:
            if os.access(f, os.F_OK):
                if not os.access(f, os.R_OK):
                    print(("rhnpush does not have read permission on %s" % f))
                    sys.exit(1)
                config2 = rhnpush_config.rhnpushConfigParser(f)
                self.defaultconfig, config2 = utils.make_common_attr_equal(self.defaultconfig, config2)

        self._files_to_list()

        # Change the channel string into a list of strings.
        # pylint: disable=E1103
        if not self.defaultconfig.channel:
            # if no channel then make it null array instead of
            # an empty string array from of size 1 [''] .
            self.defaultconfig.channel = []
        else:
            self.defaultconfig.channel = [x.strip() for x in
                                          self.defaultconfig.channel.split(',')]

        # Get the command line arguments. These take precedence over the other settings
        argoptions, files = self.cmdconfig.parse_args()

        # Makes self.defaultconfig compatible with argoptions by changing all '0' value attributes to None.
        _zero_to_none(self.defaultconfig, self.store_true_list)

        # If verbose isn't set at the command-line, it automatically gets set to zero. If it's at zero, change it to
        # None so the settings in the config files take precedence.
        if argoptions.verbose == 0:
            argoptions.verbose = None

        # Orgid, count, cache_lifetime, and verbose all need to be integers, just like in argoptions.
        if self.defaultconfig.orgid:
            self.defaultconfig.orgid = int(self.defaultconfig.orgid)

        if self.defaultconfig.count:
            self.defaultconfig.count = int(self.defaultconfig.count)

        if self.defaultconfig.cache_lifetime:
            self.defaultconfig.cache_lifetime = int(self.defaultconfig.cache_lifetime)

        if self.defaultconfig.verbose:
            self.defaultconfig.verbose = int(self.defaultconfig.verbose)

        if self.defaultconfig.timeout:
            self.defaultconfig.timeout = int(self.defaultconfig.timeout)

        # Copy the settings in argoptions into self.defaultconfig.
        self.defaultconfig, argoptions = utils.make_common_attr_equal(self.defaultconfig, argoptions)

        # Make sure files is in the correct format.
        if self.defaultconfig.files != files:
            self.defaultconfig.files = files

        return self.defaultconfig


# Changes every option in config that is also in store_true_list that is set to '0' to None
def _zero_to_none(config, store_true_list):
    for opt in config.keys():
        for cmd in store_true_list:
            if str(opt) == cmd and config.__dict__[opt] == '0':
                config.__dict__[opt] = None
