#
# Copyright (c) 2008--2011 Red Hat, Inc.
# Copyright (c) 2010--2011 SUSE Linux Products GmbH
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
from datetime import datetime
import traceback
from optparse import OptionParser
from spacewalk.server import rhnPackage, rhnSQL, rhnChannel, rhnPackageUpload
from spacewalk.common import CFG, initCFG, rhnLog, rhnFault, log_debug
from spacewalk.common.checksum import getFileChecksum
from spacewalk.common.rhn_mpm import InvalidPackageError
from spacewalk.server.importlib.importLib import IncompletePackage, Erratum, Checksum, Bug, Keyword
from spacewalk.server.importlib.packageImport import ChannelPackageSubscription
from spacewalk.server.importlib.backendOracle import SQLBackend
from spacewalk.common.rhn_mpm import InvalidPackageError
from spacewalk.server.importlib.errataImport import ErrataImport
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
            self.import_updates(plugin, url)
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

    def import_updates(self, plug, url):
      notices = plug.get_updates()
      self.print_msg("Repo " + url + " has " + str(len(notices)) + " errata.")
      if len(notices) > 0:
        self.upload_updates(notices)

    def upload_updates(self, notices):
        batch = []
        skipped_updates = 0
        typemap = {
                  'security'    : 'Security Advisory',
                  'recommended' : 'Bug Fix Advisory',
                  'bugfix'      : 'Bug Fix Advisory',
                  'optional'    : 'Product Enhancement Advisory',
                  'feature'     : 'Product Enhancement Advisory',
                  'enhancement' : 'Product Enhancement Advisory'
                  }
        for notice in notices:
            notice = self.fix_notice(notice)
            existing_errata = self.get_errata(notice['update_id'])

            e = Erratum()
            e['errata_from']   = notice['from']
            e['advisory']      = notice['update_id']
            e['advisory_name'] = notice['update_id']
            e['advisory_rel']  = notice['version']
            e['advisory_type'] = typemap.get(notice['type'], 'Product Enhancement Advisory')
            e['product']       = notice['release']
            e['description']   = notice['description']
            e['synopsis']      = notice['title']
            e['topic']         = ' '
            e['solution']      = ' '
            e['issue_date']    = self._to_db_date(notice['issued'])
            if notice['updated']:
                e['update_date']   = self._to_db_date(notice['updated'])
            else:
                e['update_date']   = self._to_db_date(notice['issued'])
            e['org_id']        = self.channel['org_id']
            e['notes']         = ''
            e['refers_to']     = ''
            e['channels']      = []
            e['packages']      = []
            e['files']         = []
            if existing_errata:
                e['channels'] = existing_errata['channels']
                e['packages'] = existing_errata['packages']
            e['channels'].append({'label':self.channel_label})

            for pkg in notice['pkglist'][0]['packages']:
                param_dict = {
                             'name'          : pkg['name'],
                             'version'       : pkg['version'],
                             'release'       : pkg['release'],
                             'arch'          : pkg['arch'],
                             'channel_label' : self.channel_label
                             }
                if pkg['epoch'] is None or pkg['epoch'] == '':
                    epochStatement = "is NULL"
                else:
                    epochStatement = "= :epoch"
                    param_dict['epoch'] = pkg['epoch']
                if self.channel['org_id']:
                    param_dict['org_id'] = self.channel['org_id']
                    orgStatement = "= :org_id"
                else:
                    orgStatement = "is NULL"

                h = rhnSQL.prepare("""
                    select p.id, c.checksum, c.checksum_type
                      from rhnPackage p
                      join rhnPackagename pn on p.name_id = pn.id
                      join rhnpackageevr pevr on p.evr_id = pevr.id
                      join rhnpackagearch pa on p.package_arch_id = pa.id
                      join rhnArchType at on pa.arch_type_id = at.id
                      join rhnChecksumView c on p.checksum_id = c.id
                      join rhnChannelPackage cp on p.id = cp.package_id
                      join rhnChannel ch on cp.channel_id = ch.id
                     where pn.name = :name
                       and p.org_id %s
                       and pevr.version = :version
                       and pevr.release = :release
                       and pa.label = :arch
                       and pevr.epoch %s
                       and at.label = 'rpm'
                       and ch.label = :channel_label
                """ % (orgStatement, epochStatement))
                apply(h.execute, (), param_dict)
                cs = h.fetchone_dict() or None

                if not cs:
                    if param_dict.has_key('epoch'):
                        log_debug(1, "No cheksum found for %s-%s:%s-%s.%s. Skipping Package" % (param_dict['name'],
                                                                                                param_dict['epoch'],
                                                                                                param_dict['version'],
                                                                                                param_dict['release'],
                                                                                                param_dict['arch']
                                                                                               ))
                    else:
                        log_debug(1, "No cheksum found for %s-%s-%s.%s. Skipping Package" % (param_dict['name'],
                                                                                             param_dict['version'],
                                                                                             param_dict['release'],
                                                                                             param_dict['arch'],
                                                                                            ))
                    continue

                newpkgs = []
                for oldpkg in e['packages']:
                    if oldpkg['package_id'] != cs['id']:
                        newpkgs.append(oldpkg)

                package = IncompletePackage()
                for k in pkg.keys():
                    package[k] = pkg[k]
                package['epoch'] = pkg.get('epoch', '')
                package['org_id'] = self.channel['org_id']

                package['checksums'] = {cs['checksum_type'] : cs['checksum']}
                package['checksum_type'] = cs['checksum_type']
                package['checksum'] = cs['checksum']

                package['package_id'] = cs['id']
                newpkgs.append(package)

                e['packages'] = newpkgs

            if len(e['packages']) == 0:
                skipped_updates = skipped_updates + 1
                continue

            e['keywords'] = []
            if notice['reboot_suggested']:
                kw = Keyword()
                kw.populate({'keyword':'reboot_suggested'})
                e['keywords'].append(kw)
            if notice['restart_suggested']:
                kw = Keyword()
                kw.populate({'keyword':'restart_suggested'})
                e['keywords'].append(kw)
            e['bugs'] = []
            e['cve'] = []
            if notice['references']:
                bzs = filter(lambda r: r['type'] == 'bugzilla', notice['references'])
                if len(bzs):
                    tmp = {}
                    for bz in bzs:
                        if bz['id'] not in tmp:
                            bug = Bug()
                            bug.populate({'bug_id' : bz['id'], 'summary' : bz['title'], 'href' : bz['href']})
                            e['bugs'].append(bug)
                            tmp[bz['id']] = None
                cves = filter(lambda r: r['type'] == 'cve', notice['references'])
                if len(cves):
                    tmp = {}
                    for cve in cves:
                        if cve['id'] not in tmp:
                            e['cve'].append(cve['id'])
                            tmp[cve['id']] = None
            e['locally_modified'] = None
            batch.append(e)

        if skipped_updates > 0:
            self.print_msg("%d errata skipped because of empty package list." % skipped_updates)
        backend = SQLBackend()
        importer = ErrataImport(batch, backend)
        importer.run()
        self.regen = True

    def import_packages(self, plug, url):
        packages = plug.list_packages()
        to_process = []
        self.print_msg("Repo " + url + " has " + str(len(packages)) + " packages.")
        for pack in packages:
            path, package_channel = rhnPackage.get_path_for_package(
                   [pack.name, pack.version, pack.release, pack.epoch, pack.arch],
                   self.channel_label)

            to_download = False
            to_link     = False
            if not path:
                # package is not on disk
                to_download = True
            else:
                # a different package is on disk
                pack.path = os.path.join(CFG.MOUNT_POINT, path)
                if not self.match_package_checksum(pack.path,
                                pack.checksum_type, pack.checksum):
                    to_download = True

            if package_channel != self.channel_label:
                # package is not in the channel
                to_link = True

            if to_download or to_link:
                to_process.append((pack, to_download, to_link))

        num_to_process = len(to_process)
        if num_to_process == 0:
            self.print_msg("No new packages to sync.")
            return

        self.regen=True
        is_non_local_repo = (url.find("file://") < 0)
        # try/except/finally doesn't work in python 2.4 (RHEL5), so here's a hack
        def finally_remove(path):
            if is_non_local_repo and path and os.path.exists(path):
                os.remove(path)

        for (index, what) in enumerate(to_process):
            pack, to_download, to_link = what
            localpath = None
            try:
                self.print_msg("%d/%d : %s" % (index+1, num_to_process, pack.getNVREA()))
                if to_download:
                    pack.path = localpath = plug.get_package(pack)
                pack.load_checksum_from_header()
                if to_download:
                    self.upload_package(pack)
                    finally_remove(localpath)
                if to_link:
                    self.associate_package(pack)
            except KeyboardInterrupt:
                finally_remove(localpath)
                raise
            except Exception, e:
                self.error_msg(e)
                finally_remove(localpath)
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
        package.payload_stream.close()

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

    def _to_db_date(self, date):
        ret = ""
        if date.isdigit():
          ret = datetime.fromtimestamp(float(date)).isoformat(' ')
        else:
          # we expect to get ISO formated date
          ret = date
        return ret

    def fix_notice(self, notice):
        if "." in notice['version']:
            new_version = 0
            for n in notice['version'].split('.'):
                new_version = (new_version + int(n)) * 100
            try:
                notice['version'] = new_version / 100
            except TypeError: # yum in RHEL5 does not have __setitem__
                notice._md['version'] = new_version / 100
        if "suse" in notice['from'].lower():
            # suse style; we need to append the version to id
            try:
                notice['update_id'] = notice['update_id'] + '-' + notice['version']
            except TypeError: # yum in RHEL5 does not have __setitem__
                notice._md['update_id'] = notice['update_id'] + '-' + notice['version']
        return notice

    def get_errata(self, update_id):
        h = rhnSQL.prepare("""select
            e.id, e.advisory, e.advisory_name, e.advisory_rel
            from rhnerrata e
            where e.advisory = :name
        """)
        h.execute(name=update_id)
        ret = h.fetchone_dict() or None
        if not ret:
            return None

        h = rhnSQL.prepare("""select distinct c.label
            from rhnchannelerrata ce
            join rhnchannel c on c.id = ce.channel_id
            where ce.errata_id = :eid
        """)
        h.execute(eid=ret['id'])
        channels = h.fetchall_dict() or []

        ret['channels'] = channels
        ret['packages'] = []

        h = rhnSQL.prepare("""
            select p.id as package_id,
                   pn.name,
                   pevr.epoch,
                   pevr.version,
                   pevr.release,
                   pa.label as arch,
                   p.org_id,
                   cv.checksum,
                   cv.checksum_type
              from rhnerratapackage ep
              join rhnpackage p on p.id = ep.package_id
              join rhnpackagename pn on pn.id = p.name_id
              join rhnpackageevr pevr on pevr.id = p.evr_id
              join rhnpackagearch pa on pa.id = p.package_arch_id
              join rhnchecksumview cv on cv.id = p.checksum_id
             where ep.errata_id = :eid
        """)
        h.execute(eid=ret['id'])
        packages = h.fetchall_dict() or []
        for pkg in packages:
            ipackage = IncompletePackage()
            for k in pkg.keys():
                ipackage[k] = pkg[k]
            ipackage['epoch'] = pkg.get('epoch', '')

            ipackage['checksums'] = {ipackage['checksum_type'] : ipackage['checksum']}
            ret['packages'].append(ipackage)

        return ret


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
        self.file.close()
