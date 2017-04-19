# Copyright (c) 2017 Red Hat, Inc.
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
import tempfile

import requests

from spacewalk.cdn_tools.constants import CA_CERT_PATH
from spacewalk.common.cli import getUsernamePassword
from spacewalk.common.rhnConfig import CFG
from spacewalk.satellite_tools.syncLib import log, log2


class CandlepinApi(object):
    """Class used to communicate with Candlepin API."""

    def __init__(self, current_manifest=None, username=None, password=None,
                 http_proxy=None, http_proxy_username=None, http_proxy_password=None):
        self.base_url = current_manifest.get_api_url()
        if CFG.CANDLEPIN_SERVER_API:
            log(0, "Overriding Candlepin server to: '%s'" % CFG.CANDLEPIN_SERVER_API)
            self.base_url = CFG.CANDLEPIN_SERVER_API

        if self.base_url.startswith('https'):
            self.protocol = 'https'
        elif self.base_url.startswith('http'):
            self.protocol = 'http'
        else:
            raise ValueError("Invalid protocol in URL: '%s'" % self.base_url)

        if not self.base_url.endswith('/'):
            self.base_url += '/'

        self.current_manifest = current_manifest

        # Authentication with upstream consumer certificate or with username and password
        if self.current_manifest and self.protocol == 'https' and not username:
            self.username = self.password = None
        else:
            log(0, "Candlepin login:")
            self.username, self.password = getUsernamePassword(username, password)

        self.http_proxy = http_proxy
        self.http_proxy_username = http_proxy_username
        self.http_proxy_password = http_proxy_password

    def _get_proxies(self):
        proxies = {}
        if self.http_proxy:
            auth = ""
            if self.http_proxy_username and self.http_proxy_password:
                auth = "%s:%s@" % (self.http_proxy_username, self.http_proxy_password)
            proxy_string = "http://%s%s" % (auth, self.http_proxy)
            proxies["http"] = proxy_string
            proxies["https"] = proxy_string
        return proxies

    def _write_cert(self):
        cert = None
        if self.current_manifest:
            credentials = self.current_manifest.get_consumer_credentials()
            fd, cert_file = tempfile.mkstemp(prefix="/tmp/cert-")
            fo = os.fdopen(fd, 'wb')
            fo.write(credentials.get_cert())
            fo.flush()
            fo.close()

            fd, key_file = tempfile.mkstemp(prefix="/tmp/key-")
            fo = os.fdopen(fd, 'wb')
            fo.write(credentials.get_key())
            fo.flush()
            fo.close()
            cert = (cert_file, key_file)
        return cert

    @staticmethod
    def _delete_cert(cert):
        if cert is not None:
            cert_file, key_file = cert
            if cert_file:
                os.unlink(cert_file)
            if key_file:
                os.unlink(key_file)

    def _call_api(self, url, params=None, method="get"):
        if self.protocol == 'https':
            verify = CA_CERT_PATH
        else:
            verify = False

        response = None
        if self.username is not None and self.password is not None:
            try:
                if method == "get":
                    response = requests.get(url, params=params, proxies=self._get_proxies(),
                                            auth=(self.username, self.password), verify=verify)
                elif method == "put":
                    response = requests.put(url, params=params, proxies=self._get_proxies(),
                                            auth=(self.username, self.password), verify=verify)
                else:
                    raise ValueError("Unsupported method: '%s'" % method)
            except requests.RequestException:
                e = sys.exc_info()[1]
                log2(0, 0, "ERROR: %s" % str(e), stream=sys.stderr)
        else:
            cert = self._write_cert()
            try:
                try:
                    if method == "get":
                        response = requests.get(url, params=params, proxies=self._get_proxies(),
                                                verify=verify, cert=cert)
                    elif method == "put":
                        response = requests.put(url, params=params, proxies=self._get_proxies(),
                                                verify=verify, cert=cert)
                    else:
                        raise ValueError("Unsupported method: '%s'" % method)
                except requests.RequestException:
                    e = sys.exc_info()[1]
                    log2(0, 0, "ERROR: %s" % str(e), stream=sys.stderr)
            finally:
                self._delete_cert(cert)
        return response

    def export_manifest(self, uuid=None, ownerid=None, satellite_version=None):
        """Performs export request to Candlepin API and saves exported manifest to target file.
           Can take required parameters from current manifest or override them with parameters of this method."""
        if uuid is None:
            if self.current_manifest:
                uuid = self.current_manifest.get_uuid()
            else:
                raise ValueError("Uuid is not known.")
        if ownerid is None:
            if self.current_manifest:
                ownerid = self.current_manifest.get_ownerid()
            else:
                raise ValueError("Ownerid is not known.")
        if satellite_version is None:
            if self.current_manifest:
                satellite_version = self.current_manifest.get_satellite_version()
            else:
                raise ValueError("Satellite version is not known.")

        url = "%s%s/export" % (self.base_url, uuid)
        params = {"ext": ["ownerid:%s" % ownerid, "version:%s" % satellite_version]}

        log(1, "URL: '%s'" % url)
        log(1, "Parameters: '%s'" % str(params))

        response = self._call_api(url, params=params, method="get")

        if response is not None:
            # pylint: disable=E1101
            if response.status_code == requests.codes.ok:
                fd, downloaded_manifest = tempfile.mkstemp(prefix="/tmp/manifest-", suffix=".zip")
                fo = os.fdopen(fd, 'wb')
                for chunk in response:
                    fo.write(chunk)
                fo.flush()
                fo.close()
                return downloaded_manifest
            else:
                log2(0, 0, "Status code: %s" % response.status_code, stream=sys.stderr)
                log2(0, 0, "Message: '%s'" % response.text, stream=sys.stderr)

        return None

    def refresh_manifest(self, uuid=None):
        if uuid is None:
            if self.current_manifest:
                uuid = self.current_manifest.get_uuid()
            else:
                raise ValueError("Uuid is not known.")

        url = "%s%s/certificates" % (self.base_url, uuid)

        log(1, "URL: '%s'" % url)

        response = self._call_api(url, method="put")

        if response is not None:
            # pylint: disable=E1101
            if response.status_code == requests.codes.ok or response.status_code == requests.codes.no_content:
                return True
            else:
                log2(0, 0, "Status code: %s" % response.status_code, stream=sys.stderr)
                log2(0, 0, "Message: '%s'" % response.text, stream=sys.stderr)

        return False
