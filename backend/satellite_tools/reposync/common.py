import os
import re
import shutil
import sys
import time
from datetime import datetime

from spacewalk.server import rhnPackage, rhnSQL, rhnChannel
from spacewalk.common import fileutils, rhnLog
from spacewalk.common.rhnLog import log_debug
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


def getChannels(exclude_vendor_channels=True):

    d_parents = getParentsChilds(exclude_vendor_channels)
    l_custom_ch = []

    for ch in d_parents:
        l_custom_ch += [ch] + d_parents[ch]

    return l_custom_ch


def set_filter_opt(option, opt_str, value, parser):
    # pylint: disable=W0613
    if opt_str in ['--include', '-i']:
        f_type = '+'
    else:
        f_type = '-'
    parser.values.filters.append((f_type, re.split(r'[,\s]+', value)))


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


class BaseRepoSync(object):
    """ Base class that all RepoSync classes need to inherit. """

    def update_date(self):
        """ Updates the last sync time"""
        h = rhnSQL.prepare("""update rhnChannel set LAST_SYNCED = current_timestamp
                             where label = :channel""")
        h.execute(channel=self.channel['label'])

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
