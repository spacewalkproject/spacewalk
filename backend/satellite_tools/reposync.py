#
# Copyright (c) 2008--2012 Red Hat, Inc.
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
import hashlib
import os
import re
import shutil
import sys
import time
from datetime import datetime

from spacewalk.server import rhnPackage, rhnSQL, rhnChannel, rhnPackageUpload
from spacewalk.common import fileutils, rhnLog, rhn_pkg
from spacewalk.common.rhnLog import log_debug
from spacewalk.common.checksum import getFileChecksum
from spacewalk.common.rhnConfig import CFG, initCFG
from spacewalk.common.rhnException import rhnFault
from spacewalk.server.importlib.importLib import IncompletePackage, Erratum, Bug, Keyword
from spacewalk.server.importlib.packageImport import ChannelPackageSubscription
from spacewalk.server.importlib.backendOracle import SQLBackend
from spacewalk.server.importlib.errataImport import ErrataImport
from spacewalk.server import taskomatic

from urlgrabber.grabber import URLGrabError

default_log_location = '/var/log/rhn/reposync/'
relative_comps_dir   = 'rhn/comps'
default_hash = 'sha256'

def set_filter_opt(option, opt_str, value, parser):
    if opt_str in [ '--include', '-i']: f_type = '+'
    else:                               f_type = '-'
    parser.values.filters.append((f_type, re.split('[,\s]+', value)))


class RepoSync(object):
    def __init__(self, channel_label, repo_type, url=None, fail=False,
                 quiet=False, filters=[], no_errata = False, sync_kickstart = False):
        self.regen = False
        self.fail = fail
        self.quiet = quiet
        self.filters = filters
        self.no_errata = no_errata
        self.sync_kickstart = sync_kickstart

        initCFG('server')
        rhnSQL.initDB()

        # setup logging
        log_filename = channel_label + '.log'
        rhnLog.initLOG(default_log_location + log_filename)
        #os.fchown isn't in 2.4 :/
        os.system("chgrp apache " + default_log_location + log_filename)

        self.log_msg("\nSync started: %s" % (time.asctime(time.localtime())))
        self.log_msg(str(sys.argv))

        self.channel_label = channel_label
        self.channel = self.load_channel()
        if not self.channel or not rhnChannel.isCustomChannel(self.channel['id']):
            self.print_msg("Channel does not exist or is not custom.")
            sys.exit(1)

        if not url:
            # TODO:need to look at user security across orgs
            h = rhnSQL.prepare("""select s.id, s.source_url, s.label
                                  from rhnContentSource s,
                                       rhnChannelContentSource cs
                                 where s.id = cs.source_id
                                   and cs.channel_id = :channel_id""")
            h.execute(channel_id=int(self.channel['id']))
            source_data = h.fetchall_dict()
            if source_data:
                self.urls = [(row['id'], row['source_url'], row['label']) for row in source_data]
            else:
                self.error_msg("Channel has no URL associated")
                sys.exit(1)
        else:
            self.urls = [(None, url, None)]

        self.repo_plugin = self.load_plugin(repo_type)

    def sync(self):
        """Trigger a reposync"""
        start_time = datetime.now()
        for (repo_id, url, repo_label) in self.urls:
            self.print_msg("Repo URL: %s" % url)
            plugin = None
            try:
                plugin = self.repo_plugin(url, self.channel_label)
                if repo_id is not None:
                    keys = rhnSQL.fetchone_dict("""
                        select k1.key as ca_cert, k2.key as client_cert, k3.key as client_key
                        from rhncontentsourcessl
                                join rhncryptokey k1
                                on rhncontentsourcessl.ssl_ca_cert_id = k1.id
                                left outer join rhncryptokey k2
                                on rhncontentsourcessl.ssl_client_cert_id = k2.id
                                left outer join rhncryptokey k3
                                on rhncontentsourcessl.ssl_client_key_id = k3.id
                        where rhncontentsourcessl.content_source_id = :repo_id
                        """, repo_id=int(repo_id))
                    if keys and keys.has_key('ca_cert'):
                        plugin.set_ssl_options(keys['ca_cert'], keys['client_cert'], keys['client_key'])
                self.import_packages(plugin, repo_id, url)
                self.import_groups(plugin, url)

                if not self.no_errata:
                    self.import_updates(plugin, url)
                if self.sync_kickstart:
                    try:
                        self.import_kickstart(plugin, url, repo_label)
                    except:
                        rhnSQL.rollback()
                        raise
            except Exception, e:
                self.error_msg("ERROR: %s" % e)
            if plugin is not None:
                plugin.clear_ssl_cache()
        if self.regen:
            taskomatic.add_to_repodata_queue_for_channel_package_subscription(
                [self.channel_label], [], "server.app.yumreposync")
            taskomatic.add_to_erratacache_queue(self.channel_label)
        self.update_date()
        rhnSQL.commit()
        total_time = datetime.now() - start_time
        self.print_msg("Sync completed.")
        self.print_msg("Total time: %s" % str(total_time).split('.')[0])


    def update_date(self):
        """ Updates the last sync time"""
        h = rhnSQL.prepare( """update rhnChannel set LAST_SYNCED = current_timestamp
                             where label = :channel""")
        h.execute(channel=self.channel['label'])

    def load_plugin(self, repo_type):
        name = repo_type + "_src"
        mod = __import__('spacewalk.satellite_tools.repo_plugins', globals(), locals(), [name])
        submod = getattr(mod, name)
        return getattr(submod, "ContentSource")

    def import_updates(self, plug, url):
        notices = plug.get_updates()
        self.print_msg("Repo %s has %s errata." % (url, len(notices)))
        if notices:
            self.upload_updates(notices)

    def import_groups(self, plug, url):
        groupsfile = plug.get_groups()
        if groupsfile:
            basename = os.path.basename(groupsfile)
            self.print_msg("Repo %s has comps file %s." % (url, basename))
            relativedir =  os.path.join(relative_comps_dir, self.channel_label)
            absdir =  os.path.join(CFG.MOUNT_POINT, relativedir)
            if not os.path.exists(absdir):
                os.makedirs(absdir)
            relativepath = os.path.join(relativedir, basename)
            abspath =  os.path.join(absdir, basename)
            for suffix in ['.gz', '.bz']:
                if basename.endswith(suffix):
                    abspath = abspath.rstrip(suffix)
                    relativepath = relativepath.rstrip(suffix)
            src = fileutils.decompress_open(groupsfile)
            dst = open(abspath, "w")
            shutil.copyfileobj(src,dst)
            dst.close()
            src.close()
            # update or insert
            hu = rhnSQL.prepare("""update rhnChannelComps
                                      set relative_filename = :relpath,
                                          modified = current_timestamp
                                    where channel_id = :cid""")
            hu.execute(cid=self.channel['id'], relpath=relativepath)

            hi = rhnSQL.prepare("""insert into rhnChannelComps
                                  (id, channel_id, relative_filename)
                                  (select sequence_nextval('rhn_channelcomps_id_seq'),
                                          :cid,
                                          :relpath
                                     from dual
                                    where not exists (select 1 from rhnChannelComps
                                                       where channel_id = :cid))""")
            hi.execute(cid=self.channel['id'], relpath=relativepath)

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
            e['product']       = notice['release'] or 'Unknown'
            e['description']   = notice['description']
            e['synopsis']      = notice['title'] or notice['update_id']
            if (notice['type'] == 'security' and notice['severity'] and
                not e['synopsis'].startswith(notice['severity'] + ': ')):
                e['synopsis'] = notice['severity'] + ': ' + e['synopsis']
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
                             'channel_id'    : int(self.channel['id']),
                             }
                if pkg['epoch'] == '0':
                    epochStatement = "(pevr.epoch is NULL or pevr.epoch = '0')"
                elif pkg['epoch'] is None or pkg['epoch'] == '':
                    epochStatement = "pevr.epoch is NULL"
                else:
                    epochStatement = "pevr.epoch = :epoch"
                    param_dict['epoch'] = pkg['epoch']
                if self.channel['org_id']:
                    param_dict['org_id'] = self.channel['org_id']
                    orgStatement = "= :org_id"
                else:
                    orgStatement = "is NULL"

                h = rhnSQL.prepare("""
                    select p.id, pevr.epoch, c.checksum, c.checksum_type
                      from rhnPackage p
                      join rhnPackagename pn on p.name_id = pn.id
                      join rhnpackageevr pevr on p.evr_id = pevr.id
                      join rhnpackagearch pa on p.package_arch_id = pa.id
                      join rhnArchType at on pa.arch_type_id = at.id
                      join rhnChecksumView c on p.checksum_id = c.id
                      join rhnChannelPackage cp on p.id = cp.package_id
                     where pn.name = :name
                       and p.org_id %s
                       and pevr.version = :version
                       and pevr.release = :release
                       and pa.label = :arch
                       and %s
                       and at.label = 'rpm'
                       and cp.channel_id = :channel_id
                """ % (orgStatement, epochStatement))
                h.execute(**param_dict)
                cs = h.fetchone_dict() or None

                if not cs:
                    if param_dict.has_key('epoch'):
                        epoch = param_dict['epoch'] + ":"
                    else:
                        epoch = ""
                    log_debug(1, "No checksum found for %s-%s%s-%s.%s."
                                 " Skipping Package" % (param_dict['name'],
                                                        epoch,
                                                        param_dict['version'],
                                                        param_dict['release'],
                                                        param_dict['arch']
                                                        ))
                    continue

                newpkgs = []
                for oldpkg in e['packages']:
                    if oldpkg['package_id'] != cs['id']:
                        newpkgs.append(oldpkg)

                package = IncompletePackage().populate(pkg)
                package['epoch'] = cs['epoch']
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

    def import_packages(self, plug, source_id, url):
        if (not self.filters) and source_id:
            h = rhnSQL.prepare("""
                    select flag, filter
                      from rhnContentSourceFilter
                     where source_id = :source_id
                     order by sort_order """)
            h.execute(source_id = source_id)
            filter_data = h.fetchall_dict() or []
            filters = [(row['flag'], re.split('[,\s]+', row['filter']))
                                                         for row in filter_data]
        else:
            filters = self.filters

        packages = plug.list_packages(filters)
        to_process = []
        num_passed = len(packages)
        self.print_msg("Packages in repo:             %5d" % plug.num_packages)
        if plug.num_excluded:
            self.print_msg("Packages passed filter rules: %5d" % num_passed)
        channel_id = int(self.channel['id'])
        for pack in packages:
            db_pack = rhnPackage.get_info_for_package(
                   [pack.name, pack.version, pack.release, pack.epoch, pack.arch],
                   channel_id, int(self.channel['org_id']))

            to_download = True
            to_link     = True
            if db_pack['path']:
                pack.path = os.path.join(CFG.MOUNT_POINT, db_pack['path'])
                if self.match_package_checksum(pack.path,
                                pack.checksum_type, pack.checksum):
                    # package is already on disk
                    to_download = False
                    if db_pack['channel_id'] == channel_id:
                        # package is already in the channel
                        to_link = False
                elif db_pack['channel_id'] == channel_id:
                    # different package with SAME NVREA
                    self.disassociate_package(db_pack)

            if to_download or to_link:
                to_process.append((pack, to_download, to_link))

        num_to_process = len(to_process)
        if num_to_process == 0:
            self.print_msg("No new packages to sync.")
            return
        else:
            self.print_msg("Packages already synced:      %5d" %
                                                  (num_passed - num_to_process))
            self.print_msg("Packages to sync:             %5d" % num_to_process)

        self.regen=True
        is_non_local_repo = (url.find("file://") < 0)

        def finally_remove(path):
            if is_non_local_repo and path and os.path.exists(path):
                os.remove(path)

        # try/except/finally doesn't work in python 2.4 (RHEL5), so here's a hack
        for (index, what) in enumerate(to_process):
            pack, to_download, to_link = what
            localpath = None
            try:
                self.print_msg("%d/%d : %s" % (index+1, num_to_process, pack.getNVREA()))
                if to_download:
                    pack.path = localpath = plug.get_package(pack)
                pack.load_checksum_from_header()
                if to_download:
                    pack.upload_package(self.channel)
                    finally_remove(localpath)
            except KeyboardInterrupt:
                finally_remove(localpath)
                raise
            except Exception, e:
                self.error_msg(e)
                finally_remove(localpath)
                if self.fail:
                    raise
                to_process[index] = (pack, False, False)
                continue

        self.print_msg("Linking packages to channel.")
        import_batch = [self.associate_package(pack)
                                for (pack, to_download, to_link) in to_process
                                        if to_link]
        backend = SQLBackend()
        caller = "server.app.yumreposync"
        importer = ChannelPackageSubscription(import_batch,
                        backend, caller=caller, repogen=False)
        importer.run()
        backend.commit()

    def match_package_checksum(self, abspath, checksum_type, checksum):
        if (os.path.exists(abspath) and
            getFileChecksum(checksum_type, filename=abspath) == checksum):
            return 1
        return 0

    def associate_package(self, pack):
        package = {}
        package['name'] = pack.name
        package['version'] = pack.version
        package['release'] = pack.release
        package['arch'] = pack.arch
        package['checksum'] = pack.a_pkg.checksum
        package['checksum_type'] = pack.a_pkg.checksum_type
        package['channels']  = [{'label':self.channel_label,
                                 'id':self.channel['id']}]
        package['org_id'] = self.channel['org_id']
        # use epoch from file header because createrepo puts epoch="0" to
        # primary.xml even for packages with epoch=''
        package['epoch'] = pack.a_pkg.header['epoch']

        return IncompletePackage().populate(package)

    def disassociate_package(self, pack):
        h = rhnSQL.prepare("""
            delete from rhnChannelPackage cp
             where cp.channel_id = :channel_id
               and cp.package_id in (select p.id
                                       from rhnPackage p
                                       join rhnChecksumView c
                                         on p.checksum_id = c.id
                                      where c.checksum = :checksum
                                        and c.checksum_type = :checksum_type
                                    )
                """)
        h.execute(channel_id=self.channel['id'],
                  checksum_type=pack['checksum_type'], checksum=pack['checksum'])

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
        return ret[:19] #return 1st 19 letters of date, therefore preventing ORA-01830 caused by fractions of seconds

    def fix_notice(self, notice):
        if "." in notice['version']:
            new_version = 0
            for n in notice['version'].split('.'):
                new_version = (new_version + int(n)) * 100
            try:
                notice['version'] = new_version / 100
            except TypeError: # yum in RHEL5 does not have __setitem__
                notice._md['version'] = new_version / 100
        if notice['from'] and "suse" in notice['from'].lower():
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
            ipackage = IncompletePackage().populate(pkg)
            ipackage['epoch'] = pkg.get('epoch', '')

            ipackage['checksums'] = {ipackage['checksum_type'] : ipackage['checksum']}
            ret['packages'].append(ipackage)

        return ret

    def import_kickstart(self, plug, url, repo_label):
        pxeboot_path = 'images/pxeboot/'
        pxeboot = plug.get_file(pxeboot_path)
        if pxeboot is None:
            if not re.search(r'/$', url):
                url = url + '/'
            self.error_msg("ERROR: kickstartable tree not detected (no %s%s)" % (url, pxeboot_path))
            return
        channel_id = int(self.channel['id'])

        if rhnSQL.fetchone_dict("""
            select id
            from rhnKickstartableTree
            where org_id = :org_id and channel_id = :channel_id and label = :label
            """, org_id = self.channel['org_id'], channel_id = self.channel['id'], label = repo_label):
            print "Kickstartable tree %s already synced." % repo_label
            return

        row = rhnSQL.fetchone_dict("""
            select sequence_nextval('rhn_kstree_id_seq') as id from dual
            """)
        ks_id = row['id']
        ks_path = 'rhn/kickstart/%s/%s' % ( self.channel['org_id'], repo_label )

        row = rhnSQL.execute("""
            insert into rhnKickstartableTree (id, org_id, label, base_path, channel_id,
                        kstree_type, install_type, last_modified, created, modified)
            values (:id, :org_id, :label, :base_path, :channel_id,
                        ( select id from rhnKSTreeType where label = 'externally-managed'),
                        ( select id from rhnKSInstallType where label = 'generic_rpm'),
                        current_timestamp, current_timestamp, current_timestamp)
            """, id = ks_id, org_id = self.channel['org_id'], label = repo_label,
                base_path = os.path.join(CFG.MOUNT_POINT, ks_path), channel_id = self.channel['id'])

        insert_h = rhnSQL.prepare("""
            insert into rhnKSTreeFile (kstree_id, relative_filename, checksum_id, file_size, last_modified, created, modified)
            values (:id, :path, lookup_checksum('sha256', :checksum), :st_size, epoch_seconds_to_timestamp_tz(:st_time), current_timestamp, current_timestamp)
            """)
        dirs = [ '' ]
        while len(dirs) > 0:
            d = dirs.pop(0)
            v = None
            if d == pxeboot_path:
                v = pxeboot
            else:
                v = plug.get_file(d)
            if v is None:
                continue

            for s in (m.group(1) for m in re.finditer(r'(?i)<a href="(.+?)"', v)):
                if re.match(r'/', s) or re.search(r'\?', s) or re.search(r'\.\.', s) or re.match(r'[a-zA-Z]+:', s) or re.search(r'\.rpm$', s):
                    continue
                if re.search(r'/$', s):
                    dirs.append(d + s)
                    continue
                local_path = os.path.join(CFG.MOUNT_POINT, ks_path, d, s)
                if os.path.exists(local_path):
                    print "File %s%s already present locally" % (d, s)
                else:
                    print "Retrieving %s" % d + s
                    plug.get_file(d + s, os.path.join(CFG.MOUNT_POINT, ks_path))
                st = os.stat(local_path)
                insert_h.execute(id = ks_id, path = d + s, checksum = getFileChecksum('sha256', local_path), st_size = st.st_size, st_time = st.st_mtime)

        rhnSQL.commit()

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

        self.a_pkg = None

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
        self.a_pkg = rhn_pkg.package_from_stream(self.file, packaging='rpm')
        self.a_pkg.read_header()
        self.a_pkg.payload_checksum()
        self.file.close()

    def upload_package(self, channel):
        rel_package_path = rhnPackageUpload.relative_path_from_header(
                self.a_pkg.header, channel['org_id'],
                self.a_pkg.checksum_type, self.a_pkg.checksum)
        package_dict, diff_level = rhnPackageUpload.push_package(self.a_pkg,
                force=False,
                relative_path=rel_package_path,
                org_id=channel['org_id'])
