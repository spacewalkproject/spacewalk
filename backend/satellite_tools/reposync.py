#!/usr/bin/python -u
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
import sys, os, time, grp
from optparse import OptionParser
from common import rhnLib
from server import rhnPackage, rhnSQL, rhnChannel, rhnPackageUpload
from common import CFG, initCFG, rhnLog, fetchTraceback
from rhn.common import rhn_rpm
from rhn.common.rhn_mpm import InvalidPackageError
from server.importlib.importLib import IncompletePackage
from server.importlib.backendOracle import OracleBackend
from server.importlib.packageImport import ChannelPackageSubscription


default_log_location = '/var/log/rhn/reposync/'

class RepoSync:
   
    parser = None
    type = None
    url = None
    channel_label = None
    plugin = None
    channel = None
    fail = False
    repo_label = None
    quiet = False
    mirrorlist = False

    def main(self):
        initCFG('server')
        db_string = CFG.DEFAULT_DB #"rhnsat/rhnsat@rhnsat"
        rhnSQL.initDB(db_string)
        (options, args) = self.process_args()

        log_filename = 'reposync.log'
        if options.channel_label and options.label:
            date = time.localtime()
            datestr = '%d.%02d.%02d-%02d:%02d:%02d' % (date.tm_year, date.tm_mon, date.tm_mday, date.tm_hour, date.tm_min, date.tm_sec)
            log_filename = options.channel_label + '-' + options.label + '-' +  datestr + '.log'
           
        rhnLog.initLOG(default_log_location + log_filename)
        #os.fchown isn't in 2.4 :/
        os.system("chgrp apache " + default_log_location + log_filename)


        quit = False
        if not options.url:
            quit = True
            self.error_msg("--url must be specified")
        if not options.type:
            quit = True
            self.error_msg("--type must be specified")
        if not options.channel_label:
            quit = True
            self.error_msg("--channel must be specified")
        if not options.label:
            quit = True
            self.error_msg("--label must be specified")

        self.log_msg("\nSync started: %s" % (time.asctime(time.localtime())))
        self.log_msg(str(sys.argv))


        if quit:
            sys.exit(1)

        self.type = options.type
        self.url = options.url
        self.channel_label = options.channel_label
        self.fail = options.fail
        self.repo_label = options.label
        self.mirrorlist = options.mirror
        self.quiet = options.quiet
        self.channel = self.load_channel()

        if not self.channel or not rhnChannel.isCustomChannel(self.channel['id']):
            print "Channel does not exist or is not custom"
            sys.exit(1)

        self.plugin = self.load_plugin()(self.url, self.channel_label + "-" + self.repo_label, self.mirrorlist)
        self.import_packages(self.plugin.list_packages())
        self.print_msg("Sync complete")

    def process_args(self):
        self.parser = OptionParser()
        self.parser.add_option('-u', '--url', action='store', dest='url', help='The url to sync')
        self.parser.add_option('-c', '--channel', action='store', dest='channel_label', help='The label of the channel to sync packages to')
        self.parser.add_option('-t', '--type', action='store', dest='type', help='The type of repo, currently only "yum" is supported')
        self.parser.add_option('-l', '--label', action='store', dest='label', help='A friendly label to refer to the repo')
        self.parser.add_option('-f', '--fail', action='store_true', dest='fail', default=False , help="If a package import fails, fail the entire operation")
        self.parser.add_option('-q', '--quiet', action='store_true', dest='quiet', default=False, help="Print no output, still logs output")
        self.parser.add_option('-m', '--mirrorlist', action='store_true', dest='mirror', default=False, help="Treat --url as a mirror list (may not be supported by all content sources)")
        return self.parser.parse_args()

    def load_plugin(self):
        name = self.type + "_src"
        mod = __import__('satellite_tools.repo_plugins', globals(), locals(), [name])
        submod = getattr(mod, name)
        return getattr(submod, "ContentSource")
        
    def import_packages(self, packages):
        to_link = []
        to_download = []
        self.print_msg("Repo " + self.url + " has " + str(len(packages)) + " packages.")
        for pack in packages:
             pid = None
             if pack.checksums.has_key('md5sum'):
                 """lookup by md5sum"""
             elif pack.checksums.has_key('sha256'):
                 """lookup by sha256"""
             if pid == None:
                 if self.channel_label not in \
                     rhnPackage.get_channels_for_package([pack.name, \
                     pack.version, pack.release, pack.epoch, pack.arch]) and \
                     self.channel_label not in \
                     rhnPackage.get_channels_for_package([pack.name, \
                     pack.version, pack.release, '', pack.arch]):
                     to_download.append(pack)

        if len(to_download) == 0:
            self.print_msg("No new packages to download.")
        for (index, pack) in enumerate(to_download):
            """download each package"""
            try:
                self.print_msg(str(index+1) + "/" + str(len(to_download)) + " : "+ \
                      pack.getNVREA())
                path = self.plugin.get_package(pack)
                md5 = rhnLib.getFileMD5(filename=path)
                pid =  rhnPackage.get_package_for_md5sum(
                                  self.channel['org_id'], md5)
                if pid is None:
                    self.upload_package(pack, path)
                self.associate_package(pack, md5)
                if self.url.find("file://")  < 0:
                    os.remove(path)

            except KeyboardInterrupt:
                raise
            except:
                self.error_msg("ERROR" + fetchTraceback())
                if self.fail:
                    raise
                continue
    
    def upload_package(self, package, path):
        temp_file = open(path, 'rb')
        header, payload_stream, md5sum, header_start, header_end = \
                rhnPackageUpload.load_package(temp_file)
        rel_package_path = rhnPackageUpload.relative_path_from_header(
                    header, org_id=self.channel['org_id'], md5sum=md5sum)
        package_path = os.path.join(CFG.MOUNT_POINT,
                    rel_package_path)
        package_dict, diff_level = rhnPackageUpload.push_package(header,
                    payload_stream, md5sum, force=False,
                    header_start=header_start, header_end=header_end,
                    relative_path=rel_package_path, 
                    org_id=self.channel['org_id'])
        temp_file.close()

    def associate_package(self, pack, md5sum):
        caller = "server.app.yumreposync"
        backend = OracleBackend()
        backend.init()
        package = {}
        package['name'] = pack.name
        package['version'] = pack.version
        package['release'] = pack.release
        package['epoch'] = pack.epoch
        package['arch'] = pack.arch
        package['md5sum'] = md5sum
        package['channels']  = [{'label':self.channel_label, 
                                 'id':self.channel['id']}]
        package['org_id'] = self.channel['org_id']
        try:
           self._importer_run(package, caller, backend)
        except:
            package['epoch'] = ''
            self._importer_run(package, caller, backend)

        backend.commit()

    def _importer_run(self, package, caller, backend):
            importer = ChannelPackageSubscription(
                       [IncompletePackage().populate(package)],
                       backend, caller=caller)
            importer.run()


    def load_channel(self):
        return rhnChannel.channel_info(self.channel_label)


    def print_msg(self, message):
        rhnLog.log_clean(0, message)
        if not self.quiet:
            print message


    def error_msg(self, message):
        rhnLog.log_clean(0, message)
        if not self.quiet:
            sys.stderr.write(str(message) + "\n")

    def log_msg(self, message):
        rhnLog.log_clean(0, message)

class ContentPackage:

    #map of checksums.  Valid keys are 'md5sum' & 'sha256'
    checksums = {}
    
    #unique ID that can be used by plugin
    unique_id = None 

    name = None
    version = None
    release = None
    epoch = None
    arch = None

    def setNVREA(self, name, version, release, epoch, arch):
        self.name = name
        self.version = version
        self.release = release
        self.arch = arch
        self.epoch = epoch

    def getNVREA(self):
        if self.epoch:
            return self.name + '-' + self.version + '-' + self.release + '-' + self.epoch + '.' + self.arch
        else:
            return self.name + '-' + self.version + '-' + self.release + '.' + self.arch

