#
# Copyright (c) 2008--2011 Red Hat, Inc.
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
# config file-related queuing functions
#

from spacewalk.common.rhnLog import log_debug
from spacewalk.server import rhnSQL

# the "exposed" functions
__rhnexport__ = ['install', 'remove', 'patchInstall', 'patchRemove',
    'patchClusterInstall', 'patchClusterRemove', 'refresh_list', ]

_query_lookup_action_package = rhnSQL.Statement("""
    select ap.id
      from rhnActionPackage ap
     where ap.action_id = :action_id
       and ap.name_id = LOOKUP_PACKAGE_NAME(:name)
       and ap.evr_id = LOOKUP_EVR(:epoch, :version, :release)
""")

_query_delete_server_action_package_result = rhnSQL.Statement("""
    delete from rhnServerActionPackageResult
     where server_id = :server_id
       and action_package_id in
           (select ap.id
              from rhnActionPackage ap
             where ap.action_id = :action_id)
""")

_query_insert_server_action_package_result = rhnSQL.Statement("""
    insert into rhnServerActionPackageResult
           (server_id, action_package_id, result_code, stderr, stdout)
    values (:server_id, :action_package_id, :result_code, :stdout_data,
            :stderr_data)
""")

def install(server_id, action_id, data={}):
    log_debug(1, "Result", data)
    # Data is a dict of:
    #   version = 0
    #   name = "solarispkgs.install"
    #   status = [
    #       [(n, v, r, a), (ret, stdout, stderr)],
    #       ...
    #   ]
    h = rhnSQL.prepare(_query_lookup_action_package)
    key_id = {}
    status_data = data.get('status', [])
    for k, v in status_data:
        params = {
            'action_id' : action_id,
            'name'      : k[0],
            'version'   : k[1],
            'release'   : k[2],
            'epoch'     : None,
        }
        apply(h.execute, (), params)
        row = h.fetchone_dict()
        if not row:
            log_debug(4, "action_id: %d; server_id: %s; package specified, "
                "but not found in rhnActionPackage: %s" % (
                action_id, server_id, k))
            continue
        k = tuple(k)
        key_id[k] = (row['id'], v)

    # Remove old entries, if present
    h = rhnSQL.prepare(_query_delete_server_action_package_result)
    h.execute(server_id=server_id, action_id=action_id)
    
    # Insert new entries
    h = rhnSQL.prepare(_query_insert_server_action_package_result, blob_map={'stdout_data': 'stdout_data', 'stderr_data': 'stderr_data'} )
    for k, (action_package_id, v) in key_id.items():
        result_code, stdout_data, stderr_data = v[:3]
        if stdout_data:
            stdout_data = str(stdout_data or "")
        if stderr_data:
            stderr_data = str(stderr_data or "")
        if not (stdout_data or stderr_data):
            # Nothing to do
            continue
        h.execute(server_id=server_id, action_package_id=action_package_id,
            result_code=result_code, stdout_data=stdout_data, stderr_data=stderr_data)

remove = install

patchInstall = install

patchRemove = install

patchClusterInstall = install

patchClusterRemove = install

def refresh_list(server_id, action_id, data={}):
    if not data:
        return
    log_debug("action_extra_data.packages.refresh_list: Should do something "
        "useful with this data", server_id, action_id, data)
