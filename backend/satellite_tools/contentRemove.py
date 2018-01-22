# Copyright (c) 2016 Red Hat, Inc.
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
import shutil
import sys
from spacewalk.common.rhnConfig import CFG
from spacewalk.common.rhnLog import log_debug, log_error
from spacewalk.satellite_tools.progress_bar import ProgressBar
from spacewalk.server.rhnPackage import unlink_package_file
from spacewalk.server import rhnSQL


def __serverCheck(labels, unsubscribe):
    sql = """
        select distinct S.org_id, S.id, S.name
        from rhnChannel c inner join
             rhnServerChannel sc on c.id = sc.channel_id inner join
             rhnServer s on s.id = sc.server_id
        where c.label in (%s)
    """
    params, bind_params = _bind_many(labels)
    bind_params = ', '.join(bind_params)
    h = rhnSQL.prepare(sql % (bind_params))
    h.execute(**params)
    server_list = h.fetchall_dict()
    if not server_list:
        return 0

    if unsubscribe:
        return __unsubscribeServers(labels)

    print("\nCurrently there are systems subscribed to one or more of the specified channels.")
    print("If you would like to automatically unsubscribe these systems, simply use the --unsubscribe flag.\n")
    print("The following systems were found to be subscribed:")

    print("%-8s %-14s name" % ('org_id', 'id'))
    print("-" * 32)
    for server in server_list:
        print("%-8s %-14s %s" % (server['org_id'], server['id'], server['name']))

    return len(server_list)


def __unsubscribeServers(labels):
    sql = """
        select distinct sc.server_id as server_id, C.id as channel_id, c.parent_channel, c.label
        from rhnChannel c inner join
             rhnServerChannel sc on c.id = sc.channel_id
        where c.label in (%s) order by C.parent_channel
    """
    params, bind_params = _bind_many(labels)
    bind_params = ', '.join(bind_params)
    h = rhnSQL.prepare(sql % (bind_params))
    h.execute(**params)
    server_channel_list = h.fetchall_dict()

    channel_counts = {}
    for i in server_channel_list:
        if i['label'] in channel_counts:
            channel_counts[i['label']] = channel_counts[i['label']] + 1
        else:
            channel_counts[i['label']] = 1
    print("\nThe following channels will have their systems unsubscribed:")
    channel_list = channel_counts.keys()
    channel_list.sort()
    for i in channel_list:
        print("%-40s s-8%" % (i, channel_counts[i]))

    pb = ProgressBar(prompt='Unsubscribing:    ', endTag=' - complete',
                     finalSize=len(server_channel_list), finalBarLength=40, stream=sys.stdout)
    pb.printAll(1)

    unsubscribe_server_proc = rhnSQL.Procedure("rhn_channel.unsubscribe_server")
    for i in server_channel_list:
        unsubscribe_server_proc(i['server_id'], i['channel_id'])
        pb.addTo(1)
        pb.printIncrement()
    pb.printComplete()


def __kickstartCheck(labels):
    sql = """
        select K.org_id, K.label
        from rhnKSData K inner join
             rhnKickstartDefaults KD on KD.kickstart_id = K.id inner join
             rhnKickstartableTree KT on KT.id = KD.kstree_id inner join
             rhnChannel c on c.id = KT.channel_id
        where c.label in (%s)
    """
    params, bind_params = _bind_many(labels)
    bind_params = ', '.join(bind_params)
    h = rhnSQL.prepare(sql % (bind_params))
    h.execute(**params)
    kickstart_list = h.fetchall_dict()

    if not kickstart_list:
        return 0

    print("The following kickstarts are associated with one of the specified channels. " +
          "Please remove these or change their associated base channel.\n")
    print("%-8s label" % ('org_id', 'label'))
    print("-" * 20)
    for kickstart in kickstart_list:
        print("%-8s %s" % (kickstart['org_id'], kickstart['label']))

    return len(kickstart_list)


def __listChannels():
    sql = """
        select c1.label, c2.label parent_channel
        from rhnChannel c1 left outer join rhnChannel c2 on c1.parent_channel = c2.id
        order by c2.label desc, c1.label asc
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
        if not parent_channel:
            parents[row['label']] = []

        if parent_channel:
            parents[parent_channel].append(row['label'])

    return labels, parents


def delete_outside_channels(org):
    rpms_ids = list_packages_without_channels(org, sources=0)
    rpms_paths = _get_package_paths(rpms_ids, sources=0)
    srpms_ids = list_packages_without_channels(org, sources=1)
    srpms_paths = _get_package_paths(srpms_ids, sources=1)

    _delete_srpms(srpms_ids)
    _delete_rpms(rpms_ids)

    _delete_files(rpms_paths + srpms_paths)


def delete_channels(channelLabels, force=0, justdb=0, skip_packages=0, skip_channels=0,
                    skip_kickstart_trees=0, just_kickstart_trees=0):
    # Get the package ids
    if not channelLabels:
        return

    rpms_ids = list_packages(channelLabels, force=force, sources=0)
    rpms_paths = _get_package_paths(rpms_ids, sources=0)
    srpms_ids = list_packages(channelLabels, force=force, sources=1)
    srpms_paths = _get_package_paths(srpms_ids, sources=1)

    if not skip_packages and not just_kickstart_trees:
        _delete_srpms(srpms_ids)
        _delete_rpms(rpms_ids)

    if not skip_kickstart_trees and not justdb:
        _delete_ks_files(channelLabels)

    if not justdb and not skip_packages and not just_kickstart_trees:
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
            'table_1': e[0],
            'channel_field': e[1],
            'table_2': e[2],
            'link_field': e[3],
        }
        h = rhnSQL.prepare(query % args)
        h.executemany(channel_id=channel_ids)

    tables = [
        ['rhnErrataFileChannel', 'channel_id'],
        ['rhnErrataNotificationQueue', 'channel_id'],
        ['rhnChannelErrata', 'channel_id'],
        ['rhnChannelPackage', 'channel_id'],
        ['rhnRegTokenChannels', 'channel_id'],
        ['rhnServerProfile', 'base_channel'],
        ['rhnKickstartableTree', 'channel_id'],
    ]

    if not skip_channels:
        tables.extend([
            ['rhnChannelFamilyMembers', 'channel_id'],
            ['rhnDistChannelMap', 'channel_id'],
            ['rhnReleaseChannelMap', 'channel_id'],
            ['rhnChannel', 'id'],
        ])

    if just_kickstart_trees:
        tables = [['rhnKickstartableTree', 'channel_id']]

    query = "delete from %s where %s = :channel_id"
    for table, field in tables:
        log_debug(3, "Processing table %s" % table)
        h = rhnSQL.prepare(query % (table, field))
        h.executemany(channel_id=channel_ids)

    if not justdb and not just_kickstart_trees:
        __deleteRepoData(channelLabels)


def __deleteRepoData(labels):
    directory = '/var/cache/' + CFG.repomd_path_prefix
    for label in labels:
        if os.path.isdir(directory + '/' + label):
            shutil.rmtree(directory + '/' + label)


def list_packages_without_channels(org_id, sources=0):
    """List packages in given org outside any channel"""

    if sources:
        query = """
            select ps.id from rhnPackage p inner join
                              rhnPackageSource ps on p.source_rpm_id = ps.source_rpm_id left join
                              rhnChannelPackage cp on cp.package_id = p.id
            where cp.channel_id is null
        """
    else:
        query = """
            select p.id from rhnPackage p left join
                             rhnChannelPackage cp on cp.package_id = p.id
            where cp.channel_id is null
        """

    if org_id:
        query += """
            and p.org_id = :org_id
        """
        if sources:
            query += """
                and p.org_id = ps.org_id
            """
    else:
        query += """
            and p.org_id is null
        """
        if sources:
            query += """
                and ps.org_id is null
            """

    h = rhnSQL.prepare(query)
    h.execute(org_id=org_id)

    return [x['id'] for x in h.fetchall_dict() or []]


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
    bind_params = ', '.join(bind_params)

    if sources:
        templ = _templ_srpms()
    else:
        templ = _templ_rpms()

    if force:
        query = templ % ("", bind_params)
    else:
        if CFG.DB_BACKEND == 'oracle':
            minus_op = 'MINUS'  # ORA syntax
        else:
            minus_op = 'EXCEPT'  # ANSI syntax
        query = """
            %s
            %s
            %s
        """ % (
            templ % ("", bind_params),
            minus_op,
            templ % ("not", bind_params),
        )
    h = rhnSQL.prepare(query)
    h.execute(**params)
    return [x['id'] for x in h.fetchall_dict() or []]


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
    group = 300
    toDel = packageIds[:]
    print "Deleting package metadata (" + str(len(toDel)) + "):"
    pb = ProgressBar(prompt='Removing:         ', endTag=' - complete',
                     finalSize=len(packageIds), finalBarLength=40, stream=sys.stdout)
    pb.printAll(1)

    while toDel:
        _delete_rpm_group(toDel[:group])
        del toDel[:group]
        pb.addTo(group)
        pb.printIncrement()
    pb.printComplete()


def _delete_rpm_group(packageIds):

    references = [
        'rhnChannelPackage',
        'rhnErrataPackage',
        'rhnErrataPackageTMP',
        'rhnPackageChangelogRec',
        'rhnPackageConflicts',
        'rhnPackageFile',
        'rhnPackageObsoletes',
        'rhnPackageProvides',
        'rhnPackageRequires',
        'rhnPackageRecommends',
        'rhnPackageSuggests',
        'rhnPackageSupplements',
        'rhnPackageEnhances',
        'rhnPackageBreaks',
        'rhnPackagePredepends',
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
    rhnSQL.commit()


def _delete_files(relpaths):
    for relpath in relpaths:
        path = os.path.join(CFG.MOUNT_POINT, relpath)
        if not os.path.exists(path):
            log_debug(1, "Not removing %s: no such file" % path)
            continue
        unlink_package_file(path)


def _bind_many(l):
    h = {}
    lr = []
    for i, item in enumerate(l):
        key = 'p_%s' % i
        h[key] = item
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


def _delete_ks_files(channel_labels):
    sql = """
        select kt.base_path
          from rhnChannel c
          join rhnKickstartableTree kt on c.id = kt.channel_id
         where c.label in (%s) and not exists (
                select 1
                  from rhnKickstartableTree ktx
                  join rhnChannel cx on cx.id = ktx.channel_id
                 where replace(ktx.base_path, :mnt_point, '') =
                       replace(kt.base_path, :mnt_point, '')
                   and cx.label not in (%s))
    """

    params, bind_params = _bind_many(channel_labels)
    params['mnt_point'] = CFG.MOUNT_POINT + '/'
    bind_params = ', '.join(bind_params)
    h = rhnSQL.prepare(sql % (bind_params, bind_params))
    h.execute(**params)
    kickstart_list = h.fetchall_dict() or []

    for kickstart in kickstart_list:
        path = os.path.join(CFG.MOUNT_POINT, str(kickstart['base_path']))
        if not os.path.exists(path):
            log_debug(1, "Not removing %s: no such file" % path)
            continue
        shutil.rmtree(path)
