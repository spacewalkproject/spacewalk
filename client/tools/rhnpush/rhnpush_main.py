#
# Copyright (c) 2008--2017 Red Hat, Inc.
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
"""
Management tool for the Spacewalk Proxy.

This script performs various management operations on the Spacewalk Proxy:
- Creates the local directory structure needed to store local packages
- Uploads packages from a given directory to the RHN servers
- Optionally, once the packages are uploaded, they can be linked to (one or
  more) channels, and copied in the local directories for these channels.
- Lists the RHN server's vision on a certain channel
- Checks if the local image of the channel (the local directory) is in sync
  with the server's image, and prints the missing packages (or the extra
  ones)
"""

import os
import random
import sys
import time
# pylint: disable=W0402
from optparse import Option, OptionParser

# pylint: disable=F0401,E0611
from rhn.connections import idn_ascii_to_puny

from rhn import rpclib
from rhn.i18n import sstr
from spacewalk.common.rhn_pkg import InvalidPackageError, package_from_filename
from spacewalk.common.usix import raise_with_tb

from rhnpush.utils import tupleify_urlparse
from rhnpush import rhnpush_confmanager, uploadLib, rhnpush_v2

if sys.version_info[0] == 3:
    import urllib.parse as urlparse
else:
    import urlparse

# Global settings
BUFFER_SIZE = 65536
HEADERS_PER_CALL = 10
DEBUG = 0
RPMTAG_NOSOURCE = 1051


def main():
    # Initialize a command-line processing object with a table of options
    optionsTable = [
        Option('-v', '--verbose', action='count', help='Increase verbosity',
               default=0),
        Option('-d', '--dir', action='store',
               help='Process packages from this directory'),
        Option('-c', '--channel', action='append',
               help='Manage this channel (specified by label)'),
        Option('-n', '--count', action='store',
               help='Process this number of headers per call', type='int'),
        Option('-l', '--list', action='store_true',
               help='Only list the specified channels'),
        Option('-r', '--reldir', action='store',
               help='Relative dir to associate with the file'),
        Option('-o', '--orgid', action='store',
               help='Org ID', type='int'),
        Option('-u', '--username', action='store',
               help='Use this username to connect to RHN/Satellite'),
        Option('-p', '--password', action='store',
               help='Use this password to connect to RHN/Satellite'),
        Option('-s', '--stdin', action='store_true',
               help='Read the package names from stdin'),
        Option('-X', '--exclude', action='append',
               help='Exclude packages that match this glob expression'),
        Option('--force', action='store_true',
               help='Force the package upload (overwrites if already uploaded)'),
        Option('--nosig', action='store_true', help='Push unsigned packages'),
        Option('--newest', action='store_true',
               help='Only push the packages that are newer than the server ones'),
        Option('--nullorg', action='store_true', help='Use the null org id'),
        Option('--header', action='store_true',
               help='Upload only the header(s)'),
        Option('--source', action='store_true',
               help='Upload source package information'),
        Option('--server', action='store',
               help='Push to this server (http[s]://<hostname>/APP)'),
        Option('--proxy', action='store',
               help='Use proxy server (<server>:<port>)'),
        Option('--test', action='store_true',
               help='Only print the packages to be pushed'),
        Option('-?', '--usage', action='store_true',
               help='Briefly describe the options'),
        Option('-N', '--new-cache', action='store_true',
               help='Create a new username/password cache'),
        Option('--extended-test', action='store_true',
               help='Perform a more verbose test'),
        Option('--no-session-caching', action='store_true',
               help='Disables session-token authentication.'),
        Option('--tolerant', action='store_true',
               help='If rhnpush errors while uploading a package, continue uploading the rest of the packages.'),
        Option('--ca-chain', action='store', help='alternative SSL CA Cert'),
        Option('--timeout', action='store', type='int', metavar='SECONDS',
               help='Change default connection timeout.')
    ]

    # Having to maintain a store_true list is ugly. I'm trying to get rid of this.
    true_list = ['usage', 'test', 'source', 'header', 'nullorg', 'newest',
                 'nosig', 'force', 'list', 'stdin', 'new_cache',
                 'extended_test', 'no_session_caching', 'tolerant']
    # pylint: disable=E1101,E1103
    optionParser = OptionParser(option_list=optionsTable, usage="%prog [OPTION] [<package>]")
    manager = rhnpush_confmanager.ConfManager(optionParser, true_list)
    options = manager.get_config()

    upload = UploadClass(options, files=options.files)

    if options.usage:
        optionParser.print_usage()
        sys.exit(0)

    if options.proxy:
        options.proxy = idn_ascii_to_puny(options.proxy)

    if options.list:
        if not options.channel:
            upload.die(1, "Must specify a channel for --list to work")
        upload.list()
        return

    if options.dir and not options.stdin:
        upload.directory()

    elif options.stdin and not options.dir:
        upload.readStdin()

    elif options.dir and options.stdin:
        upload.readStdin()
        upload.directory()

    if options.exclude:
        upload.filter_excludes()

    if options.newest:
        if not options.channel:
            upload.die(1, "Must specify a channel for --newest to work")

        upload.newest()

    if not upload.files:
        if upload.newest:
            print("No new files to upload; exiting")
        else:
            print("Nothing to do (try --help for more options)")
        sys.exit(0)

    if options.test:
        upload.test()
        return

    if options.extended_test:
        upload.extended_test()
        return

    if options.header:
        upload.uploadHeaders()
        return

    ret = upload.packages()
    if ret != 0:
        return 1


class UploadClass(uploadLib.UploadClass):
    # pylint: disable=E1101,W0201,W0632

    def __init__(self, options, files=None):
        uploadLib.UploadClass.__init__(self, options, files)
        self.url_v2 = None

    def setURL(self):
        server = sstr(idn_ascii_to_puny(self.options.server))
        if server is None:
            self.die(1, "Required parameter --server not supplied")
        scheme, netloc, path, params, query, fragment = tupleify_urlparse(
            urlparse.urlparse(server))
        if not netloc:
            # No schema - trying to patch it up ourselves?
            server = "http://%s" % server
            scheme, netloc, path, params, query, fragment = tupleify_urlparse(
                urlparse.urlparse(server))

        if not netloc:
            self.die(2, "Invalid URL %s" % server)
        if path == '':
            path = '/APP'
        if scheme.lower() not in ('http', 'https'):
            self.die(3, "Unknown URL scheme %s" % scheme)
        self.url = urlparse.urlunparse((scheme, netloc, path, params, query,
                                        fragment))
        self.url_v2 = urlparse.urlunparse((scheme, netloc, "/PACKAGE-PUSH",
                                           params, query, fragment))

    def setOrg(self):
        if self.options.nullorg:
            if self.options.force:
                self.die(1, "ERROR: You cannot force a package to a nullorg channel.")
            else:
                # They push things to the None org id
                self.orgId = ''
        else:
            self.orgId = self.options.orgid or -1

    def setForce(self):
        if self.options.force:
            self.force = 4
        else:
            self.force = None

    def setRelativeDir(self):
        self.relativeDir = self.options.reldir

    def setChannels(self):
        self.channels = self.options.channel or []

    # pylint: disable=W0702
    def _test_force(self):
        test_force_str = "Setting force flag:  %s"
        test_force = "Passed"
        try:
            self.setForce()
        except:
            test_force = "Failed"
        print(test_force_str % test_force)

    def _test_set_org(self):
        test_set_org_str = "Setting the org:    %s"
        test_set_org = "Passed"
        try:
            self.setOrg()
        except:
            test_set_org = "Failed"
        print(test_set_org_str % test_set_org)

    def _test_set_url(self):
        test_set_url_str = "Setting the URL:    %s"
        test_set_url = "Passed"
        try:
            self.setURL()
        except:
            test_set_url = "Failed"
        print(test_set_url_str % test_set_url)

    def _test_set_channels(self):
        test_set_channels_str = "Setting the channels:  %s"
        test_set_channels = "Passed"
        try:
            self.setChannels()
        except:
            test_set_channels = "Failed"
        print(test_set_channels_str % test_set_channels)

    def _test_username_password(self):
        test_user_pass_str = "Setting the username and password:    %s"
        test_user_pass = "Passed"
        try:
            self.setUsernamePassword()
        except:
            test_user_pass = "Failed"
        print(test_user_pass_str % test_user_pass)

    def _test_set_server(self):
        test_set_server_str = "Setting the server:  %s"
        test_set_server = "Passed"
        try:
            self.setServer()
        except:
            test_set_server = "Failed"
        print(test_set_server_str % test_set_server)

    def _test_connect(self):
        auth_ret = uploadLib.call(self.server.packages.test_login,
                                  self.username, self.password)
        if auth_ret == 1:
            test_auth = "Passed"
        else:
            test_auth = "Failed"
        print("Testing connection and authentication:   %s" % test_auth)

    def _test_access(self):
        access_ret = callable(self.server.packages.channelPackageSubscriptionBySession)

        if access_ret == 1:
            test_access = "Passed"
        else:
            test_access = "Failed"
        print("Testing access to upload functionality on server:    %s" % test_access)

    # 12/22/05 wregglej 173287  Added a this funtion to test the new session authentication stuff.
    # It still needs work.
    def _test_authenticate(self):
        self.authenticate()

    def extended_test(self):
        self._test_force()
        self._test_set_org()
        self._test_set_url()
        self._test_set_channels()
        self._test_username_password()
        self._test_set_server()
        self._test_connect()
        self._test_access()
        print("The files that would have been pushed:")
        self.test()

    def packages(self):
        self.setForce()
        # set the org
        self.setOrg()
        # set the URL
        self.setURL()
        # set the channels
        self.setChannels()
        # set the server
        self.setServer()
        # 12/22/05 wregglej 173287 authenticate the session.
        self.authenticate()

        # Do we have the new-style handler available?

        # ping the server for status
        self.warn(2, "url is", self.url_v2)
        ping = rhnpush_v2.PingPackageUpload(self.url_v2, self.options.proxy)
        ping_status, errmsg, headerinfo = ping.ping()
        self.warn(2, "Result codes:", ping_status, errmsg)

        # move patch clusters to the end because all the patches in the cluster
        # have to be pushed before the cluster itself
        files1 = []
        files2 = []
        for filename in self.files:
            if filename.startswith('patch-cluster-'):
                files2.append(filename)
            else:
                files1.append(filename)

        self.files = files1 + files2

        channel_packages = []

        # a little fault tolarence is in order
        random.seed()
        tries = 3

        # satellites < 4.1.0 are no more supported
        if sys.version_info[0] == 3:
            pack_exist_check = headerinfo.get('X-RHN-Check-Package-Exists')
        else:
            pack_exist_check = headerinfo.getheader('X-RHN-Check-Package-Exists')
        if not pack_exist_check:
            self.die(-1, "Pushing to Satellite < 4.1.0 is not supported.")

        (server_digest_hash, pkgs_info, digest_hash) = self.check_package_exists()

        for pkg in self.files:
            ret = None  # pkilambi:errors off as not initialized.this fixes it.

            # temporary fix for picking pkgs instead of full paths
            pkg_key = (pkg.strip()).split('/')[-1]

            if pkg_key not in server_digest_hash:
                continue

            checksum_type, checksum = digest = digest_hash[pkg_key]
            server_digest = tuple(server_digest_hash[pkg_key])

            # compare checksums for existance check
            if server_digest == digest and not self.options.force:
                channel_packages.append(pkgs_info[pkg_key])
                self.warn(1, "Package %s already exists on the RHN Server-- Skipping Upload...." % pkg)
                continue

            elif server_digest == ():
                self.warn(1, "Package %s Not Found on RHN Server -- Uploading" % pkg)

            elif server_digest == "on-disk" and not self.options.force:
                channel_packages.append(pkgs_info[pkg_key])
                self.warn(0, "Package on disk but not on db -- Skipping Upload " % pkg)
                continue

            elif server_digest != digest:
                if self.options.force:
                    self.warn(1, "Package checksum %s mismatch  -- Forcing Upload" % pkg)
                else:
                    msg = "Error: Package %s already exists on the server with" \
                          " a different checksum. Skipping upload to prevent" \
                          " overwriting existing package. (You may use rhnpush with" \
                          " the --force option to force this upload if the" \
                          " force_upload option is enabled on your server.)\n" % pkg
                    if not self.options.tolerant:
                        self.die(-1, msg)
                    self.warn(0, msg)
                    continue

            for _t in range(0, tries):
                try:
                    ret = self.package(pkg, checksum_type, checksum)
                    if ret is None:
                        raise uploadLib.UploadError()

                # TODO:  Revisit this.  We throw this error all over the place,
                #        but doing so will cause us to skip the --tolerant logic
                #        below.  I don't think we really want this behavior.
                #        There are some cases where we don't want to retry 3
                #        times, but not at the expense of disabling the tolerant
                #        flag, IMHO.  This loop needs some lovin'.  -- pav

                # FIX: it checks for tolerant flag and aborts only if the flag is
                #not specified
                except uploadLib.UploadError:
                    ue = sys.exc_info()[1]
                    if not self.options.tolerant:
                        self.die(1, ue)
                    self.warn(2, ue)
                except AuthenticationRequired:
                    # session expired so we re-authenticate for the process to complete
                    # this uses the username and password from memory if available
                    # else it prompts for one.
                    self.authenticate()
                except:
                    self.warn(2, sys.exc_info()[1])
                    wait = random.randint(1, 5)
                    self.warn(0, "Waiting %d seconds and trying again..." % wait)
                    time.sleep(wait)
                # The else clause gets executed in the stuff in the try-except block *succeeds*.
                else:
                    break

            # if the preceeding for-loop exits without a call to break, then this else clause gets called.
            # What's kind of weird is that if the preceeding for-loop doesn't call break then an error occurred
            # and all of retry attempts failed. If the for-loop *does* call break then everything is hunky-dory.
            # In short, this else clause only get's called if something is F.U.B.A.R and the retry attempts don't
            # fix anything.
            else:
                if not self.options.tolerant:
                    # pkilambi:bug#176358:this exits with a error code of 1
                    self.die(1, "Giving up after %d attempts" % tries)
                else:
                    print("Giving up after %d attempts and continuing on..." % (tries,))

            # 5/13/05 wregglej - 154248 ?? we still want to add the packages if they're source.
            if ret and self.channels:  # and ret['arch'] != 'src':
                # Don't bother to add the package if
                # no channel was specified or a source rpm was passed
                channel_packages.append(ret)

        # self.channels is never None, it always has at least one entry with an empty string.
        if len(self.channels) == 1 and self.channels[0] == '':
            return
        info = {
            'packages': channel_packages,
            'channels': self.channels
        }
        if self.orgId == '' or self.orgId > 0:
            info['orgId'] = self.orgId

        # 2/3/06 wregglej 173287 Added check to see if we can use session tokens.
        if channel_packages:
            self.authenticate()
            uploadLib.call(self.server.packages.channelPackageSubscriptionBySession,
                           self.session.getSessionString(), info)
        return 0

    # does an existance check of the packages to be uploaded and returns their checksum and other info
    def check_package_exists(self):
        self.warn(2, "Computing checksum and package info. This may take some time ...")
        pkg_hash = {}
        digest_hash = {}

        for pkg in self.files:
            pkg_info = {}
            pkg_key = (pkg.strip()).split('/')[-1]

            if not os.access(pkg, os.R_OK):
                if not self.options.tolerant:
                    self.die(-1, "Could not read file %s" % pkg)
                self.warn(-1, "Could not read file %s" % pkg)
                continue
            try:
                a_pkg = package_from_filename(pkg)
                a_pkg.read_header()
                a_pkg.payload_checksum()
            except InvalidPackageError:
                if not self.options.tolerant:
                    self.die(-1, "ERROR: %s: This file doesn't appear to be a package" % pkg)
                self.warn(2, "ERROR: %s: This file doesn't appear to be a package" % pkg)
                continue
            except IOError:
                if not self.options.tolerant:
                    self.die(-1, "ERROR: %s: No such file or directory available" % pkg)
                self.warn(2, "ERROR: %s: No such file or directory available" % pkg)
                continue

            digest_hash[pkg_key] = (a_pkg.checksum_type, a_pkg.checksum)
            a_pkg.input_stream.close()

            for tag in ('name', 'version', 'release', 'epoch', 'arch'):
                val = a_pkg.header[tag]
                if val is None:
                    val = ''
                pkg_info[tag] = val
            # b195903:the arch for srpms should be obtained by is_source check
            # instead of checking arch in header
            if a_pkg.header.is_source:
                if not self.options.source:
                    self.die(-1, "ERROR: Trying to Push src rpm, Please re-try with --source.")
                if RPMTAG_NOSOURCE in a_pkg.header.keys():
                    pkg_info['arch'] = 'nosrc'
                else:
                    pkg_info['arch'] = 'src'
            pkg_info['checksum_type'] = a_pkg.checksum_type
            pkg_info['checksum'] = a_pkg.checksum
            pkg_hash[pkg_key] = pkg_info

        if self.options.nullorg:
            # to satisfy xmlrpc from None values.
            orgid = 'null'
        else:
            orgid = ''

        info = {
            'packages': pkg_hash,
            'channels': self.channels,
            'org_id': orgid,
            'force': self.options.force or 0
        }
        # rpc call to get checksum info for all the packages to be uploaded
        if not self.options.source:
            # computing checksum and other info is expensive process and session
            # could have expired.Make sure its re-authenticated.
            self.authenticate()
            if uploadLib.exists_getPackageChecksumBySession(self.server):
                checksum_data = uploadLib.getPackageChecksumBySession(self.server,
                                                                      self.session.getSessionString(), info)
            else:
                # old server only md5 capable
                checksum_data = uploadLib.getPackageMD5sumBySession(self.server,
                                                                    self.session.getSessionString(), info)
        else:
            # computing checksum and other info is expensive process and session
            # could have expired.Make sure its re-authenticated.
            self.authenticate()
            if uploadLib.exists_getPackageChecksumBySession(self.server):
                checksum_data = uploadLib.getSourcePackageChecksumBySession(self.server,
                                                                            self.session.getSessionString(), info)
            else:
                # old server only md5 capable
                checksum_data = uploadLib.getSourcePackageMD5sumBySession(self.server,
                                                                          self.session.getSessionString(), info)

        return (checksum_data, pkg_hash, digest_hash)

    def package(self, package, fileChecksumType, fileChecksum):
        self.warn(1, "Uploading package %s" % package)
        if not os.access(package, os.R_OK):
            self.die(-1, "Could not read file %s" % package)

        try:
            h = uploadLib.get_header(package, source=self.options.source)
        except uploadLib.UploadError:
            e = sys.exc_info()[1]
            # GS: MALFORMED PACKAGE
            print("Unable to load package", package, ":", e)
            return None

        if hasattr(h, 'packaging'):
            packaging = h.packaging
        else:
            packaging = 'rpm'

        if packaging == 'rpm' and self.options.nosig is None and not h.is_signed():
            # pkilambi:bug#173886:force exit to check for sig if --nosig
            raise uploadLib.UploadError("ERROR: %s: unsigned rpm (use --nosig to force)" % package)

        try:
            ret = self._push_package_v2(package, fileChecksumType, fileChecksum)
        except uploadLib.UploadError:
            e = sys.exc_info()[1]
            ret, diff_level, pdict = e.args[:3]
            severities = {
                1: 'path changed',
                2: 'package resigned',
                3: 'differing build times or hosts',
                4: 'package recompiled',
            }
            if diff_level in severities:
                strmsg = \
                    "Error: Package with same name already exists on " + \
                    "server but contents differ ("                     + \
                    severities[diff_level]                             + \
                    ").  Use --force or remove old package before "    + \
                    "uploading the newer version."
            else:
                strmsg = "Error: severity %s" % diff_level
            self.warn(-1, "Uploading failed for %s\n%s\n\tDiff: %s" %
                      (package, strmsg, pdict['diff']['diff']))
            if diff_level != 1:
                # This will prevent us from annoyingly retrying when there is
                # no reason to.
                raise uploadLib.UploadError()
            return ret

        return ret

    def _push_package_v2(self, package, fileChecksumType, fileChecksum):
        self.warn(1, "Using POST request")
        pu = rhnpush_v2.PackageUpload(self.url_v2, self.options.proxy)

        pu.set_session(self.session.getSessionString())
        pu.set_force(self.options.force)
        pu.set_null_org(self.options.nullorg)
        pu.set_timeout(self.options.timeout)

        status, msgstr = pu.upload(package, fileChecksumType, fileChecksum)

        ret = {}
        for tag in ('name', 'version', 'release', 'epoch', 'arch'):
            val = getattr(pu, "package_%s" % tag)
            if val is None:
                val = ''
            ret[tag] = val

        ret['checksum_type'] = fileChecksumType
        ret['checksum'] = fileChecksum
        if status == 400:
            # Bad request - something bad happened
            try:
                data = rpclib.xmlrpclib.loads(msgstr)
            except:
                # Raise the exception instead of silently dying
                raise_with_tb(uploadLib.UploadError("Error pushing %s: %s (%s)" %
                                                    (package, msgstr, status)), sys.exc_info()[2])
            (diff_dict, ), methodname = data
            del methodname
            diff_level = diff_dict['level']
            pdict = diff_dict['diff']
            raise uploadLib.UploadError(ret, diff_level, pdict)

        if status == 403:
            # auth expired raise an exception to grab one
            raise AuthenticationRequired()

        if status != 200:
            self.die(1, "Error pushing %s: %s (%s)" % (package, msgstr, status))

        return ret


class AuthenticationRequired(Exception):
    pass

if __name__ == '__main__':
    # test code
    sys.exit(main() or 0)
