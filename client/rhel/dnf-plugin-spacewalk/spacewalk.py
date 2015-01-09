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
PLUGIN_CONF = 'spacewalk.conf'

RHN_DISABLED    = _("Spacewalk based repositories will be disabled.")
COMMUNICATION_ERROR  = _("There was an error communicating with Spacewalk server.")
NOT_REGISTERED_ERROR = _("This system is not registered with Spacewalk server.")
NOT_SUBSCRIBED_ERROR = _("This system is not subscribed to any channels.")
NO_SYSTEM_ID_ERROR   = _("SystemId could not be acquired.")
USE_RHNREGISTER      = _("You can use rhn_register to register.")
UPDATES_FROM_SPACEWALK = _("This system is receiving updates from Spacewalk server.")
GPG_KEY_REJECTED     =  _("For security reasons packages from Spacewalk based repositories can be verified only with locally installed gpg keys. GPG key '%s' has been rejected.")


class Spacewalk(dnf.Plugin):

    name = 'spacewalk'

    def __init__(self, base, cli):
        super(Spacewalk, self).__init__(base, cli)
        self.base = base
        self.cli = cli
        self.stored_channels_path = os.path.join(self.base.conf.persistdir,
                                                 STORED_CHANNELS_NAME)
        self.connected_to_spacewalk = False
        self.conf = dnf.conf.Conf()
        self.read_config(self.conf, PLUGIN_CONF)
        logger.debug('initialized Spacewalk plugin')


    def config(self):
        self.cli.demands.root_user = True

        enabled_channels = {}
        sslcacert = None
        force_http = 0
        proxy_url = None
        # set timeout according to config once BZ#1175466 is fixed
        timeout = 300
        import pdb; pdb.set_trace()
        cached_channels = self._read_channels_file()
        if not self.cli.demands.sack_activation:
            # no network communication, use list of channels from persistdir
            enabled_channels = cached_channels
        else:
            # setup proxy according to up2date
            up2date_cfg = up2date_client.config.initUp2dateConfig()
            sslcacert = get_ssl_ca_cert(up2date_cfg)
            force_http = up2date_cfg['useNoSSLForPackages'],

            try:
                login_info = up2date_client.up2dateAuth.getLoginInfo(timeout=timeout)
            except up2dateErrors.RhnServerException as e:
                logger.error("%s\n%s\n%s", COMMUNICATION_ERROR, RHN_DISABLED,
                                           unicode(e))
                return

            if not login_info:
                logger.error("%s\n%s", NOT_REGISTERED_ERROR, RHN_DISABLED)
                self._write_channels_file({})
                return

            try:
                svrChannels = up2date_client.rhnChannel.getChannelDetails(
                                                              timeout=timeout)
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
            logger.info(UPDATES_FROM_SPACEWALK)

            for channel in svrChannels:
                if channel['version']:
                     enabled_channels[channel['label']] = dict(channel.items())
            self._write_channels_file(enabled_channels)

        repos = self.base.repos

        for (channel_id, channel_dict) in enabled_channels.iteritems():
            cached_channel = cached_channels.get(channel_id)
            cached_version = None
            if cached_channel:
                cached_version = cached_channel.get('version')
            repo = SpacewalkRepo(channel_dict, {
                                    'cachedir'  : self.base.conf.cachedir,
                                    'proxy'     : proxy_url,
                                    'timeout'   : timeout,
                                    'sslcacert' : sslcacert,
                                    'force_http': force_http,
                                    'cached_version' : cached_version,
                                })
            repos.add(repo)

        # DEBUG
        logger.debug(enabled_channels)


    def _read_channels_file(self):
        try:
            with open(self.stored_channels_path, "r") as channels_file:
                content = channels_file.read()
                channels = json.loads(content)
                return channels
        except IOError as e:
            if e.errno != errno.ENOENT:
                raise
        return {}

    def _write_channels_file(self, var):
        with open(self.stored_channels_path, "w") as channels_file:
            json.dump(var, channels_file, indent=4)

class  SpacewalkRepo(dnf.repo.Repo):
    """
    Repository object for Spacewalk. Uses up2date libraries.
    """
    needed_headers = ['X-RHN-Server-Id',
                      'X-RHN-Auth-User-Id',
                      'X-RHN-Auth',
                      'X-RHN-Auth-Server-Time',
                      'X-RHN-Auth-Expire-Offset']

    def __init__(self, channel, opts):
        super(SpacewalkRepo, self).__init__(unicode(channel['label']),
                                            opts.get('cachedir'))
        # dnf stuff
        self.name = unicode(channel['name'])
        self.baseurl = [ url + '/GET-REQ/' + self.id for url in channel['url']]
        self.sslcacert = opts.get('sslcacert')
        self.proxy = opts.get('proxy')
        try:
            self.gpgkey = get_gpg_key_urls(channel['gpg_key_url'])
        except InvalidGpgKeyLocation as e:
            logger.warn(GPG_KEY_REJECTED, e.msg)
            self.gpgkey = []
        if channel['version'] != opts.get('cached_version'):
            self.metadata_expire = 1

        # spacewalk stuff
        self.keepalive = 0
        self.bandwidth = 0
        self.retries = 1
        self.throttle = 0
        self.timeout = opts.get('timeout')
        self.force_http = opts.get('force_http')

        self.enable()

    def summary_dict(self):
        return {
                'name':    self.name,
                'baseurl': self.baseurl,
                'gpgkey':  self.gpgkey,
                }


# FIXME
# all rutines bellow should go to rhn-client-tools because they are share
# between yum-rhn-plugin and dnf-plugin-spacewalk
def get_gpg_key_urls(key_url_string):
    """
    Parse the key urls and validate them.

    key_url_string is a space seperated list of gpg key urls that must be
    located in /etc/pkg/rpm-gpg/.
    Return a list of strings containing the key urls.
    Raises InvalidGpgKeyLocation if any of the key urls are invalid.
    """
    key_urls = key_url_string.split()
    for key_url in key_urls:
        if not is_valid_gpg_key_url(key_url):
            raise InvalidGpgKeyLocation(key_url)
    return key_urls

def is_valid_gpg_key_url(key_url):
    proto_split = key_url.split('://')
    if len(proto_split) != 2:
        return False

    proto, path = proto_split
    if proto.lower() != 'file':
        return False

    path = os.path.normpath(path)
    if not path.startswith('/etc/pki/rpm-gpg/'):
        return False
    return True

def get_ssl_ca_cert(up2date_cfg):
    if not (up2date_cfg.has_key('sslCACert') and up2date_cfg['sslCACert']):
        raise BadSslCaCertConfig

    ca_certs = up2date_cfg['sslCACert']
    if type(ca_certs) == list:
        return ca_certs[0]

    return ca_certs
