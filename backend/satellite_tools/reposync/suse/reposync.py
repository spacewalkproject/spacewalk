#
# Copyright (c) 2008--2015 Red Hat, Inc.
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
import socket
import sys
import time
import traceback
import base64
from datetime import datetime
from optparse import OptionParser

from yum import Errors
from yum.i18n import to_unicode

from spacewalk.server import rhnPackage, rhnSQL, rhnChannel, rhnPackageUpload, suseEula
from spacewalk.common import fileutils, rhnMail, rhnLog, suseLib, rhn_pkg
from spacewalk.common.rhnTB import fetchTraceback
from spacewalk.common.rhnLog import log_debug
from spacewalk.common.checksum import getFileChecksum
from spacewalk.common.rhnConfig import CFG, initCFG
from spacewalk.server.importlib.importLib import IncompletePackage, Erratum, Bug, Keyword
from spacewalk.server.importlib.packageImport import ChannelPackageSubscription
from spacewalk.server.importlib.backendOracle import SQLBackend
from spacewalk.server.importlib.errataImport import ErrataImport
from spacewalk.server import taskomatic

hostname = socket.gethostname()
if '.' not in hostname:
    hostname = socket.getfqdn()

default_log_location = '/var/log/rhn/reposync/'
relative_comps_dir = 'rhn/comps'
default_hash = 'sha256'

# namespace prefixes for parsing SUSE patches XML files
YUM = "{http://linux.duke.edu/metadata/common}"
RPM = "{http://linux.duke.edu/metadata/rpm}"
SUSE = "{http://novell.com/package/metadata/suse/common}"
PATCH = "{http://novell.com/package/metadata/suse/patch}"

class ChannelException(Exception):
    """Channel Error"""
    def __init__(self, value=None):
        Exception.__init__(self)
        self.value = value
    def __str__(self):
        return "%s" %(self.value,)

    def __unicode__(self):
        return '%s' % to_unicode(self.value)

class ChannelTimeoutException(ChannelException):
    """Channel timeout error e.g. a remote repository is not responding"""
    pass

def getChannelRepo():

    initCFG('server')
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

    initCFG('server')
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

    # with SUSE we sync also Vendor channels with reposync
    # change parameter to False to get not only Custom Channels
    d_parents = getParentsChilds(False)
    l_custom_ch = []

    for ch in d_parents:
        l_custom_ch += [ch] + d_parents[ch]

    return l_custom_ch

class RepoSync(object):

    def __init__(self, channel_label, repo_type, url=None, fail=False,
                 quiet=False, noninteractive=False, filters=None,
                 deep_verify=False, no_errata=False, sync_kickstart = False, latest=False):
        self.regen = False
        self.fail = fail
        self.quiet = quiet
        self.interactive = not noninteractive
        self.filters = filters or []
        self.deep_verify = deep_verify
        self.no_errata = no_errata
        self.sync_kickstart = sync_kickstart
        self.error_messages = []
        self.available_packages = {}
        self.latest = latest

        initCFG('server.susemanager')
        rhnSQL.initDB()

        # setup logging
        log_filename = channel_label + '.log'
        try:
            if CFG.DEBUG > 1:
                dlevel = CFG.DEBUG
            else:
                dlevel = 0
        except:
            dlevel = 0
        rhnLog.initLOG(default_log_location + log_filename, dlevel)
        #os.fchown isn't in 2.4 :/
        os.system("chgrp www " + default_log_location + log_filename)

        self.log_msg("\nSync started: %s" % (time.asctime(time.localtime())))
        self.log_msg(str(sys.argv))

        self.channel_label = channel_label
        self.repo_plugin = self.load_plugin(repo_type)
        self.channel = self.load_channel()
        if not self.channel:
            self.print_msg("Channel does not exist or is not custom.")
            sys.exit(1)

        if not url:
            # TODO:need to look at user security across orgs
            h = rhnSQL.prepare("""select s.id, s.source_url, s.metadata_signed, s.label
                                  from rhnContentSource s,
                                       rhnChannelContentSource cs
                                 where s.id = cs.source_id
                                   and cs.channel_id = :channel_id""")
            h.execute(channel_id=int(self.channel['id']))
            source_urls = h.fetchall_dict()
            if source_urls:
                self.urls = source_urls
            else:
                # generate empty metadata and quit
                taskomatic.add_to_repodata_queue_for_channel_package_subscription(
                    [channel_label], [], "server.app.yumreposync")
                rhnSQL.commit()
                self.error_msg("Channel has no URL associated")
                if not self.channel['org_id']:
                    # RES base vendor channels do not have a URL. This is not an error
                    sys.exit(0)
                sys.exit(1)
        else:
            self.urls = [{'id': None, 'source_url': url, 'metadata_signed' : 'N', 'label': None}]

        self.arches = get_compatible_arches(int(self.channel['id']))

    def load_plugin(self, repo_type):
        """Try to import the repository plugin required to sync the repository

        :repo_type: type of the repository; only 'yum' is currently supported

        """
        name = repo_type + "_src"
        mod = __import__('spacewalk.satellite_tools.repo_plugins',
                         globals(), locals(), [name])
        try:
            submod = getattr(mod, name)
        except AttributeError:
            self.error_msg("Repository type %s is not supported. "
                           "Could not import "
                           "spacewalk.satellite_tools.repo_plugins.%s."
                           % (repo_type, name))
            sys.exit(1)
        return getattr(submod, "ContentSource")

    def sync(self):
        """Trigger a reposync"""
        start_time = datetime.now()
        for data in self.urls:
            self.set_repo_credentials(data)
            insecure = False
            if data['metadata_signed'] == 'N':
                insecure = True
            plugin = None

            # If the repository uses a uln:// URL, switch to the ULN plugin, overriding the command-line
            if data['source_url'].startswith("uln://"):
                self.repo_plugin = self.load_plugin("uln")

            # pylint: disable=W0703
            try:
                plugin = self.repo_plugin(data['source_url'], self.channel_label,
                                        insecure, self.quiet, self.interactive)
                if data['id'] is not None:
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
                        """, repo_id=int(data['id']))
                    if keys and keys.has_key('ca_cert'):
                        plugin.set_ssl_options(keys['ca_cert'], keys['client_cert'], keys['client_key'])

                # update the checksum type of channels with org_id NULL
                self.updateChannelChecksumType(plugin.get_md_checksum_type())

                self.import_packages(plugin, data['id'], data['source_url'])
                self.import_groups(plugin, data['source_url'])
                if not self.no_errata:
                    self.import_updates(plugin, data['source_url'])
                # only for repos obtained from the DB
                if self.sync_kickstart and data['label']:
                    try:
                        self.import_kickstart(plugin, data['source_url'], data['label'])
                    except:
                        rhnSQL.rollback()
                        raise
                self.import_products(plugin)
                self.import_susedata(plugin)

            except ChannelTimeoutException, e:
                self.print_msg(e)
                self.sendErrorMail(str(e))
                sys.exit(1)
            except ChannelException, e:
                self.print_msg("ChannelException: %s" % e)
                self.sendErrorMail("ChannelException: %s" % str(e))
                sys.exit(1)
            except Errors.YumGPGCheckError, e:
                self.print_msg("YumGPGCheckError: %s" % e)
                self.sendErrorMail("YumGPGCheckError: %s" % e)
                sys.exit(1)
            except Errors.RepoError, e:
                self.print_msg("RepoError: %s" % e)
                self.sendErrorMail("RepoError: %s" % e)
                sys.exit(1)
            except Errors.RepoMDError, e:
                if "primary not available" in str(e):
                    taskomatic.add_to_repodata_queue_for_channel_package_subscription(
                        [self.channel_label], [], "server.app.yumreposync")
                    rhnSQL.commit()
                    self.print_msg("Repository has no packages. (%s)" % e)
                    sys.exit(0)
                else:
                    self.print_msg("RepoMDError: %s" % e)
                    self.sendErrorMail("RepoMDError: %s" % e)
                sys.exit(1)
            except:
                self.print_msg("Unexpected error: %s" % sys.exc_info()[0])
                self.print_msg("%s" % traceback.format_exc())
                self.sendErrorMail(fetchTraceback())
                sys.exit(1)

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
        if len(self.error_messages) > 0:
            self.sendErrorMail("Repo Sync Errors: %s" % '\n'.join(self.error_messages))
            sys.exit(1)

    def set_repo_credentials(self, url_dict):
        """Set the credentials in the url_dict['source_url'] from the config file

        We look for the `credentials` query argument and use its value
        as the location of the username and password in the current
        configuration file.

        Examples:
        ?credentials=mirrcred - read 'mirrcred_user' and 'mirrcred_pass'
        ?credeentials=mirrcred_5 - read 'mirrcred_user_5' and 'mirrcred_pass_5'

        """
        url = suseLib.URL(url_dict['source_url'])
        creds = url.get_query_param('credentials')
        if creds:
            namespace = creds.split("_")[0]
            creds_no = 0
            try:
                creds_no = int(creds.split("_")[1])
            except (ValueError, IndexError):
                self.error_msg("Could not figure out which credentials to use "
                               "for this URL: "+url.getURL())
                sys.exit(1)
            # SCC - read credentials from DB
            h = rhnSQL.prepare("""SELECT username, password FROM suseCredentials WHERE id = :id""");
            h.execute(id=creds_no);
            credentials = h.fetchone_dict() or None;
            if not credentials:
                self.error_msg("Could not figure out which credentials to use "
                               "for this URL: "+url.getURL())
                sys.exit(1)
            url.username = credentials['username']
            url.password = base64.decodestring(credentials['password'])
            # remove query parameter from url
            url.query = ""
        url_dict['source_url'] = url.getURL()

    def update_date(self):
        """ Updates the last sync time"""
        h = rhnSQL.prepare("""update rhnChannel set LAST_SYNCED = current_timestamp
                             where label = :channel""")
        h.execute(channel=self.channel['label'])

    def import_groups(self, repo, url):
        groupsfile = repo.get_groups()
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

    def import_updates(self, plug, url):
        if self.no_errata:
            return
        (notices_type, notices) = plug.get_updates()
        saveurl = suseLib.URL(url)
        if saveurl.password:
            saveurl.password = "*******"
        self.print_msg("Repo %s has %s patches." % (saveurl.getURL(),
                                                    len(notices)))
        if notices:
            if notices_type == 'updateinfo':
                self.upload_updates(notices)
            elif notices_type == 'patches':
                self.upload_patches(notices)

    def upload_patches(self, notices):
        """Insert the information from patches into the database

        :arg notices: a list of ElementTree roots from individual patch files

        """
        typemap = {'security'    : 'Security Advisory',
                   'recommended' : 'Bug Fix Advisory',
                   'bugfix'      : 'Bug Fix Advisory',
                   'optional'    : 'Product Enhancement Advisory',
                   'feature'     : 'Product Enhancement Advisory',
                   'enhancement' : 'Product Enhancement Advisory'
                   }
        backend = SQLBackend()
        skipped_updates = 0
        batch = []

        for notice in notices:
            e = Erratum()

            version = notice.find(YUM+'version').get('ver')
            category = notice.findtext(PATCH+'category')

            e['advisory']     = e['advisory_name'] = self._patch_naming(notice)
            e['errata_from']  = 'maint-coord@suse.de'
            e['advisory_rel'] = version
            e['advisory_type'] = typemap.get(category,
                                             'Product Enhancement Advisory')

            existing_errata = get_errata(e['advisory'])

            if (existing_errata and
                not self.errata_needs_update(existing_errata, version,
                                             _to_db_date(notice.get('timestamp')))):
                continue
            self.print_msg("Add Patch %s" % e['advisory'])

            # product name
            query = rhnSQL.prepare("""
                SELECT p.friendly_name
                  FROM suseproducts p
                  JOIN suseproductchannel pc on p.id = pc.product_id
                 WHERE pc.channel_id = :channel_id
                """)
            query.execute(channel_id=int(self.channel['id']))
            try:
                e['product'] = query.fetchone()[0]
            except TypeError:
                e['product'] = 'unknown product'

            for desc_lang in notice.findall(PATCH+'description'):
                if desc_lang.get('lang') == 'en':
                    e['description'] = desc_lang.text or 'not set'
                    break
            for sum_lang in notice.findall(PATCH+'summary'):
                if sum_lang.get('lang') == 'en':
                    e['synopsis'] = sum_lang.text or 'not set'
                    break
            e['topic']       = ' '
            e['solution']    = ' '
            e['issue_date']  = _to_db_date(notice.get('timestamp'))
            e['update_date'] = e['issue_date']
            e['notes']       = ''
            e['org_id']      = self.channel['org_id']
            e['refers_to']   = ''
            e['channels']    = [{'label': self.channel_label}]
            e['packages']    = []
            e['files']       = []
            if existing_errata:
                e['channels'].extend(existing_errata['channels'])
                e['packages'] = existing_errata['packages']

            atoms = notice.find(PATCH+'atoms')
            packages = atoms.findall(YUM+'package')

            e['packages'] = self._patches_process_packages(packages,
                                                           e['advisory_name'],
                                                           e['packages'])
            # an update can't have zero packages, so we skip this update
            if not e['packages']:
                skipped_updates = skipped_updates + 1
                continue

            e['keywords'] = []
            if notice.find(PATCH+'reboot-needed') is not None:
                kw = Keyword()
                kw.populate({'keyword': 'reboot_suggested'})
                e['keywords'].append(kw)
            if notice.find(PATCH+'package-manager') is not None:
                kw = Keyword()
                kw.populate({'keyword': 'restart_suggested'})
                e['keywords'].append(kw)

            e['bugs'] = find_bugs(e['description'])
            e['cve'] = find_cves(e['description'])
            # set severity to Low to get a currency rating
            e['security_impact'] = "Low"

            e['locally_modified'] = None
            batch.append(e)
            if self.deep_verify:
                # import step by step
                importer = ErrataImport(batch, backend)
                importer.run()
                batch = []

        if skipped_updates > 0:
            self.print_msg("%d patches skipped because of incomplete package list." % skipped_updates)
        if len(batch) > 0:
            importer = ErrataImport(batch, backend)
            importer.run()
        self.regen = True

    def upload_updates(self, notices):
        skipped_updates = 0
        batch = []
        typemap = {
                  'security'    : 'Security Advisory',
                  'recommended' : 'Bug Fix Advisory',
                  'bugfix'      : 'Bug Fix Advisory',
                  'optional'    : 'Product Enhancement Advisory',
                  'feature'     : 'Product Enhancement Advisory',
                  'enhancement' : 'Product Enhancement Advisory'
                  }
        backend = SQLBackend()

        for notice in notices:
            notice = _fix_notice(notice)
            patch_name = self._patch_naming(notice)
            existing_errata = get_errata(patch_name)
            if existing_errata and not _is_old_suse_style(notice):
                if int(existing_errata['advisory_rel']) < int(notice['version']):
                    # A disaster happens
                    #
                    # re-releasing an errata with a higher release number
                    # only happens in case of a disaster.
                    # This should force mirrored repos to remove the old
                    # errata and take care that the new one is the only
                    # available.
                    # This mean a hard overwrite
                    _delete_invalid_errata(existing_errata['id'])
                elif int(existing_errata['advisory_rel']) > int(notice['version']):
                    # the existing errata has a higher release than the now
                    # parsed one. We need to skip the current errata
                    continue
                # else: release match, so we update the errata

            if notice['updated']:
                updated_date = _to_db_date(notice['updated'])
            else:
                updated_date = _to_db_date(notice['issued'])
            if (existing_errata and
                not self.errata_needs_update(existing_errata, notice['version'], updated_date)):
                continue
            self.print_msg("Add Patch %s" % patch_name)
            e = Erratum()
            e['errata_from']   = notice['from']
            e['advisory'] = e['advisory_name'] = patch_name
            e['advisory_rel']  = notice['version']
            e['advisory_type'] = typemap.get(notice['type'], 'Product Enhancement Advisory')
            e['product']       = notice['release'] or 'Unknown'
            e['description']   = notice['description'] or 'not set'
            e['synopsis']      = notice['title'] or notice['update_id']
            if (notice['type'] == 'security' and notice['severity'] and
                not e['synopsis'].startswith(notice['severity'] + ': ')):
                e['synopsis'] = notice['severity'] + ': ' + e['synopsis']
            e['topic']         = ' '
            e['solution']      = ' '
            e['issue_date']    = _to_db_date(notice['issued'])
            e['update_date']   = updated_date
            e['org_id']        = self.channel['org_id']
            e['notes']         = ''
            e['refers_to']     = ''
            e['channels']      = [{'label':self.channel_label}]
            e['packages']      = []
            e['files']         = []
            if existing_errata:
                e['channels'].extend(existing_errata['channels'])
                e['packages'] = existing_errata['packages']

            e['packages'] = self._updates_process_packages(
                notice['pkglist'][0]['packages'], e['advisory_name'], e['packages'])
            # One or more package references could not be found in the Database.
            # To not provide incomplete patches we skip this update
            if not e['packages']:
                skipped_updates = skipped_updates + 1
                continue

            e['keywords'] = _update_keywords(notice)
            e['bugs'] = _update_bugs(notice)
            e['cve'] = _update_cve(notice)
            if notice['severity']:
                e['security_impact'] = notice['severity']
            else:
                # 'severity' not available in older yum versions
                # set default to Low to get a correct currency rating
                e['security_impact'] = "Low"
            e['locally_modified'] = None
            batch.append(e)
            if self.deep_verify:
                # import step by step
                importer = ErrataImport(batch, backend)
                importer.run()
                batch = []

        if skipped_updates > 0:
            self.print_msg("%d patches skipped because of empty package list." % skipped_updates)
        if len(batch) > 0:
            importer = ErrataImport(batch, backend)
            importer.run()
        self.regen = True

    def errata_needs_update(self, existing_errata, new_errata_version, new_errata_changedate):
        """check, if the errata in the DB needs an update

           new_errata_version: integer version number
           new_errata_changedate: date of the last change in DB format "%Y-%m-%d %H:%M:%S"
        """
        if self.deep_verify:
            # with deep_verify always re-import all errata
            return True

        if int(existing_errata['advisory_rel']) < int(new_errata_version):
            log_debug(2, "Patch need update: higher version")
            return True
        newdate = datetime.strptime(new_errata_changedate,
                                    "%Y-%m-%d %H:%M:%S")
        olddate = datetime.strptime(existing_errata['update_date'],
                                    "%Y-%m-%d %H:%M:%S")
        if newdate > olddate:
            log_debug(2, "Patch need update: newer update date - %s > %s" % (newdate, olddate))
            return True
        for c in existing_errata['channels']:
            if self.channel_label == c['label']:
                log_debug(2, "No update needed")
                return False
        log_debug(2, "Patch need update: channel not yet part of the patch")
        return True

    def import_products(self, repo):
        products = repo.get_products()
        for product in products:
            query = rhnSQL.prepare("""
                select spf.id
                  from suseProductFile spf
                  join rhnpackageevr pe on pe.id = spf.evr_id
                  join rhnpackagearch pa on pa.id = spf.package_arch_id
                 where spf.name = :name
                   and spf.evr_id = LOOKUP_EVR(:epoch, :version, :release)
                   and spf.package_arch_id = LOOKUP_PACKAGE_ARCH(:arch)
                   and spf.vendor = :vendor
                   and spf.summary = :summary
                   and spf.description = :description
            """)
            query.execute(**product)
            row = query.fetchone_dict()
            if not row or not row.has_key('id'):
                get_id_q = rhnSQL.prepare("""SELECT sequence_nextval('suse_prod_file_id_seq') as id FROM dual""")
                get_id_q.execute()
                row = get_id_q.fetchone_dict() or {}
                if not row or not row.has_key('id'):
                    print "no id for sequence suse_prod_file_id_seq"
                    continue

                h = rhnSQL.prepare("""
                    insert into suseProductFile
                        (id, name, evr_id, package_arch_id, vendor, summary, description)
                    VALUES (:id, :name, LOOKUP_EVR(:epoch, :version, :release),
                            LOOKUP_PACKAGE_ARCH(:arch), :vendor, :summary, :description)
                """)
                h.execute(id=row['id'], **product)

            params = {
                'product_cap'   : "product(%s)" % product['name'],
                'cap_version'   : product['version'] + "-" + product['release'],
                'channel_id'    : int(self.channel['id'])
            }
            if self.channel['org_id']:
                org_statement = "and p.org_id = :channel_org"
                params['channel_org'] = self.channel['org_id']
            else:
                org_statement = "and p.org_id is NULL"

            query = rhnSQL.prepare("""
                select p.id
                  from rhnPackage p
                  join rhnPackageProvides pp on pp.package_id = p.id
                  join rhnPackageCapability pc on pc.id = pp.capability_id
                  join rhnChannelPackage cp on cp.package_id = p.id
                 where pc.name = :product_cap
                   and pc.version = :cap_version
                   and cp.channel_id = :channel_id
                   %s
            """ % org_statement)

            query.execute(**params)
            packrow = query.fetchone_dict()
            if not packrow or not packrow.has_key('id'):
                # package not in DB
                continue

            h = rhnSQL.prepare("""select 1 from susePackageProductFile where package_id = :paid and prodfile_id = :prid""")
            h.execute(paid=packrow['id'], prid=row['id'])
            ex = h.fetchone_dict() or None
            if not ex:
                h = rhnSQL.prepare("""insert into susePackageProductFile (package_id, prodfile_id)
                    VALUES (:package_id, :product_id)
                """)
                h.execute(package_id=packrow['id'], product_id=row['id'])
                self.regen = True

    def import_susedata(self, repo):
        kwcache = {}
        susedata = repo.get_susedata()
        for package in susedata:
            query = rhnSQL.prepare("""
                SELECT p.id
                  FROM rhnPackage p
                  JOIN rhnPackagename pn ON p.name_id = pn.id
                  JOIN rhnChecksumView c ON p.checksum_id = c.id
                  JOIN rhnChannelPackage cp ON p.id = cp.package_id
                 WHERE pn.name = :name
                   AND p.evr_id = LOOKUP_EVR(:epoch, :version, :release)
                   AND p.package_arch_id = LOOKUP_PACKAGE_ARCH(:arch)
                   AND cp.channel_id = :channel_id
                   AND c.checksum = :pkgid
                """)
            query.execute(name=package['name'], epoch=package['epoch'],
                          version=package['version'], release=package['release'],
                          arch=package['arch'], pkgid=package['pkgid'],
                          channel_id=int(self.channel['id']))
            row = query.fetchone_dict() or None
            if not row or not row.has_key('id'):
                # package not found in DB
                continue
            pkgid = int(row['id'])
            log_debug(4, "import_susedata pkgid: %s channelId: %s" % (pkgid, int(self.channel['id'])))

            h = rhnSQL.prepare("""
                SELECT smk.id, smk.label
                  FROM suseMdData smd
                  JOIN suseMdKeyword smk ON smk.id = smd.keyword_id
                 WHERE smd.package_id = :package_id
                   AND smd.channel_id = :channel_id
            """)
            h.execute(package_id=pkgid, channel_id=int(self.channel['id']))
            ret = h.fetchall_dict() or {}
            pkgkws = {}
            for row in ret:
                log_debug(4, "DB keyword: %s kid: %s" % (row['label'], row['id']))
                pkgkws[row['label']] = False
                kwcache[row['label']] = row['id']

            for keyword in package['keywords']:
                log_debug(4, "Metadata keyword: %s" % keyword)
                if keyword not in kwcache:
                    kw = rhnSQL.prepare("""select LOOKUP_MD_KEYWORD(:label) id from dual""")
                    kw.execute(label=keyword)
                    kwid = kw.fetchone_dict()['id']
                    kwcache[keyword] = kwid

                if keyword in pkgkws:
                    pkgkws[keyword] = True
                else:
                    log_debug(4, "Insert new keywordId: %s pkgId: %s channelId: %s" % (kwcache[keyword], pkgid, int(self.channel['id'])))
                    kadd = rhnSQL.prepare("""INSERT INTO suseMdData (package_id, channel_id, keyword_id)
                                              VALUES(:package_id, :channel_id, :keyword_id)""")
                    kadd.execute(package_id=pkgid, channel_id=int(self.channel['id']), keyword_id=kwcache[keyword])
                    self.regen = True

            if package.has_key('eula'):
                eula_id = suseEula.find_or_create_eula(package['eula'])
                rhnPackage.add_eula_to_package(
                  package_id=pkgid,
                  eula_id=eula_id
                )

            # delete all removed keywords
            for label in pkgkws:
                if not pkgkws[label]:
                    log_debug(4, "Delete obsolete keywordId: %s pkgId: %s channelId: %s" % (kwcache[label], pkgid, int(self.channel['id'])))
                    kdel = rhnSQL.prepare("""DELETE FROM suseMdData WHERE package_id = :package_id
                                             AND channel_id = :channel_id AND keyword_id = :keyword_id""")
                    kdel.execute(package_id=pkgid, channel_id=int(self.channel['id']), keyword_id=kwcache[label])
                    self.regen = True

    def _patch_naming(self, notice):
        """Return the name of the patch according to our rules

        :notice: a notice/patch object (this could be a dictionary
        (new-style) or an ElementTree element (old code10 style))

        """
        try:
            version = int(notice.find(YUM+'version').get('ver'))
        except AttributeError:
            # normal yum updates (dicts)
            patch_name = notice['update_id']
        else:
            # code10 patches
            if version >= 1000:
                # old suse style patch naming
                patch_name = notice.get('patchid')
            else:
                # new suse style patch naming
                patch_name = notice.find(YUM+'name').text

        # remove the channel-specific prefix
        # this way we can merge patches from different channels like
        # SDK, HAE and SLES
        update_tag = self.channel['update_tag']
        if update_tag and patch_name.startswith(update_tag):
            patch_name = patch_name[len(update_tag)+1:] # +1 for the hyphen
        elif update_tag and update_tag in patch_name:
            # SLE12 has SUSE-<update-tag>-...
            patch_name = patch_name.replace('SUSE-' + update_tag , 'SUSE', 1)

        return patch_name

    def _updates_process_packages(self, packages, advisory_name,
                                  existing_packages):
        """Check if the packages are in the database

        Go through the list of 'packages' and for each of them
        check to see if it is already present in the database. If it is,
        return a list of IncompletePackage objects, otherwise return an
        empty list.

        :packages: a list of dicts that represent packages (updateinfo style)
        :advisory_name: the name of the current erratum
        :existing_packages: list of already existing packages for this errata

        """
        erratum_packages = existing_packages
        for pkg in packages:
            param_dict = {
                'name': pkg['name'],
                'version': pkg['version'],
                'release': pkg['release'],
                'arch': pkg['arch'],
                'epoch': pkg['epoch'],
                'channel_id': int(self.channel['id'])}
            if param_dict['arch'] not in self.arches:
                continue
            ret = self._process_package(param_dict, advisory_name)
            if not ret:
                if 'epoch' not in param_dict:
                    param_dict['epoch'] = ''
                else:
                    param_dict['epoch'] = '%s:' % param_dict['epoch']
                if "%(name)s-%(epoch)s%(version)s-%(release)s.%(arch)s" % param_dict not in self.available_packages:
                    continue
                # This package could not be found in the database
                # but should be available in this repo
                # so we skip the broken patch.
                errmsg = ("The package "
                          "%(name)s-%(epoch)s%(version)s-%(release)s.%(arch)s "
                          "which is referenced by patch %(patch)s was not found "
                          "in the database. This patch has been skipped." % dict(
                              patch=advisory_name,
                              **param_dict))
                self.print_msg(errmsg)
                self.error_messages.append(errmsg)
                return []

            # add new packages to the errata
            found = False
            for oldpkg in erratum_packages:
                if oldpkg['package_id'] == ret['package_id']:
                    found = True
            if not found:
                erratum_packages.append(ret)
        return erratum_packages

    def _patches_process_packages(self, packages, advisory_name, existing_packages):
        """Check if the packages are in the database

        Go through the list of 'packages' and for each of them
        check to see if it is already present in the database. If it is,
        return a list of IncompletePackage objects, otherwise return an
        empty list.

        :packages: a list of dicts that represent packages (patch style)
        :advisory_name: the name of the current erratum
        :existing_packages: list of already existing packages for this errata

        """
        erratum_packages = existing_packages
        for pkg in packages:
            nevr = pkg.find(YUM+'format').find(RPM+'requires').find(RPM+'entry')
            param_dict = {
                'name': nevr.get('name'),
                'version': nevr.get('ver'),
                'release': nevr.get('rel'),
                'epoch': nevr.get('epoch'),
                'arch': pkg.findtext(YUM+'arch'),
                'channel_id': int(self.channel['id'])
            }
            if param_dict['arch'] not in self.arches:
                continue
            ret = self._process_package(param_dict, advisory_name)
            if not ret:
                if 'epoch' not in param_dict:
                    param_dict['epoch'] = ''
                else:
                    param_dict['epoch'] = '%s:' % param_dict['epoch']
                if "%(name)s-%(epoch)s%(version)s-%(release)s.%(arch)s" % param_dict not in self.available_packages:
                    continue
                # This package could not be found in the database
                # but should be available in this repo
                # so we skip the broken patch.
                errmsg = ("The package "
                          "%(name)s-%(epoch)s%(version)s-%(release)s.%(arch)s "
                          "which is referenced by patch %(patch)s was not found "
                          "in the database. This patch has been skipped." % dict(
                              patch=advisory_name,
                              **param_dict))
                self.print_msg(errmsg)
                self.error_messages.append(errmsg)
                return []

            # add new packages to the errata
            found = False
            for oldpkg in erratum_packages:
                if oldpkg['package_id'] == ret['package_id']:
                    found = True
            if not found:
                erratum_packages.append(ret)
        return erratum_packages


    def _process_package(self, param_dict, advisory_name):
        """Search for a package in the the database

        Search for the package specified by 'param_dict' to see if it is
        already present in the database. If it is, return a
        IncompletePackage objects, otherwise return None.

        :param_dict: dict that represent packages (nerva + channel_id)
        :advisory_name: the name of the current erratum

        """
        pkgepoch = param_dict['epoch']
        del param_dict['epoch']

        if not pkgepoch or pkgepoch == '0':
            epochStatement = "(pevr.epoch is NULL or pevr.epoch = '0')"
        else:
            epochStatement = "pevr.epoch = :epoch"
            param_dict['epoch'] = pkgepoch
        if self.channel['org_id']:
            orgidStatement = " = :org_id"
            param_dict['org_id'] = self.channel['org_id']
        else:
            orgidStatement = " is NULL"

        h = rhnSQL.prepare("""
            select p.id, c.checksum, c.checksum_type, pevr.epoch
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
            """ % (orgidStatement, epochStatement))
        h.execute(**param_dict)
        cs = h.fetchone_dict()

        if not cs:
            return None

        package = IncompletePackage()
        for k in param_dict:
            if k not in ['epoch', 'channel_label', 'channel_id']:
                package[k] = param_dict[k]
        package['epoch'] = cs['epoch']
        package['org_id'] = self.channel['org_id']

        package['checksums'] = {cs['checksum_type'] : cs['checksum']}
        package['checksum_type'] = cs['checksum_type']
        package['checksum'] = cs['checksum']

        package['package_id'] = cs['id']
        return package

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
        to_process = []
        skipped = 0
        saveurl = suseLib.URL(url)
        if saveurl.password:
            saveurl.password = "*******"
        num_passed = len(packages)
        self.print_msg("Repo URL: %s" % saveurl.getURL())
        self.print_msg("Packages in repo:             %5d" % plug.num_packages)
        if plug.num_excluded:
            self.print_msg("Packages passed filter rules: %5d" % num_passed)
        channel_id = int(self.channel['id'])
        if self.channel['org_id']:
            self.channel['org_id'] = int(self.channel['org_id'])
        else:
            self.channel['org_id'] = None
        for pack in packages:
            if pack.arch in ['src', 'nosrc']:
                # skip source packages
                skipped += 1
                continue
            if pack.arch not in self.arches:
                # skip packages with incompatible architecture
                skipped += 1
                continue
            epoch = ''
            if pack.epoch and pack.epoch != '0':
                epoch = "%s:" % pack.epoch
            ident = "%s-%s%s-%s.%s" % (pack.name, epoch, pack.version, pack.release, pack.arch)
            self.available_packages[ident] = 1

            db_pack = rhnPackage.get_info_for_package(
                [pack.name, pack.version, pack.release, pack.epoch, pack.arch],
                channel_id, self.channel['org_id'])

            to_download = True
            to_link = True
            if db_pack['path']:
                # if the package exists, but under a different org_id we have to download it again
                if self.match_package_checksum(pack, db_pack):
                    # package is already on disk
                    to_download = False
                    pack.set_checksum(db_pack['checksum_type'], db_pack['checksum'])
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
            if plug.num_packages == 0:
                self.regen = True
            return
        else:
            self.print_msg("Packages already synced:      %5d" %
                           (num_passed - num_to_process))
            self.print_msg("Packages to sync:             %5d" % num_to_process)

        self.regen = True
        is_non_local_repo = (url.find("file://") < 0)

        def finally_remove(path):
            if is_non_local_repo and path and os.path.exists(path):
                os.remove(path)

        # try/except/finally doesn't work in python 2.4 (RHEL5), so here's a hack
        for (index, what) in enumerate(to_process):
            pack, to_download, to_link = what
            localpath = None
            # pylint: disable=W0703
            try:
                self.print_msg("%d/%d : %s" % (index + 1, num_to_process, pack.getNVREA()))
                if to_download:
                    pack.path = localpath = plug.get_package(pack)
                pack.load_checksum_from_header()
                if to_download:
                    pack.upload_package(self.channel)
                    finally_remove(localpath)
                if to_link:
                    self.associate_package(pack)
            except KeyboardInterrupt:
                finally_remove(localpath)
                raise
            except Exception, e:
                self.error_msg(e)
                finally_remove(localpath)
                pack.clear_header()
                if self.fail:
                    raise
                else:
                    self.error_messages.append(str(e))
                continue
            pack.clear_header()

    def match_package_checksum(self, md_pack, db_pack):
        """compare package checksum"""

        md_pack.path = abspath = os.path.join(CFG.MOUNT_POINT, db_pack['path'])
        if (self.deep_verify or
            md_pack.checksum_type != db_pack['checksum_type'] or
            md_pack.checksum != db_pack['checksum']):

            if (os.path.exists(abspath) and
                getFileChecksum(md_pack.checksum_type, filename=abspath) == md_pack.checksum):

                return True
            else:
                return False
        return True

    def associate_package(self, pack):
        caller = "server.app.yumreposync"
        backend = SQLBackend()
        package = {}
        package['name'] = pack.name
        package['version'] = pack.version
        package['release'] = pack.release
        package['arch'] = pack.arch
        package['checksum'] = pack.a_pkg.checksum
        package['checksum_type'] = pack.a_pkg.checksum_type
        package['channels'] = [{'label': self.channel_label,
                                'id': self.channel['id']}]
        package['org_id'] = self.channel['org_id']

        imported = False
        # yum's createrepo puts epoch="0" to primary.xml even for packages
        # with epoch='' so we have to check empty epoch first because it's
        # more common situation
        if pack.epoch == '0':
            package['epoch'] = ''
            try:
                self._importer_run(package, caller, backend)
                imported = True
            except:
                pass
        if not imported:
            package['epoch'] = pack.epoch
            self._importer_run(package, caller, backend)

        backend.commit()

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
        h.execute(channel_id=int(self.channel['id']),
                  checksum_type=pack['checksum_type'], checksum=pack['checksum'])

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

    @staticmethod
    def log_msg(message):
        rhnLog.log_clean(0, message)

    def sendErrorMail(self, body):
        to = CFG.TRACEBACK_MAIL
        fr = to
        if isinstance(to, type([])):
            fr = to[0].strip()
            to = ', '.join([s.strip() for s in to])

        headers = {
            "Subject" : "SUSE Manager repository sync failed (%s)" % hostname,
            "From"    : "%s <%s>" % (hostname, fr),
            "To"      : to,
        }
        extra = "Syncing Channel '%s' failed:\n\n" % self.channel_label
        rhnMail.send(headers, extra + body)

    def import_kickstart(self, plug, url, repo_label):
        ks_tree_label = re.sub(r'[^-_0-9A-Za-z@.]', '', repo_label.replace(' ', '_'))
        if len(ks_tree_label) < 4:
            ks_tree_label += "_repo"
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
                """, org_id=self.channel['org_id'], channel_id=self.channel['id'], label=ks_tree_label):
            print "Kickstartable tree %s already synced." % ks_tree_label
            return

        row = rhnSQL.fetchone_dict("""
            select sequence_nextval('rhn_kstree_id_seq') as id from dual
            """)
        ks_id = row['id']
        ks_path = 'rhn/kickstart/%s/%s' % (self.channel['org_id'], ks_tree_label)

        row = rhnSQL.execute("""
            insert into rhnKickstartableTree (id, org_id, label, base_path, channel_id,
                        kstree_type, install_type, last_modified, created, modified)
            values (:id, :org_id, :label, :base_path, :channel_id,
                        ( select id from rhnKSTreeType where label = 'externally-managed'),
                        ( select id from rhnKSInstallType where label = 'generic_rpm'),
                        current_timestamp, current_timestamp, current_timestamp)
            """, id=ks_id, org_id=self.channel['org_id'], label=ks_tree_label,
                             base_path=os.path.join(CFG.MOUNT_POINT, ks_path), channel_id=self.channel['id'])

        insert_h = rhnSQL.prepare("""
            insert into rhnKSTreeFile (kstree_id, relative_filename, checksum_id, file_size, last_modified, created, modified)
            values (:id, :path, lookup_checksum('sha256', :checksum), :st_size, epoch_seconds_to_timestamp_tz(:st_time), current_timestamp, current_timestamp)
            """)
        dirs = ['']
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
                if (re.match(r'/', s) or re.search(r'\?', s) or re.search(r'\.\.', s)
                        or re.match(r'[a-zA-Z]+:', s) or re.search(r'\.rpm$', s)):
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
                insert_h.execute(id=ks_id, path=d + s, checksum=getFileChecksum('sha256', local_path),
                                 st_size=st.st_size, st_time=st.st_mtime)

        rhnSQL.commit()

    def updateChannelChecksumType(self, repo_checksum_type):
        """
        check, if the checksum_type of the channel matches the one of the repo
        if not, change the type of the channel
        """
        if self.channel['org_id']:
            # custom channels are user managed.
            # Do not autochange this
            return

        h = rhnSQL.prepare("""SELECT ct.label
                                FROM rhnChannel c
                                JOIN rhnChecksumType ct ON c.checksum_type_id = ct.id
                               WHERE c.id = :cid""")
        h.execute(cid=self.channel['id'])
        d = h.fetchone_dict() or None
        if d and d['label'] == repo_checksum_type:
            # checksum_type is the same, no need to change anything
            return
        h = rhnSQL.prepare("""SELECT id FROM rhnChecksumType WHERE label = :clabel""")
        h.execute(clabel=repo_checksum_type)
        d = h.fetchone_dict() or None
        if not (d and d['id']):
            # unknown or invalid checksum_type
            # better not change the channel
            return
        # update the checksum_type
        h = rhnSQL.prepare("""UPDATE rhnChannel
                                 SET checksum_type_id = :ctid
                               WHERE id = :cid""")
        h.execute(ctid=d['id'], cid=self.channel['id'])


def get_errata(update_id):
    """ Return an Errata dict

    search in the database for the given advisory and
    return a dict with important values.
    If the advisory was not found it returns None

    :update_id - the advisory (name)
    """
    h = rhnSQL.prepare("""
        select e.id, e.advisory,
               e.advisory_name, e.advisory_rel,
               TO_CHAR(e.update_date, 'YYYY-MM-DD HH24:MI:SS') as update_date
          from rhnerrata e
         where e.advisory = :name
    """)
    h.execute(name=update_id)
    ret = h.fetchone_dict()
    if not ret:
        return None

    h = rhnSQL.prepare("""
        select distinct c.label
          from rhnchannelerrata ce
          join rhnchannel c on c.id = ce.channel_id
         where ce.errata_id = :eid
    """)
    h.execute(eid=ret['id'])
    ret['channels'] = h.fetchall_dict() or []

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

def get_compatible_arches(channel_id):
    """Return a list of compatible package arch labels for this channel"""
    h = rhnSQL.prepare("""select pa.label
                          from rhnChannelPackageArchCompat cpac,
                          rhnChannel c,
                          rhnpackagearch pa
                          where c.id = :channel_id
                          and c.channel_arch_id = cpac.channel_arch_id
                          and cpac.package_arch_id = pa.id""")
    h.execute(channel_id=channel_id)
    # We do not mirror source packages. If they are listed in patches
    # we need to know, that it is safe to skip them
    arches = [k['label'] for k in  h.fetchall_dict() if k['label'] not in ['src', 'nosrc']]
    return arches

def _best_checksum_item(checksums):
    if checksums.has_key('sha256'):
        checksum_type = 'sha256'
        checksum_type_orig = 'sha256'
        checksum = checksums[checksum_type_orig]
    elif checksums.has_key('sha'):
        checksum_type = 'sha1'
        checksum_type_orig = 'sha'
        checksum = checksums[checksum_type_orig]
    elif checksums.has_key('sha1'):
        checksum_type = 'sha1'
        checksum_type_orig = 'sha1'
        checksum = checksums[checksum_type_orig]
    elif checksums.has_key('md5'):
        checksum_type = 'md5'
        checksum_type_orig = 'md5'
        checksum = checksums[checksum_type_orig]
    else:
        checksum_type = 'md5'
        checksum_type_orig = None
        checksum = None
    return (checksum_type, checksum_type_orig, checksum)

def _to_db_date(date):
    if not date:
        return datetime.utcnow().isoformat(' ')
    if date.isdigit():
        ret = datetime.fromtimestamp(float(date)).isoformat(' ')
    else:
        # we expect to get ISO formated date
        try:
            ret = datetime.strptime(date, '%Y-%m-%d %H:%M:%S').isoformat(' ')
        except ValueError:
            try:
                ret = datetime.strptime(date, '%Y-%m-%d').isoformat(' ')
            except ValueError:
                raise ValueError("Not a valid date")
    return ret[:19] #return 1st 19 letters of date, therefore preventing ORA-01830 caused by fractions of seconds

def _update_keywords(notice):
    """Return a list of Keyword objects for the notice"""
    keywords = []
    if notice['reboot_suggested']:
        kw = Keyword()
        kw.populate({'keyword':'reboot_suggested'})
        keywords.append(kw)
    if notice['restart_suggested']:
        kw = Keyword()
        kw.populate({'keyword':'restart_suggested'})
        keywords.append(kw)
    return keywords

def _update_bugs(notice):
    """Return a list of Bug objects from the notice's references"""
    bugs = {}
    if notice['references'] is None:
        return []
    for bz in notice['references']:
        if bz['type'] == 'bugzilla' and bz['id'] not in bugs:
            bug = Bug()
            bug.populate({'bug_id': bz['id'],
                          'summary': bz['title'] or ("Bug %s" % bz['id']),
                          'href': bz['href']})
            bugs[bz['id']] = bug
    return bugs.values()

def _update_cve(notice):
    """Return a list of unique ids from notice references of type 'cve'"""
    cves = []
    if notice['description'] is not None:
        # sometimes CVE numbers appear in the description, but not in
        # the reference list
        cves = find_cves(notice['description'])
    if notice['references'] is not None:
        cves.extend([cve['id'][:20] for cve in notice['references'] if cve['type'] == 'cve'])
    # remove duplicates
    cves = list(set(cves))

    return cves

def _fix_notice(notice):
    if "." in notice['version']:
        new_version = 0
        for n in notice['version'].split('.'):
            new_version = (new_version + int(n)) * 100
        try:
            notice['version'] = new_version / 100
        except TypeError: # yum in RHEL5 does not have __setitem__
            notice._md['version'] = new_version / 100
    if _is_old_suse_style(notice):
        # old suse style; we need to append the version to id
        # to get a seperate patch for every issue
        try:
            notice['update_id'] = notice['update_id'] + '-' + notice['version']
        except TypeError: # yum in RHEL5 does not have __setitem__
            notice._md['update_id'] = notice['update_id'] + '-' + notice['version']
    return notice

def _is_old_suse_style(notice):
    if((notice['from'] and "suse" in notice['from'].lower() and
        int(notice['version']) >= 1000) or
        (notice['update_id'][:4] in ('res5', 'res6') and int(notice['version']) > 6 ) or
        (notice['update_id'][:4] == 'res4')):
        # old style suse updateinfo starts with version >= 1000 or
        # have the res update_tag
        return True
    return False


def find_bugs(text):
    """Find and return a list of Bug objects from the bug ids in the `text`

    Matches:
     - [#123123], (#123123)

    N.B. We assume that all the bugs are Novell Bugzilla bugs.

    """
    bug_numbers = set(re.findall('[\[\(]#(\d{6})[\]\)]', text))
    bugs = []
    for bug_number in bug_numbers:
        bug = Bug()
        bug.populate(
            {'bug_id': bug_number,
             'summary': 'bug number %s' % bug_number,
             'href':
                 'https://bugzilla.novell.com/show_bug.cgi?id=%s' % bug_number})
        bugs.append(bug)
    return bugs

def find_cves(text):
    """Find and return a list of CVE ids

    Matches:
     - CVE-YEAR-NUMBER

     Beginning 2014, the NUMBER has no maximal length anymore.
     We limit the length at 20 chars, because of the DB column size
    """
    cves = list()
    cves.extend([cve[:20] for cve in set(re.findall('CVE-\d{4}-\d+', text))])
    return cves

def set_filter_opt(option, opt_str, value, parser):
    if opt_str in [ '--include', '-i']: f_type = '+'
    else:                               f_type = '-'
    parser.values.filters.append((f_type, re.split('[,\s]+', value)))

def _delete_invalid_errata(errata_id):
    """
    Remove the errata from all channels
    This should only be alled in case of a disaster
    """
    # first get a list of all channels where this errata exists
    h = rhnSQL.prepare("""
        SELECT channel_id
          FROM rhnChannelErrata
         WHERE errata_id = :errata_id
    """)
    h.execute(errata_id=errata_id)
    channels = map(lambda x: x['channel_id'], h.fetchall_dict() or [])

    # delete channel from errata
    h = rhnSQL.prepare("""
        DELETE FROM rhnChannelErrata
         WHERE errata_id = :errata_id
    """)
    h.execute(errata_id=errata_id)

    # delete all packages from errata
    h = rhnSQL.prepare("""
        DELETE FROM rhnErrataPackage ep
         WHERE ep.errata_id = :errata_id
    """)
    h.execute(errata_id=errata_id)

    # delete files from errata
    h = rhnSQL.prepare("""
        DELETE FROM rhnErrataFile
         WHERE errata_id = :errata_id
    """)
    h.execute(errata_id=errata_id)

    # delete erratatmp
    h = rhnSQL.prepare("""
        DELETE FROM rhnErrataTmp
         WHERE id = :errata_id
    """)
    h.execute(errata_id=errata_id)

    # delete errata
    # removes also references from rhnErrataCloned
    # and rhnServerNeededCache
    h = rhnSQL.prepare("""
        DELETE FROM rhnErrata
         WHERE id = :errata_id
    """)
    h.execute(errata_id=errata_id)
    rhnSQL.commit()
    update_needed_cache = rhnSQL.Procedure("rhn_channel.update_needed_cache")

    for cid in channels:
        update_needed_cache(cid)
    rhnSQL.commit()

