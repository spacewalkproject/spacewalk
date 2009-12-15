#
# Copyright (c) 2008 Red Hat, Inc.
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

import re
import string

# common module
from common import log_debug, rhnFlags

# local module
import rhnSQL

# Globally store the parsed capabilities in rhnFlags
def set_client_capabilities(capabilities):
    if not capabilities:
        # No capabilities presented; don't set the global flag
        return

    caps = {}
    regexp = re.compile(
        r"^(?P<name>[^(]*)\((?P<version>[^)]*)\)\s*=\s*(?P<value>.*)$")
    for cap in capabilities:
        mo = regexp.match(cap)
        if not mo:
            # XXX Just ignoring it, for now
            continue
        dict = mo.groupdict()
        name = string.strip(dict['name'])
        version = string.strip(dict['version'])
        value = string.strip(dict['value'])
        
        caps[name] = {
            'version'   : version,
            'value'     : value,
        }
        
    rhnFlags.set('client-capabilities', caps)
    log_debug(4, "Client capabilities", caps)

def get_client_capabilities():
    return rhnFlags.get('client-capabilities')

def get_db_client_capabilities(server_id):
    h = rhnSQL.prepare("""
        select cc.capability_name_id, ccn.name capability, cc.version
        from rhnClientCapability cc, rhnClientCapabilityName ccn
        where cc.server_id = :server_id
        and cc.capability_name_id = ccn.id
    """)
    h.execute(server_id=server_id)
    ret = {}
    while 1:
        row = h.fetchone_dict()
        if not row:
            break
        name = row['capability']
        version = row['version']
        value = None
        ret[name] = {
            'version'   : version,
            'value'     : value,
        }
    return ret

def update_client_capabilities(server_id):
    caps = get_client_capabilities()

    if caps is None:
        caps = {}

    caps = caps.copy()

    h = rhnSQL.prepare("""
        select cc.capability_name_id, ccn.name capability, cc.version
        from rhnClientCapability cc, rhnClientCapabilityName ccn
        where cc.server_id = :server_id
        and cc.capability_name_id = ccn.id
    """)


    updates = {'server_id' : [], 'capability_name_id' : [], 'version' : []}
    deletes = {'server_id' : [], 'capability_name_id' : []}
    inserts = {'server_id' : [], 'capability' : [], 'version' : []}

    h.execute(server_id=server_id)
    while 1:
        row = h.fetchone_dict()
        if not row:
            break
        
        name = row['capability']
        version = row['version']
        capability_name_id = row['capability_name_id']

        if caps.has_key(name):
            local_ver = caps[name]['version']
            del caps[name]
            if local_ver == version:
                # Nothing to do - same version
                continue

            updates['server_id'].append(server_id)
            updates['capability_name_id'].append(capability_name_id)
            updates['version'].append(local_ver)
            continue

        # Have to delete it
        deletes['server_id'].append(server_id)
        deletes['capability_name_id'].append(capability_name_id)

    # Everything else has to be inserted
    for name, hash in caps.items():
        inserts['server_id'].append(server_id)
        inserts['capability'].append(name)
        inserts['version'].append(hash['version'])

    log_debug(5, "Deletes:", deletes)
    log_debug(5, "Updates:", updates)
    log_debug(5, "Inserts:", inserts)

    if deletes['server_id']:
        h = rhnSQL.prepare("""
            delete from rhnClientCapability
            where server_id = :server_id
            and capability_name_id = :capability_name_id
        """)
        apply(h.executemany, (), deletes)

    if updates['server_id']:
        h = rhnSQL.prepare("""
            update rhnClientCapability
            set version = :version
            where server_id = :server_id
            and capability_name_id = :capability_name_id
        """)
        apply(h.executemany, (), updates)

    if inserts['server_id']:
        h = rhnSQL.prepare("""
            insert into rhnClientCapability 
            (server_id, capability_name_id, version) 
            values (:server_id, LOOKUP_CLIENT_CAPABILITY(:capability), :version)
        """)
        apply(h.executemany, (), inserts)

    # Commit work. This can be dangerous if there is previously uncommited
    # work
    rhnSQL.commit()

def set_server_capabilities():
    try:
        ret = _set_server_capabilities()
    except rhnSQL.SQLError, e:
        if e.args[0] != 1:
            # Not a unique constraint violation
            raise
        # Try again
        ret = _set_server_capabilities()
    return ret

def _set_server_capabilities():
    # XXX Will have to figure out how to define this
    capabilities = {
        'registration.register_osad'            : {'version' : 1, 'value' : 1},
        'registration.finish_message'           : {'version' : 1, 'value' : 1},
        'registration.remaining_subscriptions'  : {'version' : 1, 'value' : 1},
        'registration.update_contact_info'      : {'version' : 1, 'value' : 1},
        'registration.delta_packages'           : {'version' : 1, 'value' : 1},
        'registration.extended_update_support'  : {'version' : 1, 'value' : 1},
        'registration.smbios'                   : {'version' : 1, 'value' : 1},
        'applet.has_base_channel'               : {'version' : 1, 'value' : 1},
        'xmlrpc.login.extra_data'               : {'version' : 1, 'value' : 1},
        'rhncfg.content.base64_decode'          : {'version' : 1, 'value' : 1},
        'rhncfg.filetype.directory'             : {'version' : 1, 'value' : 1},
        'xmlrpc.packages.extended_profile'      : {'version' : '1-2', 'value' : 1},
    }
    l = []
    for name, hashval in capabilities.items():
        l.append("%s(%s)=%s" % (name, hashval['version'], hashval['value']))

    log_debug(4, "Setting capabilities", l)
    rhnFlags.get("outputTransportOptions")['X-RHN-Server-Capability'] = l
