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
import librepo
import os
import sys
from copy import copy

# up2date libs are in non-standard path
sys.path.append("/usr/share/rhn/")
import up2date_client.up2dateAuth
import up2date_client.config
import up2date_client.rhnChannel
import up2date_client.rhnPackageInfo
from up2date_client import up2dateErrors

STORED_CHANNELS_NAME = '_spacewalk.json'
PLUGIN_CONF = 'spacewalk'

RHN_DISABLED    = _("Spacewalk based repositories will be disabled.")
CHANNELS_DISABLED = _("Spacewalk channel support will be disabled.")
COMMUNICATION_ERROR  = _("There was an error communicating with Spacewalk server.")
NOT_REGISTERED_ERROR = _("This system is not registered with Spacewalk server.")
NOT_SUBSCRIBED_ERROR = _("This system is not subscribed to any channels.")
NO_SYSTEM_ID_ERROR   = _("SystemId could not be acquired.")
USE_RHNREGISTER      = _("You can use rhn_register to register.")
UPDATES_FROM_SPACEWALK = _("This system is receiving updates from Spacewalk server.")
GPG_KEY_REJECTED     = _("For security reasons packages from Spacewalk based repositories can be verified only with locally installed gpg keys. GPG key '%s' has been rejected.")
PROFILE_NOT_SENT     = _("Package profile information could not be sent.")
MISSING_HEADER       = _("Missing required login information for Spacewalk: %s")

class Spacewalk(dnf.Plugin):

    name = 'spacewalk'

    def __init__(self, base, cli):
        super(Spacewalk, self).__init__(base, cli)
        self.base = base
        self.cli = cli
        self.stored_channels_path = os.path.join(self.base.conf.persistdir,
                                                 STORED_CHANNELS_NAME)
        self.connected_to_spacewalk = False
        self.up2date_cfg = {}
        self.conf = copy(self.base.conf)
        self.parser = self.read_config(self.conf, PLUGIN_CONF)
        if "main" in self.parser.sections():
            options = self.parser.items("main")
            for (key, value) in options:
                setattr(self.conf, key, value)
        if not self.conf.enabled:
            return
        logger.debug('initialized Spacewalk plugin')

    def config(self):
        if not self.conf.enabled:
            return
        self.cli.demands.root_user = True

        self.activate_channels(self.cli.demands.sack_activation)

    def activate_channels(self, networking=True):
        enabled_channels = {}
        sslcacert = None
        force_http = 0
        proxy_url = None
        login_info = None
        cached_channels = self._read_channels_file()
        if not networking:
            # no network communication, use list of channels from persistdir
            enabled_channels = cached_channels
        else:
            # setup proxy according to up2date
            self.up2date_cfg = up2date_client.config.initUp2dateConfig()
            sslcacert = get_ssl_ca_cert(self.up2date_cfg)
            force_http = self.up2date_cfg['useNoSSLForPackages'],

            try:
                login_info = up2date_client.up2dateAuth.getLoginInfo(timeout=self.conf.timeout)
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
                                                              timeout=self.conf.timeout)
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
            conf = copy(self.conf)
            if channel_id in self.parser.sections():
                options = self.parser.items(channel_id)
                for (key, value) in options:
                    setattr(conf, key, value)
            repo = SpacewalkRepo(channel_dict, {
                                    'cachedir'  : self.base.conf.cachedir,
                                    'proxy'     : proxy_url,
                                    'timeout'   : conf.timeout,
                                    'sslcacert' : sslcacert,
                                    'force_http': force_http,
                                    'cached_version' : cached_version,
                                    'login_info': login_info,
                                    'gpgcheck': conf.gpgcheck,
                                    'enabled': conf.enabled,
                                })
            repos.add(repo)

        # DEBUG
        logger.debug(enabled_channels)

    def transaction(self):
        """ Update system's profile after transaction. """
        if not self.conf.enabled:
            return
        if not self.connected_to_spacewalk:
            # not connected so nothing to do here
            return
        if self.up2date_cfg['writeChangesToLog'] == 1:
            delta = self._make_package_delta()
            up2date_client.rhnPackageInfo.logDeltaPackages(delta)
        try:
            up2date_client.rhnPackageInfo.updatePackageProfile(
                                                        timeout=self.conf.timeout)
        except up2dateErrors.RhnServerException as e:
            logger.error("%s\n%s\n%s", COMMUNICATION_ERROR, PROFILE_NOT_SENT,
                                       unicode(e))


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

    def _make_package_delta(self):
        delta = {'added'  : [(p.name, p.version, p. release, p.epoch, p.arch)
                                for p in self.base.transaction.install_set],
                 'removed': [(p.name, p.version, p. release, p.epoch, p.arch)
                                for p in self.base.transaction.remove_set],
                }
        return delta


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
            logger.warn(GPG_KEY_REJECTED, dnf.i18n.ucd(e))
            self.gpgkey = []
        if channel['version'] != opts.get('cached_version'):
            self.metadata_expire = 1

        # spacewalk stuff
        self.login_info = opts.get('login_info')
        self.keepalive = 0
        self.bandwidth = 0
        self.retries = 1
        self.throttle = 0
        self.timeout = opts.get('timeout')
        self.gpgcheck = opts.get('gpgcheck')
        self.force_http = opts.get('force_http')

        if opts.get('enabled'):
            self.enable()
        else:
            self.disable()

    def add_http_headers(self, handle):
        http_headers = []
        for header in self.needed_headers:
            if not self.login_info.has_key(header):
                error = MISSING_HEADER % header
                raise dnf.Error.RepoError(error)
            if self.login_info[header] in (None, ''):
                # This doesn't work due to bug in librepo (or even deeper in libcurl)
                # the workaround bellow can be removed once BZ#1211662 is fixed
                #http_headers.append("%s;" % header)
                http_headers.append("%s: \nX-libcurl-Empty-Header-Workaround: *" % header)
            else:
                http_headers.append("%s: %s" % (header, self.login_info[header]))
        if not self.force_http:
            http_headers.append("X-RHN-Transport-Capability: follow-redirects=3")
        if http_headers:
            handle.setopt(librepo.LRO_HTTPHEADER, http_headers)

    def _handle_new_remote(self, destdir, mirror_setup=True):
        handle = super(SpacewalkRepo, self)._handle_new_remote(destdir, mirror_setup)
        self.add_http_headers(handle)
        return handle


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

class InvalidGpgKeyLocation(Exception):
    pass

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
