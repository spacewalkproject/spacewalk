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
#

from common import log_debug
from server import rhnSQL

# the "exposed" functions
__rhnexport__ = ['install', 'remove', 'patchInstall', 'patchRemove',
    'patchClusterInstall', 'patchClusterRemove', 'refresh_list',]

_query_install = rhnSQL.Statement("""
    select distinct
           pn.name name,
           pe.epoch epoch,
           pe.version version,
           pe.release release,
           pa.label arch,
           c.label channel_label,
           nvl2(c.parent_channel, 0, 1) is_parent_channel
      from rhnActionPackage ap,
           rhnPackage p,
           rhnPackageName pn,
           rhnPackageEVR pe,
           rhnPackageArch pa,
           rhnServerChannel sc,
           rhnChannelPackage cp,
           rhnChannel c
     where ap.action_id = :action_id
       and ap.evr_id = p.evr_id
       and ap.evr_id = pe.id
       and ap.name_id = p.name_id
       and ap.name_id = pn.id
       and p.package_arch_id = pa.id
       and p.id = cp.package_id
       and cp.channel_id = sc.channel_id
       and sc.server_id = :server_id
       and sc.channel_id = c.id
""")

_query_remove = rhnSQL.Statement("""
    select distinct
           pn.name name,
           pe.epoch epoch,
           pe.version version,
           pe.release release,
           pa.label arch
      from rhnActionPackage ap,
           rhnPackageName pn,
           rhnPackageEVR pe,
           rhnPackageArch pa
     where ap.action_id = :action_id
       and ap.evr_id = pe.id
       and ap.name_id = pn.id
       and ap.package_arch_id = pa.id (+)
""")

def install(server_id, action_id, dry_run=0):
    log_debug(3, dry_run)

    h = rhnSQL.prepare(_query_install)
    h.execute(server_id=server_id, action_id=action_id)

    dict = {}
    while 1:
        ret = h.fetchone_dict()
        if not ret:
            break
        key = (ret['name'], ret['version'], ret['release'])
        channel_label = ret['channel_label']
        channel_is_parent = ret['is_parent_channel']
        val = (ret['arch'], channel_label, channel_is_parent)
        if not dict.has_key(key):
            dict[key] = val
            continue

        if not channel_is_parent:
            # Prefer this one instead
            dict[key] = val
            continue

    # Format: [(n, v, r, a, channel_label), {}]

    ret = []
    for k, v in dict.items():
        entry = ((k[0], k[1], k[2], v[0], v[1]), {})
        ret.append(entry)
    return ret

def remove(server_id, action_id, dry_run=0):
    log_debug(3, dry_run)

    h = rhnSQL.prepare(_query_remove)
    h.execute(action_id=action_id)
    ret = []
    while 1:
        row = h.fetchone_dict()
        if not row:
            break
        val = (row['name'], row['version'], row['release'], row['arch'] or "")
        ret.append((val, {}))

    return ret
    
patchInstall = install

patchRemove = remove

patchClusterInstall = install

patchClusterRemove = remove

def refresh_list(serverId, actionId, dry_run=0):
    """ Call the equivalent of up2date -p.
    
        I.e. update the list of a client's installed packages known by
        Red Hat's DB.
    """
    log_debug(3)
    return None

