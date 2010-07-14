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
# package-related queuing functions
#
# As a response to a queue.get, retrieves/deletes a queued action from
# the DB.
#

from common import log_debug
from server import rhnSQL, rhnCapability
from server.rhnLib import InvalidAction

# the "exposed" functions
__rhnexport__ = ['update',
                 'remove',
                 'refresh_list',
                 'runTransaction',
                 'verify']

_query_action_verify_packages = rhnSQL.Statement("""
    select distinct
           pn.name name,
           pe.version version,
           pe.release release,
           pe.epoch epoch,
           pa.label arch
      from rhnActionPackage ap,
           rhnPackageName pn,
           rhnPackageEVR pe,
           rhnPackageArch pa
     where ap.action_id = :actionid
       and ap.evr_id = pe.id
       and ap.name_id = pn.id
       and ap.package_arch_id = pa.id (+)
""")
def verify(serverId, actionId, dry_run=0):
    log_debug(3, dry_run)
    h = rhnSQL.prepare(_query_action_verify_packages)
    h.execute(actionid=actionId)
    tmppackages = h.fetchall_dict()

    if not tmppackages:
        raise InvalidAction("invalid action %s for server %s" % 
            (actionId, serverId))

    packages = []
    
    for package in tmppackages:
            
        packages.append([package['name'],
                         package['version'],
                         package['release'],
                         package['epoch'] or '',
                         package['arch'] or ''])
    log_debug(4, packages)
    return packages


def handle_action(serverId, actionId, packagesIn, dry_run=0):
    log_debug(3, serverId, actionId, dry_run)

    client_caps = rhnCapability.get_client_capabilities()
    log_debug(3,"Client Capabilities", client_caps)
    multiarch = 0
    if client_caps and client_caps.has_key('packages.update'):
        cap_info =  client_caps['packages.update']
        if cap_info['version'] > 1:
            multiarch = 1
    if not packagesIn:
        raise InvalidAction("Packages scheduled in action %s for server %s could not be found." %
            (actionId, serverId))

    packages = []
    for package in packagesIn:
        # Fix the epoch
        if package['epoch'] is None:
            package['epoch'] = ""
        pkg_arch = ''
        if multiarch:
            pkg_arch = package['arch'] or ''

        packages.append([package['name'],
                         package['version'] or '',
                         package['release'] or '',
                         package['epoch'],
                         pkg_arch])

    log_debug(4, packages)
    return packages


def remove(serverId, actionId, dry_run=0):
    h = rhnSQL.prepare(_packageStatement_remove)
    h.execute(serverid=serverId, actionid=actionId)
    tmppackages = h.fetchall_dict()
    return handle_action(serverId, actionId, tmppackages, dry_run)

def update(serverId, actionId, dry_run=0):
    h = rhnSQL.prepare(_packageStatement_update)
    h.execute(serverid=serverId, actionid=actionId)
    tmppackages = h.fetchall_dict()
    return handle_action(serverId, actionId, tmppackages, dry_run)


def refresh_list(serverId, actionId, dry_run=0):
    """ Call the equivalent of up2date -p.
    
        I.e. update the list of a client's installed packages known by
        Red Hat's DB.
    """
    log_debug(3)
    return None

def runTransaction(server_id, action_id, dry_run=0):
    log_debug(3, server_id, action_id, dry_run)

    # Fetch package_delta_id
    h = rhnSQL.prepare("""
        select package_delta_id
        from rhnActionPackageDelta
        where action_id = :action_id
    """)
    h.execute(action_id=action_id)
    row = h.fetchone_dict()
    if row is None:
        raise InvalidAction("invalid packages.runTransaction action %s for server %s" %
            (action_id, server_id))

    package_delta_id = row['package_delta_id']

    # Fetch packages
    h = rhnSQL.prepare("""
        select tro.label operation, pn.name, pe.version, pe.release, pe.epoch,
               pa.label package_arch
          from rhnPackageDeltaElement pde, rhnTransactionPackage rp,
            rhnTransactionOperation tro, rhnPackageName pn, rhnPackageEVR pe,
            rhnPackageArch pa
         where pde.package_delta_id = :package_delta_id
           and pde.transaction_package_id = rp.id
           and rp.operation = tro.id
           and rp.name_id = pn.id
           and rp.evr_id = pe.id
           and rp.package_arch_id = pa.id (+)
        order by tro.label, pn.name
    """)
    h.execute(package_delta_id=package_delta_id)

    result = []
    while 1:
        row = h.fetchone_dict()
        if not row:
            break

        operation = row['operation']

        # Need to map the operations into codes the client/rpm understands
        if operation == 'insert':
            operation = 'i'
        elif operation == 'delete':
            operation = 'e'
        elif operation == 'upgrade':
            operation = 'u'
        else:
            # Unsupported
            continue
        
        # Fix null epochs
        epoch = row['epoch']
        if epoch is None:
            epoch = ''

        name, version, release = row['name'], row['version'], row['release']
        # The package arch can be null now because of the outer join
        package_arch = row['package_arch'] or ""
        
        result.append([
            [name, version, release, epoch, package_arch], 
            operation
        ])
    return { 'packages' : result }

# SQL statements -- used by update()
_packageStatement_update = """
    select distinct
        pn.name name,
        pe.epoch epoch,
        pe.version version,
        pe.release release,
        pa.label  arch
    from rhnActionPackage ap,
        rhnPackage p,
        rhnPackageName pn,
        rhnPackageEVR pe,
        rhnPackageArch pa,
        rhnServerChannel sc,
        rhnChannelPackage cp
    where ap.action_id = :actionid
        and ap.evr_id is not null
        and ap.evr_id = p.evr_id
        and ap.evr_id = pe.id
        and ap.name_id = p.name_id
        and ap.name_id = pn.id
        and ap.package_arch_id = pa.id(+)
        and p.id = cp.package_id
        and cp.channel_id = sc.channel_id
        and sc.server_id = :serverid
    union
    select distinct
        pn.name name,
        null version,
        null release,
        null epoch,
        pa.label arch
    from rhnActionPackage ap,
        rhnPackage p,
        rhnPackageName pn,
        rhnPackageArch pa,
        rhnServerChannel sc,
        rhnChannelPackage cp
    where ap.action_id = :actionid
        and ap.evr_id is null
        and ap.name_id = p.name_id
        and p.name_id = pn.id
        and ap.package_arch_id = pa.id(+)
        and p.id = cp.package_id
        and cp.channel_id = sc.channel_id
        and sc.server_id = :serverid"""

_packageStatement_remove = """
    select distinct
        pn.name name,
        pe.epoch epoch,
        pe.version version,
        pe.release release,
        pa.label  arch
    from rhnActionPackage ap,
        rhnPackageName pn,
        rhnPackageEVR pe,
        rhnPackageArch pa,
        rhnServerPackage sp
    where ap.action_id = :actionid
        and ap.evr_id is not null
        and ap.evr_id = pe.id
        and ap.name_id = pn.id
        and ap.package_arch_id = pa.id(+)
        and sp.server_id = :serverid
        and sp.name_id = ap.name_id
        and sp.evr_id = ap.evr_id
        and (sp.package_arch_id = ap.package_arch_id or sp.package_arch_id is null)
    union
    select distinct
        pn.name name,
        null version,
        null release,
        null epoch,
        pa.label arch
    from rhnActionPackage ap,
        rhnPackageName pn,
        rhnPackageArch pa,
        rhnServerPackage sp
    where ap.action_id = :actionid
        and ap.evr_id is null
        and ap.package_arch_id = pa.id(+)
        and sp.server_id = :serverid
        and (sp.package_arch_id = ap.package_arch_id or sp.package_arch_id is null)"""

