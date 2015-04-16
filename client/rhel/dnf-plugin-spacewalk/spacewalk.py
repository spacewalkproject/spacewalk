#
# Copyright (C) 2015  Red Hat, Inc.
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of
# the GNU General Public License v.2, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY expressed or implied, including the implied warranties of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
# Public License for more details.  You should have received a copy of the
# GNU General Public License along with this program; if not, write to the
# Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301, USA.  Any Red Hat trademarks that are incorporated in the
# source code or documentation are not subject to the GNU General Public
# License and may only be used or replicated with the express permission of
# Red Hat, Inc.
#

from __future__ import absolute_import
from __future__ import unicode_literals
from dnfpluginscore import _, logger

import dnf
import dnf.exceptions
import errno
import json
import os
import sys

# up2date libs are in non-standard path
sys.path.append("/usr/share/rhn/")
import up2date_client.up2dateAuth
import up2date_client.config
import up2date_client.rhnChannel
from up2date_client import up2dateErrors

STORED_CHANNELS_NAME = '_spacewalk.json'

RHN_DISABLED = _("Spacewalk based repositories will be disabled.")
COMMUNICATION_ERROR  = _("There was an error communicating with Spacewalk server.")
NOT_REGISTERED_ERROR = _("This system is not registered with Spacewalk server.")
NOT_SUBSCRIBED_ERROR = _("This system is not subscribed to any channels.")
NO_SYSTEM_ID_ERROR   = _("SystemId could not be acquired.")
USE_RHNREGISTER      = _("You can use rhn_register to register.")

class Spacewalk(dnf.Plugin):

    name = 'spacewalk'

    def __init__(self, base, cli):
        super(Spacewalk, self).__init__(base, cli)
        self.base = base
        self.cli = cli
        self.stored_channels_path = os.path.join(self.base.conf.persistdir,
                                                 STORED_CHANNELS_NAME)
        self.connected_to_spacewalk = False
        logger.debug('initialized Spacewalk plugin')


    def config(self):
        self.cli.demands.root_user = True

        enabled_channels = {}
        if not self.cli.demands.sack_activation:
            # no network communication, use list of channels from persistdir
            enabled_channels = self._read_channels_file()
        else:
            try:
                login_info = up2date_client.up2dateAuth.getLoginInfo()
            except up2dateErrors.RhnServerException as e:
                logger.error("%s\n%s\n%s", COMMUNICATION_ERROR, RHN_DISABLED,
                                           unicode(e))
                return

            if not login_info:
                logger.error("%s\n%s", NOT_REGISTERED_ERROR, RHN_DISABLED)
                self._write_channels_file({})
                return

            try:
                svrChannels = up2date_client.rhnChannel.getChannelDetails()
            except up2dateErrors.CommunicationError as e:
                logger.error("%s\n%s\n%s", COMMUNICATION_ERROR, RHN_DISABLED,
                                           unicode(e))
                return
            except up2dateErrors.NoChannelsError:
                logger.error("%s\n%s", NOT_SUBSCRIBED_ERROR, CHANNELS_DISABLED)
                self._write_channels_file({})
                return
            except up2dateErrors.NoSystemIdError:
                logger.error("%s %s\n%s\n%s", NOT_SUBSCRIBED_ERROR,
                             NO_SYSTEM_ID_ERROR, USE_RHNREGISTER, RHN_DISABLED)
                return
            self.connected_to_spacewalk = True

            for channel in svrChannels:
                if channel['version']:
                     enabled_channels[channel['label']] = {
                                        'name':   channel['name'],
                                        'gpgkey': channel['gpg_key_url'],
                           }
            self._write_channels_file(enabled_channels)

    def _read_channels_file(self):
        try:
            with open(self.stored_channels_path, "r") as channels_file:
                content = channels_file.read()
                return json.loads(content)
        except IOError as e:
            if e.errno != errno.ENOENT:
                raise

    def _write_channels_file(self, var):
        with open(self.stored_channels_path, "w") as channels_file:
            json.dump(var, channels_file, indent=4)
