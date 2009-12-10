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
# $Id$
"""
Management tool for the RHN proxy.

This script performs various management operations on the RHN proxy:
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
import string
import time
import urlparse
import rhnpush_cache
import rhnpush_confmanager

from types import IntType, StringType
try:
    from optparse import Option, OptionParser
except ImportError:
    from optik import Option, OptionParser
from rhn import rpclib
from spacewalk.common import rhn_mpm
from spacewalk.common import checksum

import uploadLib
import rhnpush_v2

# Global settings
BUFFER_SIZE = 65536
HEADERS_PER_CALL = 10
DEBUG = 0
RPMTAG_NOSOURCE = 1051

def main():
    # Initialize a command-line processing object with a table of options
    optionsTable = [
        Option('-v','--verbose',    action='count',      help='Increase verbosity', default=0),
        Option('-d','--dir',        action='store',      help='Process packages from this directory'),
        Option('-c','--channel',    action='append',     help='Manage this channel (specified by label)'),
        Option('-n','--count',      action='store',      help='Process this number of headers per call', type='int'),
        Option('-l','--list',       action='store_true', help='Only list the specified channels'),
        Option('-r','--reldir',     action='store',      help='Relative dir to associate with the file'),
        Option('-o','--orgid',      action='store',      help='Org ID', type='int'),
        Option('-u','--username',   action='store',      help='Use this username to connect to RHN/Satellite'),
        Option('-p','--password',   action='store',      help='Use this password to connect to RHN/Satellite'),
        Option('-s','--stdin',      action='store_true', help='Read the package names from stdin'),
        Option('-X','--exclude',    action="append",     help="Exclude packages that match this glob expression"),
        Option(     '--force',      action='store_true', help='Force the package upload (overwrites if already uploaded)'),
        Option(     '--nosig',      action='store_true', help="Push unsigned packages"),
        Option(     '--newest',     action='store_true', help='Only push the packages that are newer than the server ones'),
        Option(     '--nullorg',    action='store_true', help='Use the null org id'),
        Option(     '--header',     action='store_true', help='Upload only the header(s)'),
        Option(     '--source',     action='store_true', help='Upload source package information'),
        Option(     '--server',     action='store',      help='Push to this server (http[s]://<hostname>/APP)'),
        Option(     '--test',       action='store_true', help="Only print the packages to be pushed"),
        Option('-?','--usage',      action='store_true', help="Briefly describe the options"),
        Option('-N','--new-cache',  action='store_true', help="Create a new username/password cache"),
        Option(     '--no-cache',   action='store_true', help="Do not create a username/password cache"),
        Option(     '--extended-test',  action='store_true', help="Perform a more verbose test"),
        Option(     '--no-session-caching',  action='store_true', 
            help="Disables session-token support. Useful for using rhnpush with pre-4.0.6 satellites."),
        Option(     '--tolerant',   action='store_true', 
            help="If rhnpush errors while uploading a package, continue uploading the rest of the packages.")
    ]

    #Having to maintain a store_true list is ugly. I'm trying to get rid of this.
    #12/22/05 wregglej 173287   Added no_cache to true_list so it's value gets changed from a string to an int.
    true_list = ['usage', 'test', 'source', 'header', 'nullorg', 'newest',\
                 'nosig', 'force', 'list', 'stdin', 'new_cache','extended_test', 'no_cache',\
                 'no_session_caching', 'tolerant']
    optionParser = OptionParser(option_list=optionsTable, usage="%prog [OPTION] [<package>]")
    manager = rhnpush_confmanager.ConfManager(optionParser, true_list)
    options = manager.get_config()
    
    upload = UploadClass(options, files=options.files)

    if options.usage:
        optionParser.print_usage()
        sys.exit(0)

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
            print "No new files to upload; exiting"
        else:
            print "Nothing to do (try --help for more options)"
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
    
if __name__ == "__main__":
    sys.exit(main())

class UploadClass(uploadLib.UploadClass):
    def setURL(self):
        server = self.options.server
        if server is None:
            self.die(1, "Required parameter --server not supplied")
        scheme, netloc, path, params, query, fragment = urlparse.urlparse(server)
        if not netloc:
            # No schema - trying to patch it up ourselves?
            server = "http://" + server
            scheme, netloc, path, params, query, fragment = urlparse.urlparse(server)

        if not netloc:
            self.die(2, "Invalid URL %s" % server)
        if path == '':
            path = '/APP'
        if string.lower(scheme) not in ('http', 'https'):
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

    def _test_force(self):
        test_force_str =  "Setting force flag:  %s"
        test_force = "Passed"
        try:
            self.setForce()
        except:
            test_force = "Failed"
        print test_force_str % test_force

    def _test_set_org(self):
        test_set_org_str = "Setting the org:    %s"
        test_set_org = "Passed"
        try:
            self.setOrg()
        except:
            test_set_org = "Failed"
        print test_set_org_str % test_set_org

    def _test_set_url(self):
        test_set_url_str = "Setting the URL:    %s"
        test_set_url = "Passed"
        try:
            self.setURL()
        except:
            test_set_url = "Failed"
        print test_set_url_str % test_set_url

    def _test_set_channels(self):
        test_set_channels_str = "Setting the channels:  %s"
        test_set_channels = "Passed"
        try:
            self.setChannels()
        except:
            test_set_channels = "Failed"
        print test_set_channels_str % test_set_channels

    def _test_username_password(self):
        test_user_pass_str = "Setting the username and password:    %s"
        test_user_pass = "Passed"
        try:
            self.setUsernamePassword()
        except:
            test_user_pass = "Failed"
        print test_user_pass_str % test_user_pass

    def _test_set_server(self):
        test_set_server_str = "Setting the server:  %s"
        test_set_server = "Passed"
        try:
            self.setServer()
        except:
            test_set_server = "Failed"
        print test_set_server_str % test_set_server

    def _test_connect(self):
        auth_ret = uploadLib.call(self.server.packages.test_login, self.username, self.password )
        if auth_ret == 1:
            test_auth = "Passed"
        else:
            test_auth = "Failed"
        print "Testing connection and authentication:   %s" % test_auth

    def _test_access(self):
        if self.new_sat_test():
            access_ret = callable(self.server.packages.channelPackageSubscriptionBySession)
        else:
            access_ret = callable(self.server.packages.channelPackageSubscription)

        if access_ret == 1:
            test_access = "Passed"
        else:
            test_access = "Failed"
        print "Testing access to upload functionality on server:    %s" % test_access

    #12/22/05 wregglej 173287  Added a this funtion to test the new session authentication stuff.
    #It still needs work.
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
        print "The files that would have been pushed:"
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
        #12/22/05 wregglej 173287 authenticate the session.
        self.authenticate()

        # Do we have the new-style handler available?

        #ping the server for status
        self.warn(2,"url is",self.url_v2)
        ping = rhnpush_v2.PingPackageUpload(self.url_v2)
        self.ping_status, errmsg, headerinfo = ping.ping()
        self.warn(2, "Result codes:", self.ping_status, errmsg)

        
        # move patch clusters to the end because all the patches in the cluster
        # have to be pushed before the cluster itself
        files1 = []
        files2 = []
        for file in self.files:
            if file.startswith('patch-cluster-'):
                files2.append(file)
            else:
                files1.append(file)

        self.files = files1 + files2

        channel_packages = []

        # a little fault tolarence is in order
        random.seed()
        checkpkgflag = 0
        tries = 3

        #pkilambi:check if the Sat version we are talking to has this capability.
        #If not use the normal way to talk to older satellites(< 4.1.0).
        if headerinfo.getheader('X-RHN-Check-Package-Exists'):
            checkpkgflag = 1
            (server_digest_hash, pkgs_info, digest_hash) = self.check_package_exists()
            
        for pkg in self.files:
            ret = None #pkilambi:errors off as not initialized.this fixes it.
    
            #temporary fix for picking pkgs instead of full paths
            pkg_key = (pkg.strip()).split('/')[-1]

            if checkpkgflag :
                # it's newer satellite, compute checksum checks on client.
                if not server_digest_hash.has_key(pkg_key):
                    continue
                
                digest = digest_hash[pkg_key]
                server_digest = tuple(server_digest_hash[pkg_key])

                # compare checksums for existance check
                if server_digest == digest and not self.options.force:
                    channel_packages.append(pkgs_info[pkg_key])
                    self.warn(1, "Package %s already exists on the RHN Server-- Skipping Upload...." % pkg)
                    continue

                elif server_digest == "":
                    self.warn(1,"Package %s Not Found on RHN Server -- Uploading" % pkg)

                elif server_digest == "on-disk" and not self.options.force:
                    channel_packages.append(pkgs_info[pkg_key])
                    self.warn(0,"Package on disk but not on db -- Skipping Upload "%pkg)
                    continue
                
                elif server_digest != digest:
                    if self.options.force:
                        self.warn(1,"Package checksum %s mismatch  -- Forcing Upload"% pkg)
                    else:
                        msg = """Error: Package %s already exists on the server with a different checksum. Skipping upload to prevent overwriting existing package. (You may use rhnpush with the --force option to force this upload if the force_upload option is enabled on your server.)\n"""% pkg
                        if not self.options.tolerant:
                            self.die(-1, msg)
                        self.warn(0, msg)
                        continue
            else:
                # it's an older satellite(< 4.1.0). Just do the push the usual old way,
                # without checksum pre-check.
                try:
                    f = open(pkg)
                    header, payload_stream = rhn_mpm.load(file=f)
                    checksum_type = header.checksum_type()
                except rhn_mpm.InvalidPackageError, e:
                    if not self.options.tolerant:
                        self.die(-1, "ERROR: %s: This file doesn't appear to be a package" % pkg)
                    self.warn(2, "ERROR: %s: This file doesn't appear to be a package" % pkg)
                    continue
                except IOError:
                    if not self.options.tolerant:
                        self.die(-1, "ERROR: %s: No such file or directory available" % pkg)
                    self.warn(2, "ERROR: %s: No such file or directory available" % pkg)
                    continue
                
                digest = (checksum_type,
                          checksum.getFileChecksum(checksum_type, file=payload_stream))
                f.close()
                
            for t in range(0, tries):
                try:
                    ret = self.package(pkg, digest)
                    if ret is None:
                        raise UploadError()

                # TODO:  Revisit this.  We throw this error all over the place,
                #        but doing so will cause us to skip the --tolerant logic
                #        below.  I don't think we really want this behavior.
                #        There are some cases where we don't want to retry 3
                #        times, but not at the expense of disabling the tolerant
                #        flag, IMHO.  This loop needs some lovin'.  -- pav

                #FIX: it checks for tolerant flag and aborts only if the flag is
                #not specified
                except UploadError, ue:
                    if not self.options.tolerant:
                        self.die(1, ue)
                    self.warn(2, ue)
                except AuthenticationRequired, a:
                    #session expired so we re-authenticate for the process to complete
                    #this uses the username and password from memory if available
                    #else it prompts for one.
                    self.authenticate()
                except:
                    self.warn(2, sys.exc_info()[1])
                    wait = random.randint(1, 5)
                    self.warn(0, "Waiting %d seconds and trying again..." % wait)
                    time.sleep(wait)
                #The else clause gets executed in the stuff in the try-except block *succeeds*.
                else:
                    break

            #if the preceeding for-loop exits without a call to break, then this else clause gets called.
            #What's kind of weird is that if the preceeding for-loop doesn't call break then an error occured
            #and all of retry attempts failed. If the for-loop *does* call break then everything is hunky-dory.
            #In short, this else clause only get's called if something is F.U.B.A.R and the retry attempts don't
            #fix anything.
            else:
                if not self.options.tolerant:
                    #pkilambi:bug#176358:this exits with a error code of 1
                    self.die(1, "Giving up after %d attempts" % tries)
                else:
                    print "Giving up after %d attempts and continuing on..." % (tries,)
                
            #5/13/05 wregglej - 154248 ?? we still want to add the packages if they're source.
            if ret and self.channels: # and ret['arch'] != 'src':
                # Don't bother to add the package if
                # no channel was specified or a source rpm was passed
                channel_packages.append(ret)

        #self.channels is never None, it always has at least one entry with an empty string.
        if len(self.channels) == 1 and self.channels[0] == '':
            return
        info = {
            'packages'  : channel_packages,
            'channels'  : self.channels
        }
        if self.orgId == '' or self.orgId > 0:
            info['orgId'] = self.orgId
    
        #2/3/06 wregglej 173287 Added check to see if we can use session tokens.
        if channel_packages:
            if self.new_sat_test():
                #12/22/05 wregglej 173287  Changed the XMLRPC function to the new session-based one.
                self.authenticate()
                uploadLib.call(self.server.packages.channelPackageSubscriptionBySession,
                                self.session.getSessionString(), info)
            else:
                uploadLib.call(self.server.packages.channelPackageSubscription, self.username,
                                self.password, info)
        return 0

    # does an existance check of the packages to be uploaded and returns their checksum and other info
    def check_package_exists(self):
        self.warn(2, "Computing checksum and package Info .This may take sometime ...")
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
                f = open(pkg)
                header, payload_stream = rhn_mpm.load(file=f)
                checksum_type = header.checksum_type()
            except rhn_mpm.InvalidPackageError, e:
                if not self.options.tolerant:
                    self.die(-1, "ERROR: %s: This file doesn't appear to be a package" % pkg)
                self.warn(2, "ERROR: %s: This file doesn't appear to be a package" % pkg)
                continue
            except IOError:
                if not self.options.tolerant:
                    self.die(-1, "ERROR: %s: No such file or directory available" % pkg)
                self.warn(2, "ERROR: %s: No such file or directory available" % pkg)
                continue
                        
            digest_hash[pkg_key] =  (checksum_type,
                        checksum.getFileChecksum(checksum_type, file=payload_stream))
            f.close()
            
            for tag in ('name', 'version', 'release', 'epoch', 'arch'):
                val = header[tag]
                if val is None:
                    val = ''
                pkg_info[tag] = val
            #b195903:the arch for srpms should be obtained by is_source check
            #instead of checking arch in header
            if header.is_source:
                if not self.options.source:
                    self.die(-1, "ERROR: Trying to Push src rpm, Please re-try with --source.") 
                if RPMTAG_NOSOURCE in header.keys():
                    pkg_info['arch'] = 'nosrc'
                else:
                    pkg_info['arch'] = 'src'
            pkg_info['checksum'] = digest_hash[pkg_key]
            pkg_hash[pkg_key] = pkg_info

        if self.options.nullorg:
            #to satisfy xmlrpc from None values.
            orgid = 'null'
        else:
            orgid = ''
            
        info = {
            'packages' : pkg_hash,
            'channels' : self.channels,
            'org_id'   : orgid,
	    'force'    : self.options.force or 0
            }
        # rpc call to get checksum info for all the packages to be uploaded
        if not self.options.source:
            if self.new_sat_test():
                # computing checksum and other info is expensive process and session
                # could have expired.Make sure its re-authenticated.
                self.authenticate()
                checksum_data = uploadLib.getPackageChecksumBySession(self.server, self.session.getSessionString(), info)
            else:
                checksum_data = uploadLib.getPackageChecksum(self.server, self.username, self.password, info)
        else:
            if self.new_sat_test():
                # computing checksum and other info is expensive process and session
                # could have expired.Make sure its re-authenticated.
                self.authenticate()
                checksum_data = uploadLib.getSourcePackageChecksumBySession(self.server, self.session.getSessionString(), info)
            else:
                checksum_data = uploadLib.getSourcePackageChecksum(self.server, self.username, self.password, info)
                
        return (checksum_data, pkg_hash, digest_hash)


    def package(self, package, FileChecksum):
        self.warn(1, "Uploading package %s" % package)
        if not os.access(package, os.R_OK):
            self.die(-1, "Could not read file %s" % package)

        try:
            h = uploadLib.get_header(package, source=self.options.source)
        except uploadLib.InvalidPackageError, e:
            # GS: MALFORMED PACKAGE
            print "Unable to load package", package
            return None

        if hasattr(h, 'packaging'):
            packaging = h.packaging
        else:
            packaging = 'rpm'
            
        if packaging == 'rpm' and self.options.nosig is None and not h.is_signed():
            #pkilambi:bug#173886:force exit to check for sig if --nosig 
            raise UploadError("ERROR: %s: unsigned rpm (use --nosig to force)"% package)

        try:
            if self.ping_status == 200:
                ret = self._push_package_v2(package, FileChecksum)
            else:
                ret = self._push_package_xmlrpc(package, h, packaging)
        except UploadError, e:
            ret, diff_level, pdict = e.args[:3]
            severities = {
                1   : 'path changed',
                2   : 'package resigned',
                3   : 'differing build times or hosts',
                4   : 'package recompiled',
            }
            if severities.has_key(diff_level):
                strmsg = \
                    "Error: Package with same name already exists on " + \
                    "server but contents differ ("                     + \
                    severities[diff_level]                             + \
                    ").  Use --force or remove old package before "    + \
                    "uploading the newer version."
            else:
                strmsg = "Error: severity %s" % diff_level
            self.warn(-1, "Uploading failed for %s\n%s\n\tDiff: %s" % \
                (package, strmsg, pdict['diff']['diff']))
            if diff_level != 1:
                # This will prevent us from annoyingly retrying when there is
                # no reason to.
                raise UploadError()
            return ret

        return ret

    def _push_package_v2(self, package, FileChecksum):
        self.warn(1, "Using POST request")
        pu = rhnpush_v2.PackageUpload(self.url_v2)

        if self.new_sat_test():
            pu.set_session(self.session.getSessionString())
        else:
            pu.set_auth(self.username, self.password)
        pu.set_force(self.options.force)
        pu.set_null_org(self.options.nullorg)

        status, msgstr = pu.upload(package, FileChecksum)

        ret = {}
        for tag in ('name', 'version', 'release', 'epoch', 'arch'):
            val = getattr(pu, "package_%s" % tag)
            if val is None:
                val = ''
            ret[tag] = val

        ret['checksum'] = FileChecksum
        if status == 400:
            # Bad request - something bad happened
            try:
                data = rpclib.xmlrpclib.loads(msgstr)
            except:
	        # Raise the exception instead of silently dying
                raise UploadError("Error pushing %s: %s (%s)" % 
		            (package, msgstr, status))
            (diff_dict, ), methodname = data
            del methodname
            diff_level = diff_dict['level']
            pdict = diff_dict['diff']
            raise UploadError(ret, diff_level, pdict)

        if status == 403:
            #auth expired raise an exception to grab one
            raise AuthenticationRequired()
        
        if status != 200:
            self.die(1, "Error pushing %s: %s (%s)" % (package, msgstr, status))
            
        return ret

    def _push_package_xmlrpc(self, package, header, packaging):
        self.warn(1, "Using XMLRPC")
        if self.options.source:
            ret = None
        else:
            ret = {}
            for tag in ('name', 'version', 'release', 'epoch', 'arch'):
                val = header[tag]
                if val is None:
                    val = ''
                ret[tag] = val

        bits = open(package, "r").read()
        hash = {
            'package'       : bits,
            'channels'      : self.channels,
            'packaging'     : packaging,
        }
        if self.orgId == '' or self.orgId > 0:
            hash['orgId'] = self.orgId
        if self.force:
            hash['force'] = 4
        
        #2/3/06 wregglej 173287 Added check to see if we can use session tokens.
        if self.new_sat_test():
            #12/22/05 wregglej 173287 Changed the XMLRPC call to the session-based version.
            retval = uploadLib.call(self.server.packages.uploadPackageBySession, self.session.getSessionString(), 
                                    hash)
        else:
            retval = uploadLib.call(self.server.packages.uploadPackage, self.username, self.password, hash)

        if retval == 0:
            # OK
            return ret
        if type(retval) in (type(()), type([])) and len(retval) == 2:
            (pdict, diffLevel) = retval
            raise UploadError(ret, diffLevel, pdict)
        return None

class UploadError(Exception):
    pass

class AuthenticationRequired(Exception):
    pass

if __name__ == '__main__':
    # test code
    sys.exit(main() or 0)
