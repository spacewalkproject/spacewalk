#!/usr/bin/python
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

import os

from config_common import cfg_exceptions, repository

# this is a bit odd; right now, we instantiate a regular
# repository.Repository object since it does a lot of local disk
# access for us.  In the future, though, it is unlikely Repository and
# ClientRepository classes/APIs will actually share this in common
# since Repository mostly requires user perms and ClientRepository
# mostly requires server perms

class ClientRepository:
    def __init__(self):
        self.server_repository = repository.Repository()
        tmp_channels = os.environ.get("RHNCFG_CHANNELS") or "all"

        # listed in order of losers first, ie, entry 2 overrides entry
        # 1, etc
        self.config_channels = tmp_channels.split(":")
        self.cfg_files = {}

    def list_files(self):
        # iterate over channels, accumulating hash of what files
        # come from where; subsequent entries override previous ones,
        # so the final hash is the result we seek

        if self.cfg_files:
            return self.cfg_files

        self.cfg_files = {}
        for ns in self.config_channels:
            for file in self.server_repository.list_files(ns):
                self.cfg_files[file] = [ ns, file ]

        return self.cfg_files

    def get_file(self, file):
        if not self.cfg_files:
            raise "never did a list_files"

        if file not in self.cfg_files:
            raise cfg_exceptions.ConfigNotManaged(file)

        return self.server_repository.get_file(self.cfg_files[file][0], self.cfg_files[file][1])

    def list_config_channels(self):
        return self.config_channels
