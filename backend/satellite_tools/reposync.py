#
# Copyright (c) 2008--2016 Red Hat, Inc.
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
import os
import re
import shutil
import sys
import time
from datetime import datetime
from HTMLParser import HTMLParser

from spacewalk.server import rhnPackage, rhnSQL, rhnChannel
from spacewalk.common import fileutils, rhnLog
from spacewalk.common.rhnLog import log_debug
from spacewalk.common.rhnLib import isSUSE
from spacewalk.common.checksum import getFileChecksum
from spacewalk.common.rhnConfig import CFG, initCFG
from spacewalk.server.importlib.importLib import IncompletePackage, Erratum, Bug, Keyword
from spacewalk.server.importlib.packageImport import ChannelPackageSubscription
from spacewalk.server.importlib.backendOracle import SQLBackend
from spacewalk.server.importlib.errataImport import ErrataImport
from spacewalk.server import taskomatic


default_log_location = '/var/log/rhn/reposync/'
relative_comps_dir = 'rhn/comps'
default_hash = 'sha256'


class KSDirParser(HTMLParser):
    def __init__(self):
        HTMLParser.__init__(self)
        self.tmp_type = ""
        self.tmp_datetime = ""
        self.tmp_name = ""
        self.current_tag = "dummy_tag"  # this tag doesn't exist in document
        self.dir_content = []

    def get_content(self):
        return self.dir_content

    def handle_starttag(self, tag, attributes):
        self.current_tag = tag
        if tag == 'img':
            for name, value in attributes:
                if name == 'alt':
                    self.tmp_type = value.strip('[]')

        elif tag == 'a':
            for name, value in attributes:
                if name == 'href':
                    self.tmp_name = value

    def handle_data(self, data):
        if self.current_tag == "":
            # data without tag is the last modification date
            self.tmp_datetime = data.strip().split()[0] + " " + data.strip().split()[1]
            self.dir_content.append({
                'name': self.tmp_name,
                'type': self.tmp_type,
                'datetime': self.tmp_datetime,
            })
        else:
            self.current_tag = ""


def set_filter_opt(option, opt_str, value, parser):
    # pylint: disable=W0613
    if opt_str in ['--include', '-i']:
        f_type = '+'
    else:
        f_type = '-'
    parser.values.filters.append((f_type, re.split(r'[,\s]+', value)))


def getChannelRepo():

    initCFG('server.satellite')
    rhnSQL.initDB()
    items = {}
    sql = """
           select s.source_url, c.label
                       from rhnContentSource s,
                       rhnChannelContentSource cs,
                       rhnChannel c
                       where s.id = cs.source_id and cs.channel_id=c.id
           """
    h = rhnSQL.prepare(sql)
    h.execute()
    while 1:
        row = h.fetchone_dict()
        if not row:
            break
        if not row['label'] in items:
            items[row['label']] = []
        items[row['label']] += [row['source_url']]

    return items


def getParentsChilds(b_only_custom=False):

    initCFG('server.satellite')
    rhnSQL.initDB()

    sql = """
        select c1.label, c2.label parent_channel, c1.id
        from rhnChannel c1 left outer join rhnChannel c2 on c1.parent_channel = c2.id
        order by c2.label desc, c1.label asc
    """
    h = rhnSQL.prepare(sql)
    h.execute()
    d_parents = {}
    while 1:
        row = h.fetchone_dict()
        if not row:
            break
        if not b_only_custom or rhnChannel.isCustomChannel(row['id']):
            parent_channel = row['parent_channel']
            if not parent_channel:
                d_parents[row['label']] = []
            else:
                # If the parent is not a custom channel treat the child like
                # it's a parent for our purposes
                if parent_channel not in d_parents:
                    d_parents[row['label']] = []
                else:
                    d_parents[parent_channel].append(row['label'])

    return d_parents


def getCustomChannels():

    d_parents = getParentsChilds(True)
    l_custom_ch = []

    for ch in d_parents:
        l_custom_ch += [ch] + d_parents[ch]

    return l_custom_ch


class RepoSync(object):

    def __init__(self, channel_label, repo_type, url=None, fail=False,
                 quiet=False, filters=None, no_errata=False, sync_kickstart=False, latest=False,
                 metadata_only=False, strict=0, excluded_urls=None, no_packages=False):
        self.regen = False
        self.fail = fail
        self.quiet = quiet
        self.filters = filters or []
        self.no_packages = no_packages
        self.no_errata = no_errata
        self.sync_kickstart = sync_kickstart
        self.latest = latest
        self.metadata_only = metadata_only
        self.ks_tree_type = 'externally-managed'
        self.ks_install_type = 'generic_rpm'

        initCFG('server.satellite')
        rhnSQL.initDB()

        # setup logging
        log_filename = channel_label + '.log'
        if CFG.DEBUG is not None:
            log_level = CFG.DEBUG

        rhnLog.initLOG(default_log_location + log_filename, log_level)
        # os.fchown isn't in 2.4 :/
        if isSUSE():
            os.system("chgrp www " + default_log_location + log_filename)
        else:
            os.system("chgrp apache " + default_log_location + log_filename)

        self.log_msg("\nSync started: %s" % (time.asctime(time.localtime())))
        self.log_msg(str(sys.argv))

        self.channel_label = channel_label
        self.channel = self.load_channel()
        if not self.channel:
            self.print_msg("Channel %s does not exist." % channel_label)

        if not url:
            # TODO:need to look at user security across orgs
            h = rhnSQL.prepare("""select s.id, s.source_url, s.label, fm.channel_family_id
                                  from rhnContentSource s,
                                       rhnChannelContentSource cs,
                                       rhnChannelFamilyMembers fm
                                 where s.id = cs.source_id
                                   and cs.channel_id = fm.channel_id
                                   and cs.channel_id = :channel_id""")
            h.execute(channel_id=int(self.channel['id']))
            source_data = h.fetchall_dict()
            self.urls = []
            if excluded_urls is None:
                excluded_urls = []
            if source_data:
                for row in source_data:
                    if row['source_url'] not in excluded_urls:
                        self.urls.append((row['id'], row['source_url'], row['label'], row['channel_family_id']))
        else:
            self.urls = [(None, u, None, None) for u in url]

        if not self.urls:
            self.error_msg("Channel %s has no URL associated" % channel_label)

        self.repo_plugin = self.load_plugin(repo_type)
        self.strict = strict
        self.all_packages = []

    def sync(self):
        """Trigger a reposync"""
        start_time = datetime.now()
        for (repo_id, url, repo_label, channel_family_id) in self.urls:
            print("")
            self.print_msg("Repo URL: %s" % url)
            plugin = None

            # If the repository uses a uln:// URL, switch to the ULN plugin, overriding the command-line
            if url.startswith("uln://"):
                self.repo_plugin = self.load_plugin("uln")

            # pylint: disable=W0703
            try:
                # use modified relative_url as name of repo plugin, because
                # it used as name of cache directory
                plugin_name = '_'.join(url.split('://')[1].split('/')[1:])

                plugin = self.repo_plugin(url, plugin_name)
                if repo_id is not None:
                    keys = rhnSQL.fetchone_dict("""
                        select k1.key as ca_cert, k2.key as client_cert, k3.key as client_key
                        from rhncontentssl
                                join rhncryptokey k1
                                on rhncontentssl.ssl_ca_cert_id = k1.id
                                left outer join rhncryptokey k2
                                on rhncontentssl.ssl_client_cert_id = k2.id
                                left outer join rhncryptokey k3
                                on rhncontentssl.ssl_client_key_id = k3.id
                        where rhncontentssl.content_source_id = :repo_id
                        or rhncontentssl.channel_family_id = :channel_family_id
                        """, repo_id=int(repo_id), channel_family_id=int(channel_family_id))
                    if keys and ('ca_cert' in keys):
                        plugin.set_ssl_options(keys['ca_cert'], keys['client_cert'], keys['client_key'])

                if not self.no_packages:
                    self.import_packages(plugin, repo_id, url)
                    self.import_groups(plugin, url)

                if not self.no_errata:
                    self.import_updates(plugin, url)

                # only for repos obtained from the DB
                if self.sync_kickstart and repo_label:
                    try:
                        self.import_kickstart(plugin, url, repo_label)
                    except:
                        rhnSQL.rollback()
                        raise
            except Exception:
                e = sys.exc_info()[1]
                self.error_msg("ERROR: %s" % e)
            if plugin is not None:
                plugin.clear_ssl_cache()
        if self.regen:
            taskomatic.add_to_repodata_queue_for_channel_package_subscription(
                [self.channel_label], [], "server.app.yumreposync")
            taskomatic.add_to_erratacache_queue(self.channel_label)
        self.update_date()
        rhnSQL.commit()
        elapsed_time = datetime.now() - start_time
        self.print_msg("Sync of channel completed in %s." % str(elapsed_time).split('.')[0])
        return elapsed_time

    def set_ks_tree_type(self, tree_type='externally-managed'):
        self.ks_tree_type = tree_type

    def set_ks_install_type(self, install_type='generic_rpm'):
        self.ks_install_type = install_type

    def update_date(self):
        """ Updates the last sync time"""
        h = rhnSQL.prepare("""update rhnChannel set LAST_SYNCED = current_timestamp
                             where label = :channel""")
        h.execute(channel=self.channel['label'])

    @staticmethod
    def load_plugin(repo_type):
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
            relativedir = os.path.join(relative_comps_dir, self.channel_label)
            absdir = os.path.join(CFG.MOUNT_POINT, relativedir)
            if not os.path.exists(absdir):
                os.makedirs(absdir)
            relativepath = os.path.join(relativedir, basename)
            abspath = os.path.join(absdir, basename)
            for suffix in ['.gz', '.bz', '.xz']:
                if basename.endswith(suffix):
                    abspath = abspath.rstrip(suffix)
                    relativepath = relativepath.rstrip(suffix)
            src = fileutils.decompress_open(groupsfile)
            dst = open(abspath, "w")
            shutil.copyfileobj(src, dst)
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
        typemap = {
            'security': 'Security Advisory',
            'recommended': 'Bug Fix Advisory',
            'bugfix': 'Bug Fix Advisory',
            'optional': 'Product Enhancement Advisory',
            'feature': 'Product Enhancement Advisory',
            'enhancement': 'Product Enhancement Advisory'
        }
        for notice in notices:
            notice = self.fix_notice(notice)
            advisory = notice['update_id'] + '-' + notice['version']
            existing_errata = self.get_errata(notice['update_id'])

            e = Erratum()
            e['errata_from'] = notice['from']
            e['advisory'] = advisory
            e['advisory_name'] = notice['update_id']
            e['advisory_rel'] = notice['version']
            e['advisory_type'] = typemap.get(notice['type'], 'Product Enhancement Advisory')
            e['product'] = notice['release'] or 'Unknown'
            e['description'] = notice['description']
            e['synopsis'] = notice['title'] or notice['update_id']
            if (notice['type'] == 'security' and notice['severity'] and
                    not e['synopsis'].startswith(notice['severity'] + ': ')):
                e['synopsis'] = notice['severity'] + ': ' + e['synopsis']
            if 'summary' in notice and not notice['summary'] is None:
                e['topic'] = notice['summary']
            else:
                e['topic'] = ' '
            if 'solution' in notice and not notice['solution'] is None:
                e['solution'] = notice['solution']
            else:
                e['solution'] = ' '
            e['issue_date'] = self._to_db_date(notice['issued'])
            if notice['updated']:
                e['update_date'] = self._to_db_date(notice['updated'])
            else:
                e['update_date'] = self._to_db_date(notice['issued'])
            e['org_id'] = self.channel['org_id']
            e['notes'] = ''
            e['channels'] = []
            e['packages'] = []
            e['files'] = []
            if existing_errata:
                e['channels'] = existing_errata['channels']
                e['packages'] = existing_errata['packages']
            e['channels'].append({'label': self.channel_label})

            for pkg in notice['pkglist'][0]['packages']:
                param_dict = {
                    'name': pkg['name'],
                    'version': pkg['version'],
                    'release': pkg['release'],
                    'arch': pkg['arch'],
                    'channel_id': int(self.channel['id']),
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
                    if 'epoch' in param_dict:
                        epoch = param_dict['epoch'] + ":"
                    else:
                        epoch = ""
                    log_debug(1, "No checksum found for %s-%s%s-%s.%s."
                                 " Skipping Package" % (param_dict['name'],
                                                        epoch,
                                                        param_dict['version'],
                                                        param_dict['release'],
                                                        param_dict['arch']))
                    continue

                newpkgs = []
                for oldpkg in e['packages']:
                    if oldpkg['package_id'] != cs['id']:
                        newpkgs.append(oldpkg)

                package = IncompletePackage().populate(pkg)
                package['epoch'] = cs['epoch']
                package['org_id'] = self.channel['org_id']

                package['checksums'] = {cs['checksum_type']: cs['checksum']}
                package['checksum_type'] = cs['checksum_type']
                package['checksum'] = cs['checksum']

                package['package_id'] = cs['id']
                newpkgs.append(package)

                e['packages'] = newpkgs

            if len(e['packages']) == 0:
                # FIXME: print only with higher debug option
                print("Advisory %s has empty package list." % e['advisory_name'])

            e['keywords'] = []
            if notice['reboot_suggested']:
                kw = Keyword()
                kw.populate({'keyword': 'reboot_suggested'})
                e['keywords'].append(kw)
            if notice['restart_suggested']:
                kw = Keyword()
                kw.populate({'keyword': 'restart_suggested'})
                e['keywords'].append(kw)
            e['bugs'] = []
            e['cve'] = []
            if notice['references']:
                bzs = [r for r in notice['references'] if r['type'] == 'bugzilla']
                if len(bzs):
                    tmp = {}
                    for bz in bzs:
                        if bz['id'] not in tmp:
                            bug = Bug()
                            bug.populate({'bug_id': bz['id'], 'summary': bz['title'], 'href': bz['href']})
                            e['bugs'].append(bug)
                            tmp[bz['id']] = None
                cves = [r for r in notice['references'] if r['type'] == 'cve']
                if len(cves):
                    tmp = {}
                    for cve in cves:
                        if cve['id'] not in tmp:
                            e['cve'].append(cve['id'])
                            tmp[cve['id']] = None
                others = [r for r in notice['references'] if not r['type'] == 'bugzilla' and not r['type'] == 'cve']
                if len(others):
                    tmp = len(others)
                    refers_to = ""
                    for other in others:
                        if refers_to:
                            refers_to += "\n"
                        refers_to += other['href']
                    e['refers_to'] = refers_to
            e['locally_modified'] = None
            batch.append(e)

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
            h.execute(source_id=source_id)
            filter_data = h.fetchall_dict() or []
            filters = [(row['flag'], re.split(r'[,\s]+', row['filter']))
                       for row in filter_data]
        else:
            filters = self.filters

        packages = plug.list_packages(filters, self.latest)
        self.all_packages.extend(packages)
        to_process = []
        num_passed = len(packages)
        self.print_msg("Packages in repo:             %5d" % plug.num_packages)
        if plug.num_excluded:
            self.print_msg("Packages passed filter rules: %5d" % num_passed)
        channel_id = int(self.channel['id'])
        if self.channel['org_id']:
            self.channel['org_id'] = int(self.channel['org_id'])
        else:
            self.channel['org_id'] = None
        for pack in packages:
            db_pack = rhnPackage.get_info_for_package(
                [pack.name, pack.version, pack.release, pack.epoch, pack.arch],
                channel_id, self.channel['org_id'])

            to_download = True
            to_link = True
            # Package exists in DB
            if db_pack:
                # Path in filesystem is defined
                if db_pack['path']:
                    pack.path = os.path.join(CFG.MOUNT_POINT, db_pack['path'])
                else:
                    pack.path = ""

                if self.metadata_only or self.match_package_checksum(pack.path,
                                                                     pack.checksum_type, pack.checksum):
                    # package is already on disk or not required
                    to_download = False
                    if db_pack['channel_id'] == channel_id:
                        # package is already in the channel
                        to_link = False

                elif db_pack['channel_id'] == channel_id:
                    # different package with SAME NVREA
                    self.disassociate_package(db_pack)

                # just pass data from DB, they will be used if there is no RPM available
                pack.checksum = db_pack['checksum']
                pack.checksum_type = db_pack['checksum_type']
                pack.epoch = db_pack['epoch']

            if to_download or to_link:
                to_process.append((pack, to_download, to_link))

        num_to_process = len(to_process)
        if num_to_process == 0:
            self.print_msg("No new packages to sync.")
            # If we are just appending, we can exit
            if not self.strict:
                return
        else:
            self.print_msg("Packages already synced:      %5d" %
                           (num_passed - num_to_process))
            self.print_msg("Packages to sync:             %5d" % num_to_process)

        self.regen = True
        is_non_local_repo = (url.find("file:/") < 0)

        for (index, what) in enumerate(to_process):
            pack, to_download, to_link = what
            localpath = None
            # pylint: disable=W0703
            try:
                self.print_msg("%d/%d : %s" % (index + 1, num_to_process, pack.getNVREA()))
                if to_download:
                    pack.path = localpath = plug.get_package(pack, metadata_only=self.metadata_only)
                    pack.load_checksum_from_header()
                    pack.upload_package(self.channel, metadata_only=self.metadata_only)
            except KeyboardInterrupt:
                raise
            except Exception:
                e = sys.exc_info()[1]
                self.error_msg(e)
                if self.fail:
                    raise
                to_process[index] = (pack, False, False)
                continue
            finally:
                if is_non_local_repo and localpath and os.path.exists(localpath):
                    os.remove(localpath)

        self.print_msg("Linking packages to channel.")
        if self.strict:
            import_batch = [self.associate_package(pack)
                            for pack in self.all_packages]
        else:
            import_batch = [self.associate_package(pack)
                            for (pack, to_download, to_link) in to_process
                            if to_link]
        backend = SQLBackend()
        caller = "server.app.yumreposync"
        importer = ChannelPackageSubscription(import_batch,
                                              backend, caller=caller, repogen=False,
                                              strict=self.strict)
        importer.run()
        backend.commit()

    @staticmethod
    def match_package_checksum(abspath, checksum_type, checksum):
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
        if pack.a_pkg:
            package['checksum'] = pack.a_pkg.checksum
            package['checksum_type'] = pack.a_pkg.checksum_type
            # use epoch from file header because createrepo puts epoch="0" to
            # primary.xml even for packages with epoch=''
            package['epoch'] = pack.a_pkg.header['epoch']
        else:
            # RPM not available but package metadata are in DB, reuse these values
            package['checksum'] = pack.checksum
            package['checksum_type'] = pack.checksum_type
            package['epoch'] = pack.epoch
        package['channels'] = [{'label': self.channel_label,
                                'id': self.channel['id']}]
        package['org_id'] = self.channel['org_id']

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
            print(message)

    def error_msg(self, message):
        rhnLog.log_clean(0, message)
        if not self.quiet:
            sys.stderr.write(str(message) + "\n")

    @staticmethod
    def log_msg(message):
        rhnLog.log_clean(0, message)

    @staticmethod
    def _to_db_date(date):
        ret = ""
        if date.isdigit():
            ret = datetime.fromtimestamp(float(date)).isoformat(' ')
        else:
            # we expect to get ISO formated date
            ret = date
        return ret[:19]  # return 1st 19 letters of date, therefore preventing ORA-01830 caused by fractions of seconds

    @staticmethod
    def fix_notice(notice):
        # pylint: disable=W0212
        if "." in notice['version']:
            new_version = 0
            for n in notice['version'].split('.'):
                new_version = (new_version + int(n)) * 100
            notice['version'] = new_version / 100
        return notice

    @staticmethod
    def get_errata(update_id):
        h = rhnSQL.prepare("""select
            e.id, e.advisory, e.advisory_name, e.advisory_rel
            from rhnerrata e
            where e.advisory_name = :name
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

            ipackage['checksums'] = {ipackage['checksum_type']: ipackage['checksum']}
            ret['packages'].append(ipackage)

        return ret

    def import_kickstart(self, plug, url, repo_label):
        pxeboot_path = 'images/pxeboot/'
        pxeboot = plug.get_file(pxeboot_path)
        if pxeboot is None:
            if not re.search(r'/$', url):
                url += '/'
            self.print_msg("Kickstartable tree not detected (no %s%s)" % (url, pxeboot_path))
            return

        ks_path = 'rhn/kickstart/'
        ks_tree_label = re.sub(r'[^-_0-9A-Za-z@.]', '', repo_label.replace(' ', '_'))

        if len(ks_tree_label) < 4:
            ks_tree_label += "_repo"

        id_request = """
                select id
                from rhnKickstartableTree
                where channel_id = :channel_id and label = :label
                """

        if 'org_id' in self.channel and self.channel['org_id']:
            ks_path += str(self.channel['org_id']) + '/' + CFG.MOUNT_POINT + ks_tree_label
            row = rhnSQL.fetchone_dict(id_request + " and org_id = :org_id", channel_id=self.channel['id'],
                                       label=ks_tree_label, org_id=self.channel['org_id'])
        else:
            ks_path += ks_tree_label
            row = rhnSQL.fetchone_dict(id_request + " and org_id is NULL", channel_id=self.channel['id'],
                                       label=ks_tree_label)

        if row:
            print("Kickstartable tree %s already synced with id = %d. Updating content..." % (ks_tree_label, row['id']))
            ks_id = row['id']
        else:
            row = rhnSQL.fetchone_dict("""
                select sequence_nextval('rhn_kstree_id_seq') as id from dual
                """)
            ks_id = row['id']

            rhnSQL.execute("""
                       insert into rhnKickstartableTree (id, org_id, label, base_path, channel_id, kstree_type,
                                                         install_type, last_modified, created, modified)
                       values (:id, :org_id, :label, :base_path, :channel_id,
                                 ( select id from rhnKSTreeType where label = :ks_tree_type),
                                 ( select id from rhnKSInstallType where label = :ks_install_type),
                                 current_timestamp, current_timestamp, current_timestamp)""", id=ks_id,
                           org_id=self.channel['org_id'], label=ks_tree_label, base_path=ks_path,
                           channel_id=self.channel['id'], ks_tree_type=self.ks_tree_type,
                           ks_install_type=self.ks_install_type)

            print("Added new kickstartable tree %s with id = %d. Downloading content..." % (ks_tree_label, row['id']))

        insert_h = rhnSQL.prepare("""
                insert into rhnKSTreeFile (kstree_id, relative_filename, checksum_id, file_size, last_modified, created,
                 modified) values (:id, :path, lookup_checksum('sha256', :checksum), :st_size,
                 epoch_seconds_to_timestamp_tz(:st_time), current_timestamp, current_timestamp)
        """)

        delete_h = rhnSQL.prepare("""
                delete from rhnKSTreeFile where kstree_id = :id and relative_filename = :path
        """)

        # Downloading/Updating content of KS Tree
        # start from root dir
        dirs_queue = ['']
        while len(dirs_queue) > 0:
            cur_dir_name = dirs_queue.pop(0)
            cur_dir_html = None
            if cur_dir_name == pxeboot_path:
                cur_dir_html = pxeboot
            else:
                cur_dir_html = plug.get_file(cur_dir_name)
            if cur_dir_html is None:
                continue

            parser = KSDirParser()
            parser.feed(cur_dir_html.split('<HR>')[1])

            for ks_file in parser.get_content():
                # do not download rpms, they are already downloaded by self.import_packages()
                if re.search(r'\.rpm$', ks_file['name']) or re.search(r'\.\.', ks_file['name']):
                    continue

                # if this is a directory, just add a name into queue (like BFS algorithm)
                if ks_file['type'] == 'DIR':
                    dirs_queue.append(cur_dir_name + ks_file['name'])
                    continue
                else:
                    local_path = os.path.join(CFG.MOUNT_POINT, ks_path, cur_dir_name, ks_file['name'])
                    need_download = True

                    if os.path.exists(local_path):
                        t = os.path.getmtime(local_path)
                        if ks_file['datetime'] == datetime.utcfromtimestamp(t).strftime('%d-%b-%Y %H:%M'):
                            print("File %s%s already present locally" % (cur_dir_name, ks_file['name']))
                            need_download = False
                            st = os.stat(local_path)
                        else:
                            os.unlink(os.path.join(CFG.MOUNT_POINT, ks_path, cur_dir_name + ks_file['name']))

                    if need_download:
                        for retry in range(3):
                            try:
                                print("Retrieving %s" % cur_dir_name + ks_file['name'])
                                plug.get_file(cur_dir_name + ks_file['name'], os.path.join(CFG.MOUNT_POINT, ks_path))
                                st = os.stat(local_path)
                                break
                            except OSError:  # os.stat if the file wasn't downloaded
                                if retry < 3:
                                    print("Retry download %s: attempt #%d" % (cur_dir_name + ks_file['name'], retry+1))
                                else:
                                    raise

                    # update entity about current file in a database
                    delete_h.execute(id=ks_id, path=(cur_dir_name + ks_file['name']))
                    insert_h.execute(id=ks_id, path=(cur_dir_name + ks_file['name']),
                                     checksum=getFileChecksum('sha256', local_path),
                                     st_size=st.st_size, st_time=st.st_mtime)
        rhnSQL.commit()
