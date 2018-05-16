#
# Copyright (c) 2008--2018 Red Hat, Inc.
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
from xml.dom import minidom
import gzip
import ConfigParser
import gettext
import errno

from rhn.connections import idn_puny_to_unicode

from spacewalk.server import rhnPackage, rhnSQL, rhnChannel
from spacewalk.common.usix import raise_with_tb
from spacewalk.common import fileutils, rhnLog, rhnCache, rhnMail
from spacewalk.common.rhnLib import isSUSE
from spacewalk.common.checksum import getFileChecksum
from spacewalk.common.rhnConfig import CFG, initCFG
from spacewalk.common.rhnException import rhnFault
from spacewalk.server.importlib import importLib, mpmSource, packageImport, errataCache
from spacewalk.server.importlib.packageImport import ChannelPackageSubscription
from spacewalk.server.importlib.backendOracle import SQLBackend
from spacewalk.server.importlib.errataImport import ErrataImport
from spacewalk.satellite_tools.download import ThreadedDownloader, ProgressBarLogger, TextLogger
from spacewalk.satellite_tools.repo_plugins import CACHE_DIR
from spacewalk.server import taskomatic, rhnPackageUpload
from spacewalk.satellite_tools.satCerts import verify_certificate_dates

from syncLib import log, log2, log2disk, dumpEMAIL_LOG, log2background

translation = gettext.translation('spacewalk-backend-server', fallback=True)
_ = translation.ugettext

default_log_location = '/var/log/rhn/'
relative_comps_dir = 'rhn/comps'
relative_modules_dir = 'rhn/modules'
checksum_cache_filename = 'reposync/checksum_cache'
default_import_batch_size = 10

errata_typemap = {
    'security': 'Security Advisory',
    'recommended': 'Bug Fix Advisory',
    'bugfix': 'Bug Fix Advisory',
    'optional': 'Product Enhancement Advisory',
    'feature': 'Product Enhancement Advisory',
    'enhancement': 'Product Enhancement Advisory'
}


def send_mail(sync_type="Repo"):
    """ Send email summary """
    body = dumpEMAIL_LOG()
    if body:
        print(_("+++ sending log as an email +++"))
        host_label = idn_puny_to_unicode(os.uname()[1])
        headers = {
            'Subject': _("%s sync. report from %s") % (sync_type, host_label),
        }
        sndr = "root@%s" % host_label
        if CFG.default_mail_from:
            sndr = CFG.default_mail_from
        rhnMail.send(headers, body, sender=sndr)
    else:
        print(_("+++ email requested, but there is nothing to send +++"))


class KSDirParser:
    file_blacklist = ["release-notes/"]

    def __init__(self, dir_html, additional_blacklist=None):
        self.dir_content = []

        if additional_blacklist is None:
            additional_blacklist = []
        elif not isinstance(additional_blacklist, type([])):
            additional_blacklist = [additional_blacklist]

        for s in (m.group(1) for m in re.finditer(r'(?i)<a href="(.+?)"', dir_html)):
            if not (re.match(r'/', s) or re.search(r'\?', s) or re.search(r'\.\.', s) or re.match(r'[a-zA-Z]+:', s) or
                    re.search(r'\.rpm$', s)):
                if re.search(r'/$', s):
                    file_type = 'DIR'
                else:
                    file_type = 'FILE'

                if s not in (self.file_blacklist + additional_blacklist):
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

    def get_package_dir(self):
        for section_name in self.parser.sections():
            if section_name == 'general':
                for item in self.parser.items(section_name):
                    if item[0] == 'packagedir':
                        return item[1]

    def get_addons(self):
        addons_dirs = []
        for section_name in self.parser.sections():
            # check by name
            if section_name.startswith('addon-'):
                for item in self.parser.items(section_name):
                    if item[0] == 'repository':
                        addons_dirs.append(item[1])
            # check by type
            else:
                repository = None
                repo_type = None
                for item in self.parser.items(section_name):
                    if item[0] == 'repository':
                        repository = item[1]
                    elif item[0] == 'type':
                        repo_type = item[1]

                if repo_type == 'addon' and repository is not None:
                    addons_dirs.append(repository)

        return addons_dirs


def set_filter_opt(option, opt_str, value, parser):
    # pylint: disable=W0613
    if opt_str in ['--include', '-i']:
        f_type = '+'
    else:
        f_type = '-'
    parser.values.filters.append((f_type, [v.strip() for v in value.split(',') if v.strip()]))


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


def write_ssl_set_cache(ca_cert, client_cert, client_key):
    """Write one SSL set into cache directory and return path to files."""
    def create_dir_tree(path):
        try:
            os.makedirs(path, int('0750', 8))
        except OSError:
            exc = sys.exc_info()[1]
            if exc.errno == errno.EEXIST and os.path.isdir(path):
                pass
            else:
                raise

    filenames = {}
    for cert in (ca_cert, client_cert, client_key):
        (name, pem, org) = cert
        filenames[cert] = None
        if name is not None and pem is not None:
            if not org:
                org = "NULL"
            else:
                org = str(org)
            ssldir = os.path.join(CACHE_DIR, '.ssl-certs', org)
            cert_file = os.path.join(ssldir, "%s.pem" % name)
            if not os.path.exists(cert_file):
                create_dir_tree(ssldir)
                f = open(cert_file, "w")
                f.write(str(pem))
                f.close()
            filenames[cert] = cert_file

    return filenames[ca_cert], filenames[client_cert], filenames[client_key]


def clear_ssl_cache():
    ssldir = os.path.join(CACHE_DIR, '.ssl-certs')
    shutil.rmtree(ssldir, True)


def get_single_ssl_set(keys, check_dates=False):
    """Picks one of available SSL sets for given repository."""
    if check_dates:
        for ssl_set in keys:
            if verify_certificate_dates(str(ssl_set['ca_cert'])) and \
                (not ssl_set['client_cert'] or
                 verify_certificate_dates(str(ssl_set['client_cert']))):
                return ssl_set
    # Get first
    else:
        return keys[0]
    return None


class RepoSync(object):

    def __init__(self, channel_label, repo_type=None, url=None, fail=False,
                 filters=None, no_errata=False, sync_kickstart=False, latest=False,
                 metadata_only=False, strict=0, excluded_urls=None, no_packages=False,
                 log_dir="reposync", log_level=None, force_kickstart=False, force_all_errata=False,
                 check_ssl_dates=False, force_null_org_content=False, show_packages_only=False):
        self.regen = False
        self.fail = fail
        self.filters = filters or []
        self.no_packages = no_packages
        self.no_errata = no_errata
        self.sync_kickstart = sync_kickstart
        self.force_all_errata = force_all_errata
        self.force_kickstart = force_kickstart
        self.latest = latest
        self.metadata_only = metadata_only
        self.ks_tree_type = 'externally-managed'
        self.ks_install_type = None
        self.show_packages_only = show_packages_only

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

        if not self.channel['org_id'] or force_null_org_content:
            self.org_id = None
        else:
            self.org_id = int(self.channel['org_id'])

        if not url:
            # TODO:need to look at user security across orgs
            h = rhnSQL.prepare("""select s.id, s.source_url, s.label as repo_label, cst.label as repo_type_label
                                  from rhnContentSource s,
                                       rhnChannelContentSource cs,
                                       rhnContentSourceType cst
                                 where s.id = cs.source_id
                                   and cst.id = s.type_id
                                   and cs.channel_id = :channel_id""")
            h.execute(channel_id=int(self.channel['id']))
            source_data = h.fetchall_dict()
            self.urls = []
            if excluded_urls is None:
                excluded_urls = []
            if source_data:
                for row in source_data:
                    if row['source_url'] not in excluded_urls:
                        # Override repo type DB value using parameter
                        if repo_type:
                            repo_type_label = repo_type
                        else:
                            repo_type_label = row['repo_type_label']
                        self.urls.append((row['id'], row['source_url'], repo_type_label, row['repo_label']))
        else:
            if repo_type:
                repo_type_label = repo_type
            else:
                repo_type_label = 'yum'
            self.urls = [(None, u, repo_type_label, None) for u in url]

        if not self.urls:
            log2(0, 0, "Channel %s has no URL associated" % channel_label, stream=sys.stderr)

        self.strict = strict
        self.all_packages = set()
        self.all_errata = set()
        self.check_ssl_dates = check_ssl_dates
        # Init cache for computed checksums to not compute it on each reposync run again
        self.checksum_cache = rhnCache.get(checksum_cache_filename)
        if self.checksum_cache is None:
            self.checksum_cache = {}
        self.import_batch_size = default_import_batch_size

    def set_import_batch_size(self, batch_size):
        self.import_batch_size = int(batch_size)

    def set_urls_prefix(self, prefix):
        """If there are relative urls in DB, set their real location in runtime"""
        for index, url in enumerate(self.urls):
            # Make list, add prefix, make tuple and save
            url = list(url)
            url[1] = "%s%s" % (prefix, url[1])
            url = tuple(url)
            self.urls[index] = url

    def sync(self, update_repodata=True):
        """Trigger a reposync"""
        failed_packages = 0
        sync_error = 0
        start_time = datetime.now()
        for (repo_id, url, repo_type, repo_label) in self.urls:
            log(0, '')
            log(0, "  Processing repository with URL: %s" % url)
            if self.metadata_only:
                log(0, '    * WARNING: processing RPM metadata only.')

            plugin = None

            # pylint: disable=W0703
            try:
                if '://' not in url:
                    raise Exception("Unknown protocol in repo URL: %s" % url)

                # If the repository uses a uln:// URL, switch to the ULN plugin, overriding the command-line
                if url.startswith("uln://"):
                    repo_type = "uln"

                repo_plugin = self.load_plugin(repo_type)

                if repo_label:
                    repo_name = repo_label
                else:
                    # use modified relative_url as name of repo plugin, because
                    # it used as name of cache directory as well
                    relative_url = '_'.join(url.split('://')[1].split('/')[1:])
                    repo_name = relative_url.replace("?", "_").replace("&", "_").replace("=", "_")

                (ca_cert_file, client_cert_file, client_key_file) = (None, None, None)
                if repo_id is not None:
                    keys = rhnSQL.fetchall_dict("""
                        select k1.description as ca_cert_name, k1.key as ca_cert, k1.org_id as ca_cert_org,
                               k2.description as client_cert_name, k2.key as client_cert, k2.org_id as client_cert_org,
                               k3.description as client_key_name, k3.key as client_key, k3.org_id as client_key_org
                        from rhncontentsource cs inner join
                             rhncontentsourcessl csssl on cs.id = csssl.content_source_id inner join
                             rhncryptokey k1 on csssl.ssl_ca_cert_id = k1.id left outer join
                             rhncryptokey k2 on csssl.ssl_client_cert_id = k2.id left outer join
                             rhncryptokey k3 on csssl.ssl_client_key_id = k3.id
                        where cs.id = :repo_id
                        """, repo_id=int(repo_id))
                    if keys:
                        ssl_set = get_single_ssl_set(keys, check_dates=self.check_ssl_dates)
                        if ssl_set:
                            (ca_cert_file, client_cert_file, client_key_file) = write_ssl_set_cache(
                                (ssl_set['ca_cert_name'], ssl_set['ca_cert'], ssl_set['ca_cert_org']),
                                (ssl_set['client_cert_name'], ssl_set['client_cert'], ssl_set['client_cert_org']),
                                (ssl_set['client_key_name'], ssl_set['client_key'], ssl_set['client_key_org']))
                        else:
                            raise ValueError("No valid SSL certificates were found for repository.")

                plugin = repo_plugin(url, repo_name,
                                     org=str(self.org_id or ''),
                                     channel_label=self.channel_label,
                                     ca_cert_file=ca_cert_file,
                                     client_cert_file=client_cert_file,
                                     client_key_file=client_key_file)

                if self.show_packages_only:
                    self.show_packages(plugin, repo_id)
                else:
                    if update_repodata:
                        plugin.clear_cache()

                    if not self.no_packages:
                        self.import_groups(plugin)
                        if repo_type == "yum":
                            self.import_modules(plugin)
                        ret = self.import_packages(plugin, repo_id, url)
                        failed_packages += ret

                    if not self.no_errata:
                        self.import_updates(plugin)

                    # only for repos obtained from the DB
                    if self.sync_kickstart and repo_label:
                        try:
                            self.import_kickstart(plugin, repo_label)
                        except:
                            rhnSQL.rollback()
                            raise
            except rhnSQL.SQLError:
                raise
            except Exception:
                e = sys.exc_info()[1]
                log2(0, 0, "ERROR: %s" % e, stream=sys.stderr)
                log2disk(0, "ERROR: %s" % e)
                # pylint: disable=W0104
                sync_error = -1

        # In strict mode unlink all packages from channel which are not synced from current repositories
        if self.strict and sync_error == 0:
            if not self.no_packages:
                channel_packages = rhnSQL.fetchall_dict("""
                    select p.id, ct.label as checksum_type, c.checksum
                    from rhnChannelPackage cp,
                         rhnPackage p,
                         rhnChecksumType ct,
                         rhnChecksum c
                    where cp.channel_id = :channel_id
                      and cp.package_id = p.id
                      and p.checksum_id = c.id
                      and c.checksum_type_id = ct.id
                    """, channel_id=int(self.channel['id'])) or []
                for package in channel_packages:
                    if (package['checksum_type'], package['checksum']) not in self.all_packages:
                        self.disassociate_package(package['checksum_type'], package['checksum'])
                        self.regen = True

            # For custom channels unlink also errata
            if not self.no_errata and self.channel['org_id']:
                channel_errata = self.list_errata()
                for erratum in channel_errata:
                    if erratum not in self.all_errata:
                        self.disassociate_erratum(erratum)
                        self.regen = True

        # Update cache with package checksums
        rhnCache.set(checksum_cache_filename, self.checksum_cache)
        if self.regen:
            taskomatic.add_to_repodata_queue_for_channel_package_subscription(
                [self.channel_label], [], "server.app.yumreposync")
            taskomatic.add_to_erratacache_queue(self.channel_label)
        self.update_date()
        rhnSQL.commit()

        # update permissions
        fileutils.createPath(os.path.join(CFG.MOUNT_POINT, 'rhn'))  # if the directory exists update ownership only
        for root, dirs, files in os.walk(os.path.join(CFG.MOUNT_POINT, 'rhn')):
            for d in dirs:
                fileutils.setPermsPath(os.path.join(root, d), group='apache')
            for f in files:
                fileutils.setPermsPath(os.path.join(root, f), group='apache')
        elapsed_time = datetime.now() - start_time
        log(0, "Sync of channel completed in %s." % str(elapsed_time).split('.')[0])
        # if there is no global problems, but some packages weren't synced
        if sync_error == 0 and failed_packages > 0:
            sync_error = failed_packages
        return elapsed_time, sync_error

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

    def import_updates(self, plug):
        notices = plug.get_updates()
        log(0, '')
        log(0, "  Errata in repo: %s." % len(notices))
        if notices:
            self.upload_updates(notices)

    def copy_metadata_file(self, filename, comps_type, relative_dir):
        old_checksum = None
        basename = os.path.basename(filename)
        log(0, '')
        log(0, "  Importing %s file %s." % (comps_type, basename))
        relativedir = os.path.join(relative_dir, self.channel_label)
        absdir = os.path.join(CFG.MOUNT_POINT, relativedir)
        if not os.path.exists(absdir):
            os.makedirs(absdir)
        relativepath = os.path.join(relativedir, basename)
        abspath = os.path.join(absdir, basename)
        for suffix in ['.gz', '.bz', '.xz']:
            if basename.endswith(suffix):
                abspath = abspath.rstrip(suffix)
                relativepath = relativepath.rstrip(suffix)

        h = rhnSQL.prepare("""select relative_filename
                                from rhnChannelComps
                               where channel_id = :cid
                                 and comps_type_id = (select id from rhnCompsType where label = :ctype)""")
        if h.execute(cid=self.channel['id'], ctype=comps_type):
            old_checksum = getFileChecksum('sha256', os.path.join(CFG.MOUNT_POINT, h.fetchone()[0]))

        src = fileutils.decompress_open(filename)
        dst = open(abspath, "w")
        shutil.copyfileobj(src, dst)
        dst.close()
        src.close()
        if old_checksum and old_checksum != getFileChecksum('sha256', abspath):
            self.regen = True
        # update or insert
        hu = rhnSQL.prepare("""update rhnChannelComps
                                  set relative_filename = :relpath,
                                      modified = current_timestamp
                                where channel_id = :cid
                                  and comps_type_id = (select id from rhnCompsType where label = :ctype)""")
        hu.execute(cid=self.channel['id'], relpath=relativepath, ctype=comps_type)

        hi = rhnSQL.prepare("""insert into rhnChannelComps
                              (id, channel_id, relative_filename, comps_type_id)
                              (select sequence_nextval('rhn_channelcomps_id_seq'),
                                      :cid,
                                      :relpath,
                              (select id from rhnCompsType where label = :ctype)
                                 from dual
                                where not exists (select 1 from rhnChannelComps
                                    where channel_id = :cid
                                    and comps_type_id = (select id from rhnCompsType where label = :ctype)))""")
        hi.execute(cid=self.channel['id'], relpath=relativepath, ctype=comps_type)
        return abspath

    def import_groups(self, plug):
        groupsfile = plug.get_groups()
        if groupsfile:
            abspath = self.copy_metadata_file(groupsfile, 'comps', relative_comps_dir)
            plug.groupsfile = abspath

    def import_modules(self, plug):
        modulesfile = plug.get_modules()
        if modulesfile:
            self.copy_metadata_file(modulesfile, 'modules', relative_modules_dir)

    def _populate_erratum(self, notice):
        advisory = notice['update_id'] + '-' + notice['version']
        existing_errata = self.get_errata(notice['update_id'])
        e = importLib.Erratum()
        e['errata_from'] = notice['from']
        e['advisory'] = advisory
        e['advisory_name'] = notice['update_id']
        e['advisory_rel'] = notice['version']
        e['advisory_type'] = errata_typemap.get(notice['type'], 'Product Enhancement Advisory')
        e['product'] = notice['release'] or 'Unknown'
        e['description'] = notice['description']
        e['synopsis'] = notice['title'] or notice['update_id']
        if notice['type'] == 'security' and 'severity' in notice and notice['severity'].lower() != 'none':
            e['security_impact'] = notice['severity']
        if notice['type'] == 'security' and not e['synopsis'].startswith(notice['severity'] + ': '):
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
        e['org_id'] = self.org_id
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
            if self.org_id:
                param_dict['org_id'] = self.org_id
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
                    epoch = str(param_dict['epoch']) + ":"
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

            package = importLib.IncompletePackage().populate(pkg)
            package['epoch'] = cs['epoch']
            package['org_id'] = self.org_id

            package['checksums'] = {cs['checksum_type']: cs['checksum']}
            package['checksum_type'] = cs['checksum_type']
            package['checksum'] = cs['checksum']

            package['package_id'] = cs['id']
            newpkgs.append(package)

            e['packages'] = newpkgs

        # Empty package list in original metadata
        if not e['packages'] and not notice['pkglist'][0]['packages']:
            log(2, "Advisory %s has empty package list." % e['advisory_name'])
        elif not e['packages']:
            raise ValueError("Advisory %s skipped because of empty package list (filtered)." % e['advisory_name'])

        e['keywords'] = []
        if notice['reboot_suggested']:
            kw = importLib.Keyword()
            kw.populate({'keyword': 'reboot_suggested'})
            e['keywords'].append(kw)
        if notice['restart_suggested']:
            kw = importLib.Keyword()
            kw.populate({'keyword': 'restart_suggested'})
            e['keywords'].append(kw)
        e['bugs'] = []
        e['cve'] = []
        if notice['references']:
            bzs = [r for r in notice['references'] if r['type'] == 'bugzilla']
            if bzs:
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
                        bug = importLib.Bug()
                        bug.populate({'bug_id': bz_id, 'summary': bz['title'], 'href': bz['href']})
                        e['bugs'].append(bug)
                        tmp[bz_id] = None
            cves = [r for r in notice['references'] if r['type'] == 'cve']
            if cves:
                tmp = {}
                for cve in cves:
                    if cve['id'] not in tmp:
                        e['cve'].append(cve['id'])
                        tmp[cve['id']] = None
            others = [r for r in notice['references'] if not r['type'] == 'bugzilla' and not r['type'] == 'cve']
            if others:
                refers_to = ""
                for other in others:
                    if refers_to:
                        refers_to += "\n"
                    refers_to += other['href']
                e['refers_to'] = refers_to
        e['locally_modified'] = None
        return e

    def upload_updates(self, notices):
        batch = []

        channel_advisory_names = self.list_errata()
        for notice in notices:
            notice = self.fix_notice(notice)

            # Save advisory names from all repositories
            self.all_errata.add(notice['update_id'])

            if not self.force_all_errata and notice['update_id'] in channel_advisory_names:
                continue

            # pylint: disable=W0703
            try:
                erratum = self._populate_erratum(notice)
                batch.append(erratum)
            except Exception:
                e = "Skipped %s - %s" % (notice['update_id'], sys.exc_info()[1])
                log2(1, 1, e, stream=sys.stderr)
                if self.fail:
                    raise

        if batch:
            log(0, "    Syncing %s new errata to channel." % len(batch))
            backend = SQLBackend()
            importer = ErrataImport(batch, backend)
            importer.run()
            self.regen = True
        elif notices:
            log(0, "    No new errata to sync.")

    def import_packages(self, plug, source_id, url):
        failed_packages = 0
        if (not self.filters) and source_id:
            h = rhnSQL.prepare("""
                    select flag, filter
                      from rhnContentSourceFilter
                     where source_id = :source_id
                     order by sort_order """)
            h.execute(source_id=source_id)
            filter_data = h.fetchall_dict() or []
            filters = [(row['flag'], [v.strip() for v in row['filter'].split(',') if v.strip()])
                       for row in filter_data]
        else:
            filters = self.filters

        packages = plug.list_packages(filters, self.latest)
        to_disassociate = {}
        to_process = []
        num_passed = len(packages)
        log(0, "    Packages in repo:             %5d" % plug.num_packages)
        if plug.num_excluded:
            log(0, "    Packages passed filter rules: %5d" % num_passed)
        channel_id = int(self.channel['id'])

        for pack in packages:
            db_pack = rhnPackage.get_info_for_package(
                [pack.name, pack.version, pack.release, pack.epoch, pack.arch],
                channel_id, self.org_id)

            to_download = True
            to_link = True
            # Package exists in DB
            if db_pack:
                # Path in filesystem is defined
                if db_pack['path']:
                    pack.path = os.path.join(CFG.MOUNT_POINT, db_pack['path'])
                else:
                    pack.path = ""

                if self.metadata_only or self.match_package_checksum(db_pack['path'], pack.path,
                                                                     pack.checksum_type, pack.checksum):
                    # package is already on disk or not required
                    to_download = False
                    if db_pack['channel_id'] == channel_id:
                        # package is already in the channel
                        to_link = False

                    # just pass data from DB, they will be used in strict channel
                    # linking if there is no new RPM downloaded
                    pack.checksum = db_pack['checksum']
                    pack.checksum_type = db_pack['checksum_type']
                    pack.epoch = db_pack['epoch']

                    self.all_packages.add((pack.checksum_type, pack.checksum))

                elif db_pack['channel_id'] == channel_id:
                    # different package with SAME NVREA
                    # disassociate from channel if it doesn't match package which will be downloaded
                    to_disassociate[(db_pack['checksum_type'], db_pack['checksum'])] = True

            if to_download or to_link:
                to_process.append((pack, to_download, to_link))

        num_to_process = len(to_process)
        if num_to_process == 0:
            log(0, "    No new packages to sync.")
            # If we are just appending, we can exit
            if not self.strict:
                return failed_packages
        else:
            log(0, "    Packages already synced:      %5d" % (num_passed - num_to_process))
            log(0, "    Packages to sync:             %5d" % num_to_process)

        is_non_local_repo = (url.find("file:/") < 0)

        downloader = ThreadedDownloader()
        to_download_count = 0
        for what in to_process:
            pack, to_download, to_link = what
            if to_download:
                target_file = os.path.join(plug.repo.pkgdir, os.path.basename(pack.unique_id.relativepath))
                pack.path = target_file
                params = {}
                checksum_type = pack.checksum_type
                checksum = pack.checksum
                plug.set_download_parameters(params, pack.unique_id.relativepath, target_file,
                                             checksum_type=checksum_type, checksum_value=checksum)
                downloader.add(params)
                to_download_count += 1
        if num_to_process != 0:
            log(0, "    New packages to download:     %5d" % to_download_count)
            log2(0, 0, "  Downloading packages:")
        logger = TextLogger(None, to_download_count)
        downloader.set_log_obj(logger)
        downloader.run()

        log2background(0, "Importing packages started.")
        log(0, '')
        log(0, '  Importing packages to DB:')
        progress_bar = ProgressBarLogger("               Importing packages:    ", to_download_count)

        # Prepare SQL statements
        h_delete_package_queue = rhnSQL.prepare("""delete from rhnPackageFileDeleteQueue where path = :path""")
        backend = SQLBackend()

        mpm_bin_batch = importLib.Collection()
        mpm_src_batch = importLib.Collection()
        affected_channels = []
        upload_caller = "server.app.uploadPackage"

        import_count = 0
        for (index, what) in enumerate(to_process):
            pack, to_download, to_link = what
            if not to_download:
                continue
            import_count += 1
            stage_path = pack.path

            # pylint: disable=W0703
            try:
                # check if package was downloaded
                if not os.path.exists(stage_path):
                    raise Exception

                pack.load_checksum_from_header()

                if not self.metadata_only:
                    rel_package_path = rhnPackageUpload.relative_path_from_header(pack.a_pkg.header, self.org_id,
                                                                                  pack.a_pkg.checksum_type,
                                                                                  pack.a_pkg.checksum)
                else:
                    rel_package_path = None

                if rel_package_path:
                    # Save uploaded package to cache with repository checksum type
                    self.checksum_cache[rel_package_path] = {pack.checksum_type: pack.checksum}

                    # First write the package to the filesystem to final location
                    # pylint: disable=W0703
                    try:
                        importLib.move_package(pack.a_pkg.payload_stream.name, basedir=CFG.MOUNT_POINT,
                                               relpath=rel_package_path,
                                               checksum_type=pack.a_pkg.checksum_type,
                                               checksum=pack.a_pkg.checksum, force=1)
                    except OSError:
                        e = sys.exc_info()[1]
                        raise_with_tb(rhnFault(50, "Package upload failed: %s" % e), sys.exc_info()[2])
                    except importLib.FileConflictError:
                        raise_with_tb(rhnFault(50, "File already exists"), sys.exc_info()[2])
                    except Exception:
                        raise_with_tb(rhnFault(50, "File error"), sys.exc_info()[2])

                    # Remove any pending scheduled file deletion for this package
                    h_delete_package_queue.execute(path=rel_package_path)

                pkg = mpmSource.create_package(pack.a_pkg.header, size=pack.a_pkg.payload_size,
                                               checksum_type=pack.a_pkg.checksum_type, checksum=pack.a_pkg.checksum,
                                               relpath=rel_package_path, org_id=self.org_id,
                                               header_start=pack.a_pkg.header_start,
                                               header_end=pack.a_pkg.header_end, channels=[])

                if pack.a_pkg.header.is_source:
                    mpm_src_batch.append(pkg)
                else:
                    mpm_bin_batch.append(pkg)
                # we do not want to keep a whole 'a_pkg' object for every package in memory,
                # because we need only checksum. see BZ 1397417
                pack.checksum = pack.a_pkg.checksum
                pack.checksum_type = pack.a_pkg.checksum_type
                pack.epoch = pack.a_pkg.header['epoch']
                pack.a_pkg = None

                self.all_packages.add((pack.checksum_type, pack.checksum))

                # Downloaded pkg checksum matches with pkg already in channel, no need to disassociate from channel
                if (pack.checksum_type, pack.checksum) in to_disassociate:
                    to_disassociate[(pack.checksum_type, pack.checksum)] = False
                    # Set to_link to False, no need to link again
                    to_process[index] = (pack, True, False)

                # importing packages by batch or if the current packages is the last
                if mpm_bin_batch and (import_count == to_download_count
                                      or len(mpm_bin_batch) % self.import_batch_size == 0):
                    importer = packageImport.PackageImport(mpm_bin_batch, backend, caller=upload_caller)
                    importer.setUploadForce(1)
                    importer.run()
                    rhnSQL.commit()
                    del importer.batch
                    affected_channels.extend(importer.affected_channels)
                    del mpm_bin_batch
                    mpm_bin_batch = importLib.Collection()

                if mpm_src_batch and (import_count == to_download_count
                                      or len(mpm_src_batch) % self.import_batch_size == 0):
                    src_importer = packageImport.SourcePackageImport(mpm_src_batch, backend, caller=upload_caller)
                    src_importer.setUploadForce(1)
                    src_importer.run()
                    rhnSQL.commit()
                    del mpm_src_batch
                    mpm_src_batch = importLib.Collection()

                progress_bar.log(True, None)
            except KeyboardInterrupt:
                raise
            except rhnSQL.SQLError:
                raise
            except Exception:
                failed_packages += 1
                e = str(sys.exc_info()[1])
                if e:
                    log2(0, 1, e, stream=sys.stderr)
                if self.fail:
                    raise
                to_process[index] = (pack, False, False)
                progress_bar.log(False, None)
            finally:
                if is_non_local_repo and stage_path and os.path.exists(stage_path):
                    os.remove(stage_path)

        if affected_channels:
            errataCache.schedule_errata_cache_update(affected_channels)
        log2background(0, "Importing packages finished.")

        # Disassociate packages
        for (checksum_type, checksum) in to_disassociate:
            if to_disassociate[(checksum_type, checksum)]:
                self.disassociate_package(checksum_type, checksum)
        # Do not re-link if nothing was marked to link
        if any([to_link for (pack, to_download, to_link) in to_process]):
            log(0, '')
            log(0, "  Linking packages to the channel.")
            # Packages to append to channel
            import_batch = [self.associate_package(pack) for (pack, to_download, to_link) in to_process if to_link]
            backend = SQLBackend()
            caller = "server.app.yumreposync"
            importer = ChannelPackageSubscription(import_batch,
                                                  backend, caller=caller, repogen=False)
            importer.run()
            backend.commit()
            self.regen = True
        return failed_packages

    def show_packages(self, plug, source_id):

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

        packages = plug.raw_list_packages(filters)

        num_passed = len(packages)
        log(0, "    Packages in repo:             %5d" % plug.num_packages)
        if plug.num_excluded:
            log(0, "    Packages passed filter rules: %5d" % num_passed)

        log(0, "    Package marked with '+' will be downloaded next channel synchronization")
        log(0, "    Package marked with '.' is already presented on filesystem")

        channel_id = int(self.channel['id'])

        for pack in packages:

            db_pack = rhnPackage.get_info_for_package(
                [pack.name, pack.version, pack.release, pack.epoch, pack.arch],
                channel_id, self.org_id)

            pack_status = " + "  # need to be downloaded by default
            pack_full_name = "%-60s\t" % (pack.name + "-" + pack.version + "-" + pack.release + "." +
                                          pack.arch + ".rpm")
            pack_size = "%11d bytes\t" % pack.packagesize

            if pack.checksum_type == 'sha512':
                pack_hash_info = "%-140s" % (pack.checksum_type + ' ' + pack.checksum)
            else:
                pack_hash_info = "%-80s " % (pack.checksum_type + ' ' + pack.checksum)

            # Package exists in DB
            if db_pack:
                # Path in filesystem is defined
                if db_pack['path']:
                    pack.path = os.path.join(CFG.MOUNT_POINT, db_pack['path'])
                else:
                    pack.path = ""

                if self.match_package_checksum(db_pack['path'], pack.path, pack.checksum_type, pack.checksum):
                    # package is already on disk
                    pack_status = ' . '

            log(0, "    " + pack_status + pack_full_name + pack_size + pack_hash_info)

    def match_package_checksum(self, relpath, abspath, checksum_type, checksum):
        if os.path.exists(abspath):
            if relpath not in self.checksum_cache:
                self.checksum_cache[relpath] = {}
            cached_checksums = self.checksum_cache[relpath]
            if checksum_type not in cached_checksums:
                checksum_disk = getFileChecksum(checksum_type, filename=abspath)
                cached_checksums[checksum_type] = checksum_disk
            else:
                checksum_disk = cached_checksums[checksum_type]
            if checksum_disk == checksum:
                return 1
        elif relpath in self.checksum_cache:
            # Remove path from cache if not exists
            del self.checksum_cache[relpath]
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
        package['org_id'] = self.org_id

        return importLib.IncompletePackage().populate(package)

    def disassociate_package(self, checksum_type, checksum):
        log(3, "Disassociating package with checksum: %s (%s)" % (checksum, checksum_type))
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
                  checksum_type=checksum_type, checksum=checksum)

    def disassociate_erratum(self, advisory_name):
        log(3, "Disassociating erratum: %s" % advisory_name)
        h = rhnSQL.prepare("""
                    delete from rhnChannelErrata ce
                     where ce.channel_id = :channel_id
                       and ce.errata_id in (select e.id
                                              from rhnErrata e
                                            where e.advisory_name = :advisory_name
                                           )
                        """)
        h.execute(channel_id=self.channel['id'], advisory_name=advisory_name)

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
            notice['version'] = str(new_version / 100)
        return notice

    def get_errata(self, update_id):
        h = rhnSQL.prepare("""select
            e.id, e.advisory, e.advisory_name, e.advisory_rel
            from rhnerrata e
            where e.advisory_name = :name
              and (e.org_id = :org_id or (e.org_id is null and :org_id is null))
        """)
        h.execute(name=update_id, org_id=self.org_id)
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
            ipackage = importLib.IncompletePackage().populate(pkg)
            ipackage['epoch'] = pkg.get('epoch', '')

            ipackage['checksums'] = {ipackage['checksum_type']: ipackage['checksum']}
            ret['packages'].append(ipackage)

        return ret

    def list_errata(self):
        """List advisory names present in channel"""
        h = rhnSQL.prepare("""select e.advisory_name
            from rhnChannelErrata ce
            inner join rhnErrata e on e.id = ce.errata_id
            where ce.channel_id = :cid
        """)
        h.execute(cid=self.channel['id'])
        advisories = [row['advisory_name'] for row in h.fetchall_dict() or []]
        return advisories

    def import_kickstart(self, plug, repo_label):
        log(0, '')
        log(0, '  Importing kickstarts.')
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

        if self.org_id:
            ks_path += str(self.org_id) + '/' + ks_tree_label
            # Trees synced from external repositories are expected to have full path it database
            db_path = os.path.join(CFG.MOUNT_POINT, ks_path)
            row = rhnSQL.fetchone_dict(id_request + " and org_id = :org_id", channel_id=self.channel['id'],
                                       label=ks_tree_label, org_id=self.org_id)
        else:
            ks_path += ks_tree_label
            db_path = ks_path
            row = rhnSQL.fetchone_dict(id_request + " and org_id is NULL", channel_id=self.channel['id'],
                                       label=ks_tree_label)

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
            log(0, "    Kickstartable tree not detected (no valid treeinfo file)")
            return

        if self.ks_install_type is None:
            family = treeinfo_parser.get_family()
            if family == 'Fedora':
                self.ks_install_type = 'fedora18'
            elif family == 'CentOS':
                self.ks_install_type = 'rhel_' + treeinfo_parser.get_major_version()
            else:
                self.ks_install_type = 'generic_rpm'

        fileutils.createPath(os.path.join(CFG.MOUNT_POINT, ks_path))
        # Make sure images are included
        to_download = set()
        for repo_path in treeinfo_parser.get_images():
            local_path = os.path.join(CFG.MOUNT_POINT, ks_path, repo_path)
            # TODO: better check
            if not os.path.exists(local_path) or self.force_kickstart:
                to_download.add(repo_path)

        if row:
            log(0, "    Kickstartable tree %s already synced. Updating content..." % ks_tree_label)
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
                           org_id=self.org_id, label=ks_tree_label, base_path=db_path,
                           channel_id=self.channel['id'], ks_tree_type=self.ks_tree_type,
                           ks_install_type=self.ks_install_type)

            log(0, "    Added new kickstartable tree %s. Downloading content..." % ks_tree_label)

        insert_h = rhnSQL.prepare("""
                insert into rhnKSTreeFile (kstree_id, relative_filename, checksum_id, file_size, last_modified, created,
                 modified) values (:id, :path, lookup_checksum('sha256', :checksum), :st_size,
                 epoch_seconds_to_timestamp_tz(:st_time), current_timestamp, current_timestamp)
        """)

        delete_h = rhnSQL.prepare("""
                delete from rhnKSTreeFile where kstree_id = :id and relative_filename = :path
        """)

        # Downloading/Updating content of KS Tree
        dirs_queue = ['']
        log(0, "    Gathering all files in kickstart repository...")
        while dirs_queue:
            cur_dir_name = dirs_queue.pop(0)
            cur_dir_html = plug.get_file(cur_dir_name)
            if cur_dir_html is None:
                continue

            parser = KSDirParser(cur_dir_html)
            for ks_file in parser.get_content():
                repo_path = cur_dir_name + ks_file['name']
                if ks_file['type'] == 'DIR':
                    dirs_queue.append(repo_path)
                    continue

                if not os.path.exists(os.path.join(CFG.MOUNT_POINT, ks_path, repo_path)) or self.force_kickstart:
                    to_download.add(repo_path)

        for addon_dir in treeinfo_parser.get_addons():
            repomd_url = str(addon_dir + '/repodata/repomd.xml')
            repomd_file = plug.get_file(repomd_url, os.path.join(plug.repo.basecachedir, plug.name))

            if repomd_file:
                # find location of primary.xml
                repomd_xml = minidom.parse(repomd_file)
                for i in repomd_xml.getElementsByTagName('data'):
                    if i.attributes['type'].value == 'primary':
                        primary_url = str(addon_dir + '/' +
                                          i.getElementsByTagName('location')[0].attributes['href'].value)
                        break

                primary_zip = plug.get_file(primary_url, os.path.join(plug.repo.basecachedir, plug.name))
                if primary_zip:
                    primary_xml = gzip.open(primary_zip, 'r')
                    xmldoc = minidom.parse(primary_xml)
                    for i in xmldoc.getElementsByTagName('package'):
                        package = i.getElementsByTagName('location')[0].attributes['href'].value
                        repo_path = str(os.path.normpath(os.path.join(addon_dir, package)))
                        if not os.path.exists(os.path.join(CFG.MOUNT_POINT, ks_path, repo_path)) \
                                or self.force_kickstart:
                            to_download.add(repo_path)

        if to_download:
            log(0, "    Downloading %d kickstart files." % len(to_download))
            progress_bar = ProgressBarLogger("              Downloading kickstarts:", len(to_download))
            downloader = ThreadedDownloader(force=self.force_kickstart)
            for item in to_download:
                params = {}
                plug.set_download_parameters(params, item, os.path.join(CFG.MOUNT_POINT, ks_path, item))
                downloader.add(params)
            downloader.set_log_obj(progress_bar)
            downloader.run()
            log2background(0, "Download finished.")
            for item in to_download:
                st = os.stat(os.path.join(CFG.MOUNT_POINT, ks_path, item))
                # update entity about current file in a database
                delete_h.execute(id=ks_id, path=item)
                insert_h.execute(id=ks_id, path=item,
                                 checksum=getFileChecksum('sha256', os.path.join(CFG.MOUNT_POINT, ks_path, item)),
                                 st_size=st.st_size, st_time=st.st_mtime)
        else:
            log(0, "No new kickstart files to download.")

        rhnSQL.commit()
