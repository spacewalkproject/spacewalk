#
# Copyright (c) 2008--2009 Red Hat, Inc.
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

import time

from common import log_debug
from server import rhnSQL, rhnServer
from server.configFilesHandler import format_file_results
from server.config_common.templated_document import var_interp_prep

# the "exposed" functions
__rhnexport__ = ['upload', 'deploy', 'verify', 'diff', 'mtime_upload']

_query_upload_files = rhnSQL.Statement("""
    select cfn.path
      from rhnActionConfigFileName acfn, rhnConfigFileName cfn
     where acfn.server_id = :server_id
       and acfn.action_id = :action_id
       and acfn.config_file_name_id = cfn.id
""")

_query_mtime_upload_info = rhnSQL.Statement("""
    select TO_CHAR(start_date, 'YYYY-MM-DD HH24:MI:SS') as start_date,
           TO_CHAR(end_date, 'YYYY-MM-DD HH24:MI:SS') as end_date,
           TO_CHAR(sysdate, 'YYYY-MM-DD HH24:MI:SS') as now,
           import_contents
      from rhnActionConfigDate
     where action_id = :action_id
""")

_query_mtime_upload_paths = rhnSQL.Statement("""
    select file_name,
           file_type
      from rhnActionConfigDateFile
     where action_id = :action_id
""")

def mtime_upload(server_id, action_id):
    log_debug(3)

    data = {}

    h = rhnSQL.prepare(_query_mtime_upload_info)
    h.execute(action_id=action_id)

    info = h.fetchone_dict()
    info['start_date'] = time.mktime(time.strptime(info['start_date'], '%Y-%m-%d %H:%M:%S'))
    info['now'] = time.mktime(time.strptime(info['now'], '%Y-%m-%d %H:%M:%S'))

    if info['end_date']:
        info['end_date'] = time.mktime(time.strptime(info['end_date'], '%Y-%m-%d %H:%M:%S'))
    else:
        info['end_date'] = ''

    data['info'] = info

    data['search'] = []
    data['ignore'] = []

    h = rhnSQL.prepare(_query_mtime_upload_paths)
    h.execute(action_id=action_id)

    while 1:
        row = h.fetchone_dict() or []

        if not row:
            break

        if row['file_type'] == 'W':
            data['search'].append(row['file_name'])
        elif row['file_type'] == 'B':
            data['ignore'].append(row['file_name'])

    log_debug(4, 'data', data)
    
    return action_id, data


def upload(server_id, action_id):
    log_debug(3)
    h = rhnSQL.prepare(_query_upload_files)
    h.execute(action_id=action_id, server_id=server_id)
    files = map(lambda x: x['path'], h.fetchall_dict() or [])

    return action_id, files

def deploy(server_id, action_id):
    log_debug(3)
    return _get_files(server_id, action_id)

def verify(server_id, action_id):
    log_debug(3)
    return _get_files(server_id, action_id)

def diff(server_id, action_id):
    log_debug(3)
    return _get_files(server_id, action_id)

_query_get_files = rhnSQL.Statement("""
    select cfn.path,
           cc.label config_channel,
           ccont.contents file_contents,
           ccont.is_binary is_binary,
           c.checksum_type,
           c.checksum,
           cr.delim_start,
           cr.delim_end,
           cr.revision,
           ci.username,
           ci.groupname,
           ci.filemode,
	   cft.label,
	   ci.selinux_ctx
      from 
           rhnConfigFileState cfs,
           rhnConfigContent ccont,
           rhnChecksumView c,
           rhnConfigChannel cc,
           rhnConfigFileName cfn,
           rhnConfigInfo ci,
           rhnConfigFile cf,
           rhnConfigRevision cr,
	   rhnConfigFileType cft,
           rhnActionConfigRevision acr
     where acr.server_id = :server_id
       and acr.action_id = :action_id
       and acr.config_revision_id = cr.id
       and cr.config_file_id = cf.id
       and cr.config_info_id = ci.id
       and cf.config_file_name_id = cfn.id
       and cf.config_channel_id = cc.id
       and cf.state_id = cfs.id
       and cfs.label = 'alive'
       and cr.config_content_id = ccont.id
       and cr.config_file_type_id = cft.id
       and ccont.checksum_id = c.id
""")

def _get_files(server_id, action_id):
    h = rhnSQL.prepare(_query_get_files)
    h.execute(action_id=action_id, server_id=server_id)

    server = rhnServer.search(server_id)
    server = var_interp_prep(server)
    
    files = []
    while 1:
        row = h.fetchone_dict()
        if not row:
            break
        files.append(format_file_results(row, server=server))

    result = {
        'files'         : files,
    }
    return result
