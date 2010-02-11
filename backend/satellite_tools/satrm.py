#!/usr/bin/python
#
# Module that removes channels from an installed satellite
#
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

import sys
import string
import os
from optparse import Option, OptionParser
from common import CFG, initCFG, initLOG, log_debug, log_error
from server import rhnSQL

UNSUPPORTED_WARN = """
NOTE: This method is not maintained or supported by Red Hat but can be
used if necessary precautions are taken. A database backup before removal
is recommended.
"""

options_table = [
    Option("-v", "--verbose",       action="count", 
        help="Increase verbosity"),
    Option("-c", "--channel",       action="append", 
        help="Delete this channel (can be present multiple times)"),
    Option(      "--force",         action="store_true",
        help="Remove the channel packages from any other channels too"),
    Option(      "--justdb",        action="store_true",
        help="Delete only from the database, do not remove files from disk"),
    Option("-l", "--list",          action="store_true", 
        help="List defined channels and exit"),
]


def main():
    print UNSUPPORTED_WARN

    global options_table
    parser = OptionParser(option_list=options_table)

    (options, args) = parser.parse_args()
        
    if args:
        for arg in args:
            sys.stderr.write("Not a valid option ('%s'), try --help\n" % arg)
        return -1

    if not (options.channel or options.list):
        sys.stderr.write("Nothing to do\n")
        sys.exit(0)
    
    initCFG('server')
    initLOG("stdout", options.verbose or 0)

    rhnSQL.initDB(CFG.DEFAULT_DB)

    dict_label, dict_parents = __listChannels()
    if options.list:
        for c in dict_label.keys():
            print c
        return


    # Verify if the channel is valid
    channels = {}
    for channel in options.channel:
        channels[channel] = None

    for channel in channels.keys():
        if not dict_label.has_key(channel):
            print "Unknown channel %s" % channel
            return -1
        # Sanity check: verify subchannels are deleted as well if base 
        # channels are selected
        if not dict_parents.has_key(channel):
            continue
        # this channel is a parent channel?
        for subch in dict_parents[channel]:
            if not channels.has_key(subch):
                print "Error: cannot remove channel %s: subchannel %s exists" %(
                    channel, subch)
                return -1
                
    # Are we attempting to remove a parent channel while there are still
    # references 

    try:
        delete_channels(channels.keys(), force=options.force,
            justdb=options.justdb)
    except:
        rhnSQL.rollback()
        raise
    rhnSQL.commit()
    return 0


def __listChannels():
    sql = """
        select c1.label, c2.label parent_channel 
        from rhnChannel c1, rhnChannel c2
        where c1.parent_channel = c2.id (+)
    """
    h = rhnSQL.prepare(sql)
    h.execute()
    labels = {}
    parents = {}
    while 1:
        row = h.fetchone_dict()
        if not row:
            break
        parent_channel = row['parent_channel']
        labels[row['label']] = parent_channel
        if parent_channel:
            if not parents.has_key(parent_channel):
                parents[parent_channel] = []
            parents[parent_channel].append(row['label'])
        
    return labels, parents


def delete_channels(channelLabels, force=0, justdb=0):
    # Get the package ids
    if not channelLabels:
        return 

    rpms_ids = list_packages(channelLabels, force=force, sources=0)
    rpms_paths = _get_package_paths(rpms_ids, sources=0)
    srpms_ids = list_packages(channelLabels, force=force, sources=1)
    srpms_paths = _get_package_paths(srpms_ids, sources=1)

    _delete_srpms(srpms_ids)
    _delete_rpms(rpms_ids)

    if not justdb:
        _delete_files(rpms_paths + srpms_paths)

    # Get the channel ids
    h = rhnSQL.prepare("""
        select id, parent_channel 
        from rhnChannel 
        where label = :label 
        order by parent_channel""")
    channel_ids = []
    for label in channelLabels:
        h.execute(label=label)
        row = h.fetchone_dict()
        if not row:
            break
        channel_id = row['id']
        if row['parent_channel']:
            # Subchannel, we have to remove it first
            channel_ids.insert(0, channel_id)
        else:
            channel_ids.append(channel_id)

    if not channel_ids:
        return

    indirect_tables = [
        ['rhnKickstartableTree', 'channel_id', 'rhnKSTreeFile', 'kstree_id'],
    ]
    query = """
        delete from %(table_2)s where %(link_field)s in (
            select id 
              from %(table_1)s
             where %(channel_field)s = :channel_id
        )
    """
    for e in indirect_tables:
        args = {
            'table_1'       : e[0],
            'channel_field' : e[1],
            'table_2'       : e[2],
            'link_field'    : e[3],
        }
        h = rhnSQL.prepare(query % args)
        h.executemany(channel_id=channel_ids)

    tables = [
        ['rhnErrataFileChannel', 'channel_id'],
        ['rhnChannelErrata', 'channel_id'],
        ['rhnChannelFamilyMembers', 'channel_id'],
        ['rhnChannelPackage', 'channel_id'],
        ['rhnDistChannelMap', 'channel_id'],
        ['rhnRegTokenChannels', 'channel_id'],
        ['rhnServerChannel', 'channel_id'],
        ['rhnServerProfile', 'base_channel'],
        ['rhnKickstartableTree', 'channel_id'],
        ['rhnChannel', 'id'],
    ]
    
    query = "delete from %s where %s = :channel_id"
    for table, field in tables:
        log_debug(3, "Processing table %s" % table)
        h = rhnSQL.prepare(query % (table, field))
        h.executemany(channel_id=channel_ids)

def list_packages(channelLabels, sources=0, force=0):
    "List the source ids for the channels"
    if sources:
        packages = "srpms"
    else:
        packages = "rpms"
    log_debug(3, "Listing %s" % packages)
    if not channelLabels:
        return []

    params, bind_params = _bind_many(channelLabels)
    bind_params = string.join(bind_params, ', ')

    if sources:
        templ = _templ_srpms()
    else:
        templ = _templ_rpms()

    if force:
        query = templ % ("", bind_params)
    else:
        query = """
            %s
            MINUS
            %s
        """ % (
            templ % ("", bind_params),
            templ % ("not", bind_params),
        )
    h = rhnSQL.prepare(query)
    apply(h.execute, (), params)
    return map(lambda x: x['id'], h.fetchall_dict() or [])

def _templ_rpms():
    "Returns a template for querying rpms"
    log_debug(4, "Generating template for querying rpms")
    return """\
        select cp.package_id id
        from rhnChannel c, rhnChannelPackage cp
        where c.label %s in (%s)
        and cp.channel_id = c.id"""

def _templ_srpms():
    "Returns a template for querying srpms"
    log_debug(4, "Generating template for querying srpms")
    return """\
        select  ps.id id
        from    rhnPackage p,
                rhnPackageSource ps,
                rhnChannelPackage cp,
                rhnChannel c
        where   c.label %s in (%s)
            and c.id = cp.channel_id
            and cp.package_id = p.id
            and p.source_rpm_id = ps.source_rpm_id
            and ((p.org_id is null and ps.org_id is null) or
                p.org_id = ps.org_id)"""
        
def _delete_srpms(srcPackageIds):
    """Blow away rhnPackageSource and rhnFile entries.
    """
    if not srcPackageIds:
        return
    # nuke the rhnPackageSource entry
    h = rhnSQL.prepare("""
        delete
        from rhnPackageSource
        where id = :id
    """)
    count = h.executemany(id=srcPackageIds)
    if not count:
        count = 0
    log_debug(2, "Successfully deleted %s/%s source package ids" % (
        count, len(srcPackageIds)))

def _delete_rpms(packageIds):
    if not packageIds:
        return

    references = [
        'rhnChannelPackage', 
        'rhnErrataPackage', 
        'rhnErrataPackageTMP', 
        'rhnPackageChangelog', 
        'rhnPackageConflicts', 
        'rhnPackageFile', 
        'rhnPackageObsoletes', 
        'rhnPackageProvides', 
        'rhnPackageRequires', 
        'rhnServerNeededCache',
    ]
    deleteStatement = "delete from %s where package_id = :package_id"
    for table in references:
        h = rhnSQL.prepare(deleteStatement % table)
        count = h.executemany(package_id=packageIds)
        log_debug(3, "Deleted from %s: %d rows" % (table, count))
    deleteStatement = "delete from rhnPackage where id = :package_id"
    h = rhnSQL.prepare(deleteStatement)
    count = h.executemany(package_id=packageIds)
    if count:
        log_debug(2, "DELETED package id %s" % str(packageIds))
    else:
        log_error("No such package id %s" % str(packageIds))

def _delete_files(relpaths):
    for relpath in relpaths:
        path = os.path.join(CFG.MOUNT_POINT, relpath)
        if not os.path.exists(path):
            log_debug(1, "Not removing %s: no such file" % path)
            continue
        try:
            os.unlink(path)
        except OSError:
            print "Error unlinking %s; rolling back" % path
            raise

def _bind_many(l):
    h = {}
    lr = []
    for i in range(len(l)):
        key = 'p_%s' % i
        h[key] = l[i]
        lr.append(':' + key)
    return h, lr

def _get_package_paths(package_ids, sources=0):
    if sources:
        table = "rhnPackageSource"
    else:
        table = "rhnPackage"
    h = rhnSQL.prepare("select path from %s where id = :package_id" % table)
    pdict = {}
    for package_id in package_ids:
        h.execute(package_id=package_id)
        row = h.fetchone_dict()
        if not row:
            continue
        if not row['path']:
            continue
        pdict[row['path']] = None

    return pdict.keys()

if __name__ == '__main__':
    try:
        sys.exit(main() or 0)
    except KeyboardInterrupt:
        sys.stderr.write("\nUser interrupted process.\n")
        sys.exit(0)
    except SystemExit:
        # Normal exit
        raise
    except Exception, e:
        sys.stderr.write("\nERROR: unhandled exception occurred: (%s).\n" % e)
        sys.exit(-1)

