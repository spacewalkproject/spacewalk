#
# Copyright (c) 2008--2010 Red Hat, Inc.
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
import sys, os, time
import hashlib
from optparse import OptionParser
from spacewalk.server import rhnPackage, rhnSQL, rhnChannel, rhnPackageUpload
from spacewalk.common import CFG, initCFG, rhnLog, rhnFault
from spacewalk.common.checksum import getFileChecksum
from spacewalk.server.importlib.importLib import IncompletePackage
from spacewalk.server.importlib.packageImport import ChannelPackageSubscription
from spacewalk.server.importlib.backendOracle import SQLBackend
from spacewalk.server import taskomatic

default_log_location = '/var/log/rhn/reposync/'
default_hash = 'sha256'

class RepoSync:
   
    parser = None
    type = None
    urls = None
    channel_label = None
    channel = None
    fail = False
    quiet = False
    regen = False

    def main(self):
        initCFG('server')
        db_string = CFG.DEFAULT_DB #"rhnsat/rhnsat@rhnsat"
        rhnSQL.initDB(db_string)
        (options, args) = self.process_args()

        log_filename = 'reposync.log'
        if options.channel_label:
            date = time.localtime()
            datestr = '%d.%02d.%02d-%02d:%02d:%02d' % (date.tm_year, date.tm_mon, date.tm_mday, date.tm_hour, date.tm_min, date.tm_sec)
            log_filename = options.channel_label + '-' +  datestr + '.log'
           
        rhnLog.initLOG(default_log_location + log_filename)
        #os.fchown isn't in 2.4 :/
        os.system("chgrp apache " + default_log_location + log_filename)

        if options.type not in ["yum"]:
            print "Error: Unknown type %s" % options.type
            sys.exit(2)

        quit = False
        if not options.url:
            if options.channel_label:
                # TODO:need to look at user security across orgs
                h = rhnSQL.prepare("""select s.source_url
                                      from rhnContentSource s,
                                           rhnChannelContentSource cs,
                                           rhnChannel c
                                     where s.id = cs.source_id
                                       and cs.channel_id = c.id
                                       and c.label = :label""")
                h.execute(label=options.channel_label)
                source_urls = h.fetchall_dict() or []
                if source_urls:
                    self.urls = [row['source_url'] for row in source_urls]
                else:
                    quit = True
                    self.error_msg("Channel has no URL associated")
        else:
            self.urls = [options.url]
        if not options.channel_label:
            quit = True
            self.error_msg("--channel must be specified")

        self.log_msg("\nSync started: %s" % (time.asctime(time.localtime())))
        self.log_msg(str(sys.argv))


        if quit:
            sys.exit(1)

        self.type = options.type
        self.channel_label = options.channel_label
        self.fail = options.fail
        self.quiet = options.quiet
        self.channel = self.load_channel()

        if not self.channel or not rhnChannel.isCustomChannel(self.channel['id']):
            print "Channel does not exist or is not custom"
            sys.exit(1)

        for url in self.urls:
            plugin = self.load_plugin()(url, self.channel_label)
            self.import_packages(plugin, url)
        if self.regen:
            taskomatic.add_to_repodata_queue_for_channel_package_subscription(
                [self.channel_label], [], "server.app.yumreposync")
            taskomatic.add_to_erratacache_queue(self.channel_label)
        self.update_date()
        rhnSQL.commit()        
        self.print_msg("Sync complete")


    def update_date(self):
        """ Updates the last sync time"""
        h = rhnSQL.prepare( """update rhnChannel set LAST_SYNCED = current_timestamp
                             where label = :channel""")
        h.execute(channel=self.channel['label'])

    def process_args(self):
        self.parser = OptionParser()
        self.parser.add_option('-u', '--url', action='store', dest='url', help='The url to sync')
        self.parser.add_option('-c', '--channel', action='store', dest='channel_label', help='The label of the channel to sync packages to')
        self.parser.add_option('-t', '--type', action='store', dest='type', help='The type of repo, currently only "yum" is supported', default='yum')
        self.parser.add_option('-f', '--fail', action='store_true', dest='fail', default=False , help="If a package import fails, fail the entire operation")
        self.parser.add_option('-q', '--quiet', action='store_true', dest='quiet', default=False, help="Print no output, still logs output")
        return self.parser.parse_args()

    def load_plugin(self):
        name = self.type + "_src"
        mod = __import__('spacewalk.satellite_tools.repo_plugins', globals(), locals(), [name])
        submod = getattr(mod, name)
        return getattr(submod, "ContentSource")
        
    def import_packages(self, plug, url):
        packages = plug.list_packages()
        to_link = []
        to_download = []
        self.print_msg("Repo " + url + " has " + str(len(packages)) + " packages.")
        for pack in packages:
            # we have a few scenarios here:
            # 1.  package is not on the server (link and download)
            # 2.  package is in the server, but not in the channel (just link if we can)
            # 3.  package is in the server and channel, but not on the file system (just download)
            path, package_channel = rhnPackage.get_path_for_package(
                   [pack.name, pack.version, pack.release, pack.epoch, pack.arch],
                   self.channel_label)

            if path:
                pack.path = os.path.join(CFG.MOUNT_POINT, path)
                if not self.match_package_checksum(pack.path,
                                pack.checksum_type, pack.checksum)):
                    to_download.append(pack)
            else:
                to_download.append(pack)

            if package_channel != self.channel_label:
                to_link.append(pack)

        if len(to_download) == 0:
            self.print_msg("No new packages to download.")
        else:
            self.regen=True
        is_non_local_repo = (url.find("file://") < 0)
        for (index, pack) in enumerate(to_download):
            """download each package"""
            # try/except/finally doesn't work in python 2.4 (RHEL5), so here's a hack
            try:
                try:
                    self.print_msg(str(index+1) + "/" + str(len(to_download)) + " : "+ \
                          pack.getNVREA())
                    pack.path = localpath = plug.get_package(pack)
                    pack.load_checksum_from_header()
                    self.upload_package(pack)
                    if pack in to_link:
                        self.associate_package(pack)
                except KeyboardInterrupt:
                    raise
                except Exception, e:
                   self.error_msg(e)
                   if self.fail:
                       raise
                   continue
            finally:
                if is_non_local_repo:
                    os.remove(localpath)

        if len(to_link) != 0:
            self.regen=True
        for (index, pack) in enumerate(to_link):
            """Link each package that wasn't already linked in the previous step"""
            try:
                if pack not in to_download:
                    pack.load_checksum_from_header()
                    self.associate_package(pack)
            except KeyboardInterrupt:
                raise
            except Exception, e:
                self.error_msg(e)
                if self.fail:
                    raise
                continue

    def match_package_checksum(self, abspath, checksum_type, checksum):
        if (os.path.exists(abspath) and
            getFileChecksum(checksum_type, filename=abspath) == checksum):
            return 1
        return 0
    
    def upload_package(self, package):
        rel_package_path = rhnPackageUpload.relative_path_from_header(
                package.header, self.channel['org_id'],
                package.checksum_type, package.checksum)
        package_dict, diff_level = rhnPackageUpload.push_package(package.header,
                package.payload_stream, package.checksum_type, package.checksum,
                force=False,
                header_start=package.header_start, header_end=package.header_end,
                relative_path=rel_package_path,
                org_id=self.channel['org_id'])
        package.file.close()

    def associate_package(self, pack):
        caller = "server.app.yumreposync"
        backend = SQLBackend()
        package = {}
        package['name'] = pack.name
        package['version'] = pack.version
        package['release'] = pack.release
        package['epoch'] = pack.epoch
        package['arch'] = pack.arch
        package['checksum'] = pack.checksum
        package['checksum_type'] = pack.checksum_type
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
                       backend, caller=caller, repogen=False)
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

    def short_hash(self, str):
        return hashlib.new(default_hash, str).hexdigest()[0:8]

class ContentPackage:

    def __init__(self):
        # map of checksums
        self.checksum_type = None
        self.checksum = None

        #unique ID that can be used by plugin
        self.unique_id = None

        self.name = None
        self.version = None
        self.release = None
        self.epoch = None
        self.arch = None

        self.path = None
        self.file = None
        self.header = None
        self.payload_stream = None
        self.header_start = None
        self.header_end = None

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

    def load_checksum_from_header(self):
       if self.path is None:
           raise rhnFault(50, "Unable to load package", explain=0)
        self.file = open(self.path, 'rb')
        self.header, self.payload_stream, self.header_start, self.header_end = \
                rhnPackageUpload.load_package(self.file)
        self.checksum_type = self.header.checksum_type()
        self.checksum = getFileChecksum(self.checksum_type, file=self.file)
