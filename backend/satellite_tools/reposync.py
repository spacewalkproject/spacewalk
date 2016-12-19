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
from datetime import datetime
import ConfigParser

from spacewalk.server import rhnPackage, rhnSQL, rhnChannel
from spacewalk.common import fileutils, rhnLog
from spacewalk.common.rhnLib import isSUSE
from spacewalk.common.checksum import getFileChecksum
from spacewalk.common.rhnConfig import CFG, initCFG
from spacewalk.server.importlib.importLib import IncompletePackage, Erratum, Bug, Keyword
from spacewalk.server.importlib.packageImport import ChannelPackageSubscription
from spacewalk.server.importlib.backendOracle import SQLBackend
from spacewalk.server.importlib.errataImport import ErrataImport
from spacewalk.server import taskomatic

from syncLib import log, log2disk, log2stderr


default_log_location = '/var/log/rhn/'
relative_comps_dir = 'rhn/comps'


class KSDirParser:
    file_blacklist = ["release-notes/"]

    def __init__(self, dir_html):
        self.dir_content = []
        for s in (m.group(1) for m in re.finditer(r'(?i)<a href="(.+?)"', dir_html)):
            if not (re.match(r'/', s) or re.search(r'\?', s) or re.search(r'\.\.', s) or re.match(r'[a-zA-Z]+:', s) or
                    re.search(r'\.rpm$', s)):
                if re.search(r'/$', s):
                    file_type = 'DIR'
                else:
                    file_type = 'FILE'

                if s not in self.file_blacklist:
                    self.dir_content.append({'name': s, 'type': file_type})

    def get_content(self):
        return self.dir_content

class TreeInfoError(Exception):
    pass


class TreeInfoParser(object):
    def __init__(self, filename):
        self.parser = ConfigParser.RawConfigParser()
        # do not lowercase
        self.parser.optionxform = str
        fp = open(filename)
        try:
            try:
                self.parser.readfp(fp)
            except ConfigParser.ParsingError:
                raise TreeInfoError("Could not parse treeinfo file!")
        finally:
            if fp is not None:
                fp.close()

    def get_images(self):
        files = []
        for section_name in self.parser.sections():
            if section_name.startswith('images-') or section_name == 'stage2':
                for item in self.parser.items(section_name):
                    files.append(item[1])
        return files

    def get_family(self):
        for section_name in self.parser.sections():
            if section_name == 'general':
                for item in self.parser.items(section_name):
                    if item[0] == 'family':
                        return item[1]

    def get_major_version(self):
        for section_name in self.parser.sections():
            if section_name == 'general':
                for item in self.parser.items(section_name):
                    if item[0] == 'version':
                        return item[1].split('.')[0]


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
                 filters=None, no_errata=False, sync_kickstart=False, latest=False,
                 metadata_only=False, strict=0, excluded_urls=None, no_packages=False,
                 log_dir="reposync", log_level=None):
        self.regen = False
        self.fail = fail
        self.filters = filters or []
        self.no_packages = no_packages
        self.no_errata = no_errata
        self.sync_kickstart = sync_kickstart
        self.latest = latest
        self.metadata_only = metadata_only
        self.ks_tree_type = 'externally-managed'
        self.ks_install_type = None

        initCFG('server.satellite')
        rhnSQL.initDB()

        # setup logging
        log_filename = channel_label + '.log'
        log_path = default_log_location + log_dir + '/' + log_filename
        if log_level is None:
            log_level = 0
        CFG.set('DEBUG', log_level)
        rhnLog.initLOG(log_path, log_level)
        # os.fchown isn't in 2.4 :/
        if isSUSE():
            os.system("chgrp www " + log_path)
        else:
            os.system("chgrp apache " + log_path)

        log2disk(0, "Command: %s" % str(sys.argv))
        log2disk(0, "Sync of channel started.")

        self.channel_label = channel_label
        self.channel = self.load_channel()
        if not self.channel:
            log(0, "Channel %s does not exist." % channel_label)

        if self.channel['org_id']:
            self.channel['org_id'] = int(self.channel['org_id'])
        else:
            self.channel['org_id'] = None

        if not url:
            # TODO:need to look at user security across orgs
            h = rhnSQL.prepare("""select s.id, s.source_url, s.label
                                  from rhnContentSource s,
                                       rhnChannelContentSource cs
                                 where s.id = cs.source_id
                                   and cs.channel_id = :channel_id""")
            h.execute(channel_id=int(self.channel['id']))
            source_data = h.fetchall_dict()
            self.urls = []
            if excluded_urls is None:
                excluded_urls = []
            if source_data:
                for row in source_data:
                    if row['source_url'] not in excluded_urls:
                        self.urls.append((row['id'], row['source_url'], row['label']))
        else:
            self.urls = [(None, u, None) for u in url]

        if not self.urls:
            log2stderr(0, "Channel %s has no URL associated" % channel_label)
            log2disk(0, "Channel %s has no URL associated" % channel_label)

        self.repo_plugin = self.load_plugin(repo_type)
        self.strict = strict
        self.all_packages = []

    def set_urls_prefix(self, prefix):
        """If there are relative urls in DB, set their real location in runtime"""
        for index, url in enumerate(self.urls):
            # Make list, add prefix, make tuple and save
            url = list(url)
            url[1] = "%s%s" % (prefix, url[1])
            url = tuple(url)
            self.urls[index] = url

    def sync(self, update_repodata=False):
        """Trigger a reposync"""
        if self.urls:
            ret_code = 0
        else:
            ret_code = 1
        start_time = datetime.now()
        for (repo_id, url, repo_label) in self.urls:
            log(0, "Repo URL: %s" % url)
            plugin = None

            # If the repository uses a uln:// URL, switch to the ULN plugin, overriding the command-line
            if url.startswith("uln://"):
                self.repo_plugin = self.load_plugin("uln")

            # pylint: disable=W0703
            try:
                if repo_label:
                    repo_name = repo_label
                else:
                    # use modified relative_url as name of repo plugin, because
                    # it used as name of cache directory as well
                    relative_url = '_'.join(url.split('://')[1].split('/')[1:])
                    repo_name = relative_url.replace("?", "_").replace("&", "_").replace("=", "_")

                plugin = self.repo_plugin(url, repo_name,
                                          org=str(self.channel['org_id'] or ''),
                                          channel_label=self.channel_label)

                if update_repodata:
                    plugin.clear_cache()

                if repo_id is not None:
                    keys = rhnSQL.fetchone_dict("""
                        select k1.key as ca_cert, k2.key as client_cert, k3.key as client_key
                        from rhncontentsource cs
                                join rhncryptokey k1
                                on cs.ssl_ca_cert_id = k1.id
                                left outer join rhncryptokey k2
                                on cs.ssl_client_cert_id = k2.id
                                left outer join rhncryptokey k3
                                on cs.ssl_client_key_id = k3.id
                        where cs.id = :repo_id
                        """, repo_id=int(repo_id))
                    if keys and ('ca_cert' in keys):
                        plugin.set_ssl_options(keys['ca_cert'], keys['client_cert'], keys['client_key'])

                if not self.no_packages:
                    ret = self.import_packages(plugin, repo_id, url)
                    # we check previous ret_code value because we don't want
                    # to override it with new successful one
                    if ret_code == 0:
                        ret_code = ret
                    self.import_groups(plugin, url)

                if not self.no_errata:
                    self.import_updates(plugin, url)

                # only for repos obtained from the DB
                if self.sync_kickstart and repo_label:
                    try:
                        self.import_kickstart(plugin, repo_label)
                    except:
                        rhnSQL.rollback()
                        raise
            except Exception:
                e = sys.exc_info()[1]
                log2stderr(0, "ERROR: %s" % e)
                log2disk(0, "ERROR: %s" % e)
                if ret_code == 0:
                    ret_code = 1
            if plugin is not None:
                plugin.clear_ssl_cache()
        if self.regen:
            taskomatic.add_to_repodata_queue_for_channel_package_subscription(
                [self.channel_label], [], "server.app.yumreposync")
            taskomatic.add_to_erratacache_queue(self.channel_label)
        self.update_date()
        rhnSQL.commit()
        elapsed_time = datetime.now() - start_time
        log(0, "Sync of channel completed in %s." % str(elapsed_time).split('.')[0])
        return elapsed_time, ret_code

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
        log(0, "Repo %s has %s errata." % (url, len(notices)))
        if notices:
            self.upload_updates(notices)

    def import_groups(self, plug, url):
        groupsfile = plug.get_groups()
        if groupsfile:
            basename = os.path.basename(groupsfile)
            log(0, "Repo %s has comps file %s." % (url, basename))
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
                    log(2, "No checksum found for %s-%s%s-%s.%s."
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
                log(2, "Advisory %s has empty package list." % e['advisory_name'])

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
                        try:
                            bz_id = int(bz['id'])
                        # This can happen in some incorrectly generated updateinfo, let's be smart
                        except ValueError:
                            log(2, "Bugzilla assigned to advisory %s has invalid id: %s, trying to get it from URL..."
                                % (e['advisory_name'], bz['id']))
                            bz_id = int(re.search(r"\d+$", bz['href']).group(0))
                        if bz_id not in tmp:
                            bug = Bug()
                            bug.populate({'bug_id': bz_id, 'summary': bz['title'], 'href': bz['href']})
                            e['bugs'].append(bug)
                            tmp[bz_id] = None
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
        ret_code = 0
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
        log(0, "Packages in repo:             %5d" % plug.num_packages)
        if plug.num_excluded:
            log(0, "Packages passed filter rules: %5d" % num_passed)
        channel_id = int(self.channel['id'])

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
            log(0, "No new packages to sync.")
            # If we are just appending, we can exit
            if not self.strict:
                return
        else:
            log(0, "Packages already synced:      %5d" % (num_passed - num_to_process))
            log(0, "Packages to sync:             %5d" % num_to_process)

        self.regen = True
        is_non_local_repo = (url.find("file:/") < 0)

        for (index, what) in enumerate(to_process):
            pack, to_download, to_link = what
            localpath = None
            # pylint: disable=W0703
            try:
                log(0, "%d/%d : %s" % (index + 1, num_to_process, pack.getNVREA()))
                if to_download:
                    pack.path = localpath = plug.get_package(pack, metadata_only=self.metadata_only)
                    pack.load_checksum_from_header()
                    pack.upload_package(self.channel, metadata_only=self.metadata_only)

                    # we do not want to keep a whole 'a_pkg' object for every package in memory,
                    # because we need only checksum. see BZ 1397417
                    pack.checksum = pack.a_pkg.checksum
                    pack.checksum_type = pack.a_pkg.checksum_type
                    pack.epoch = pack.a_pkg.header['epoch']
                    pack.a_pkg = None
            except KeyboardInterrupt:
                raise
            except Exception:
                ret_code = 1
                e = sys.exc_info()[1]
                log2stderr(0, e)
                log2disk(0, e)
                if self.fail:
                    raise
                to_process[index] = (pack, False, False)
                continue
            finally:
                if is_non_local_repo and localpath and os.path.exists(localpath):
                    os.remove(localpath)

        log(0, "Linking packages to channel.")
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
        return ret_code

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

    def import_kickstart(self, plug, repo_label):
        ks_path = 'rhn/kickstart/'
        ks_tree_label = re.sub(r'[^-_0-9A-Za-z@.]', '', repo_label.replace(' ', '_'))
        if len(ks_tree_label) < 4:
            ks_tree_label += "_repo"

        # construct ks_path and check we already have this KS tree synced
        id_request = """
                select id
                from rhnKickstartableTree
                where channel_id = :channel_id and label = :label
                """

        if 'org_id' in self.channel and self.channel['org_id']:
            ks_path += str(self.channel['org_id']) + '/' + ks_tree_label
            # Trees synced from external repositories are expected to have full path it database
            db_path = os.path.join(CFG.MOUNT_POINT, ks_path)
            row = rhnSQL.fetchone_dict(id_request + " and org_id = :org_id", channel_id=self.channel['id'],
                                       label=ks_tree_label, org_id=self.channel['org_id'])
        else:
            ks_path += ks_tree_label
            db_path = ks_path
            row = rhnSQL.fetchone_dict(id_request + " and org_id is NULL", channel_id=self.channel['id'],
                                       label=ks_tree_label)

        fileutils.createPath(os.path.join(CFG.MOUNT_POINT, ks_path))
        treeinfo_path = ['treeinfo', '.treeinfo']
        treeinfo_parser = None
        for path in treeinfo_path:
            log(1, "Trying " + path)
            treeinfo = plug.get_file(path, os.path.join(plug.repo.basecachedir, plug.name))
            if treeinfo:
                try:
                    treeinfo_parser = TreeInfoParser(treeinfo)
                    break
                except TreeInfoError:
                    pass

        if not treeinfo_parser:
            log(0, "Kickstartable tree not detected (no valid treeinfo file)")
            return

        if self.ks_install_type is None:
            family = treeinfo_parser.get_family()
            if family == 'Fedora':
                self.ks_install_type = 'fedora18'
            elif family == 'CentOS':
                self.ks_install_type = 'rhel_' + treeinfo_parser.get_major_version()
            else:
                self.ks_install_type = 'generic_rpm'

        # Make sure images are included
        to_download = []
        for repo_path in treeinfo_parser.get_images():
            local_path = os.path.join(CFG.MOUNT_POINT, ks_path, repo_path)
            # TODO: better check
            if not os.path.exists(local_path):
                to_download.append(repo_path)

        if row:
            log(0, "Kickstartable tree %s already synced. Updating content..." % ks_tree_label)
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
                           org_id=self.channel['org_id'], label=ks_tree_label, base_path=db_path,
                           channel_id=self.channel['id'], ks_tree_type=self.ks_tree_type,
                           ks_install_type=self.ks_install_type)

            log(0, "Added new kickstartable tree %s. Downloading content..." % ks_tree_label)

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
        log(0, "Gathering all files in kickstart repository...")
        while len(dirs_queue) > 0:
            cur_dir_name = dirs_queue.pop(0)
            cur_dir_html = plug.get_file(cur_dir_name)
            if cur_dir_html is None:
                continue

            parser = KSDirParser(cur_dir_html)

            for ks_file in parser.get_content():
                repo_path = cur_dir_name + ks_file['name']
                # if this is a directory, just add a name into queue (like BFS algorithm)
                if ks_file['type'] == 'DIR':
                    dirs_queue.append(repo_path)
                    continue

                if repo_path not in to_download:
                    to_download.append(repo_path)

        if to_download:
            log(0, "Downloading %d files." % len(to_download))
            for item in to_download:
                for retry in range(3):
                    try:
                        log(1, "Retrieving %s" % item)
                        plug.get_file(item, os.path.join(CFG.MOUNT_POINT, ks_path))
                        st = os.stat(os.path.join(CFG.MOUNT_POINT, ks_path, item))
                        break
                    except OSError:  # os.stat if the file wasn't downloaded
                        if retry < 3:
                            log(2, "Retry download %s: attempt #%d" % (item, retry + 1))
                        else:
                            raise
                # update entity about current file in a database
                delete_h.execute(id=ks_id, path=item)
                insert_h.execute(id=ks_id, path=item,
                                 checksum=getFileChecksum('sha256', os.path.join(CFG.MOUNT_POINT, ks_path, item)),
                                 st_size=st.st_size, st_time=st.st_mtime)
        else:
            log(0, "Nothing to download.")

        # set permissions recursively
        for root, dirs, files in os.walk(os.path.join(CFG.MOUNT_POINT, ks_path)):
            for d in dirs:
                fileutils.setPermsPath(os.path.join(root, d), group='apache')
            for f in files:
                fileutils.setPermsPath(os.path.join(root, f), group='apache')
        rhnSQL.commit()
