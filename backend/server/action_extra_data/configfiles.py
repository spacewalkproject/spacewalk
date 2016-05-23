#
# Copyright (c) 2008--2016 Red Hat, Inc.
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
# config file-related error handling functions
#

from spacewalk.common import rhnFlags
from spacewalk.common.rhnLog import log_debug, log_error
from spacewalk.common.stringutils import to_string
from spacewalk.server import rhnSQL
from spacewalk.server.rhnServer import server_kickstart

# the "exposed" functions
__rhnexport__ = ['upload', 'deploy', 'verify', 'diff', 'mtime_upload']

_query_reset_upload_files = rhnSQL.Statement("""
    update rhnActionConfigFileName
       set failure_id = NULL
     where server_id = :server_id
       and action_id = :action_id
""")
_query_mark_upload_files = rhnSQL.Statement("""
    update rhnActionConfigFileName
       set failure_id = :failure_id
     where server_id = :server_id
       and action_id = :action_id
       and config_file_name_id = lookup_config_filename(:path)
""")


def upload(server_id, action_id, data={}):
    log_debug(3)

    # First, unmark any file as being failed
    h = rhnSQL.prepare(_query_reset_upload_files)
    h.execute(server_id=server_id, action_id=action_id)

    if not data:
        log_debug(4, "No data sent by client")
        return

    log_debug(6, 'data', data)

    failure_table = rhnSQL.Table('rhnConfigFileFailure', 'label')
    h = rhnSQL.prepare(_query_mark_upload_files)
    # We don't do execute_bulk here, since we want to know if each update has
    # actually touched a row

    reason_map = {'missing_files': 'missing',
                  'files_too_large': 'too_big',
                  'quota_failed': 'insufficient_quota',
                  }

    for reason in reason_map.keys():
        log_debug(6, 'reason', reason)
        failed_files = data.get(reason)
        log_debug(6, 'failed_files', failed_files)
        if not failed_files:
            continue

        failure_id = failure_table[reason_map[reason]]['id']
        log_debug(6, 'failure_id', failure_id)

        for path in failed_files:
            log_debug(6, 'path', path)
            ret = h.execute(server_id=server_id, action_id=action_id,
                            failure_id=failure_id, path=path)
            if not ret:
                log_error("Could not find file %s for server %s, action %s" %
                          (path, server_id, action_id))


_query_any_action_config_filenames = rhnSQL.Statement("""
    select config_file_name_id
      from rhnActionConfigFileName
     where server_id = :server_id
       and action_id = :action_id
""")
_query_clear_action_config_filenames = rhnSQL.Statement("""
    delete from rhnActionConfigFileName
     where server_id = :server_id
       and action_id = :action_id
""")
_query_create_action_config_filename = rhnSQL.Statement("""
    insert into rhnActionConfigFileName (action_id, config_file_name_id, server_id)
    values (:action_id, lookup_config_filename(:path), :server_id)
""")


def mtime_upload(server_id, action_id, data={}):
    # at this point in time, no rhnActionConfigFileName entries exist, because
    # we didn't know them at schedule time...  go ahead and create them now, and then
    # just use the main upload to handle the updating of the state...
    paths = data.get('attempted_paths') or []

    if not paths:
        log_debug(6, "no matched files")
        return

    log_debug(6, 'attempted paths', paths)

    # if there are already rhnActionConfigFileName entries for this sid+aid,
    # it's most likely a rescheduled action, and we'll need to blow away the old
    # entries (they might not be valid any longer)
    h = rhnSQL.prepare(_query_any_action_config_filenames)
    h.execute(server_id=server_id, action_id=action_id)
    already_filenames = h.fetchone_dict() or []

    if already_filenames:
        h = rhnSQL.prepare(_query_clear_action_config_filenames)
        h.execute(server_id=server_id, action_id=action_id)

    num_paths = len(paths)

    h = rhnSQL.prepare(_query_create_action_config_filename)
    h.execute_bulk({
        'action_id': [action_id] * num_paths,
        'server_id': [server_id] * num_paths,
        'path': paths,
    })

    upload(server_id, action_id, data)


def deploy(server_id, action_id, data={}):
    log_debug(3)

    action_status = rhnFlags.get('action_status')
    server_kickstart.update_kickstart_session(server_id,
                                              action_id, action_status, kickstart_state='complete',
                                              next_action_type=None)
    return


def diff(server_id, action_id, data={}):
    log_debug(3)
    if not data:
        # Nothing to do here
        return
    status = rhnFlags.get('action_status')
    if status == 2:
        # Completed
        _reset_diff_errors(server_id, action_id)
        missing_files = data.get('missing_files') or []
        _mark_missing_diff_files(server_id, action_id, missing_files)
        diffs = data.get('diffs') or {}
        _process_diffs(server_id, action_id, diffs)

verify = diff

_query_reset_diff_errors = rhnSQL.Statement("""
    update rhnActionConfigRevision
       set failure_id = NULL
     where server_id = :server_id
       and action_id = :action_id
""")


def _reset_diff_errors(server_id, action_id):
    h = rhnSQL.prepare(_query_reset_diff_errors)
    h.execute(server_id=server_id, action_id=action_id)

_query_lookup_diff_files = rhnSQL.Statement("""
    select acr.id, cfn.path
      from rhnConfigFileName cfn,
           rhnConfigFile cf,
           rhnConfigRevision cr,
           rhnActionConfigRevision acr
     where acr.server_id = :server_id
       and acr.action_id = :action_id
       and acr.config_revision_id = cr.id
       and cr.config_file_id = cf.id
       and cf.config_file_name_id = cfn.id
""")
_query_mark_failed_diff_files = rhnSQL.Statement("""
    update rhnActionConfigRevision
       set failure_id = :failure_id
     where id = :action_config_revision_id
""")


def _mark_missing_diff_files(server_id, action_id, missing_files):
    if not missing_files:
        # Nothing to do
        log_debug(4, "No missing files reported by client")
        return
    # First, fetch all of the files scheduled
    h = rhnSQL.prepare(_query_lookup_diff_files)
    h.execute(server_id=server_id, action_id=action_id)
    hash = {}
    while 1:
        row = h.fetchone_dict()
        if not row:
            break
        action_config_revision_id, path = row['id'], row['path']
        if path in hash:
            # This shouldn't really happen
            log_error("Duplicate path for diff "
                      "(scheduler did not resolve config files? %s, %s" %
                      (hash[path], action_config_revision_id))
        else:
            hash[path] = action_config_revision_id

    ids = []
    for path in missing_files:
        if path not in hash:
            log_error("Client reports missing a file "
                      "that was not scheduled for diff? %s" % path)
            continue
        ids.append(hash[path])
    if not ids:
        log_debug(4, "No missing files found")
        return
    failure_table = rhnSQL.Table('rhnConfigFileFailure', 'label')
    failure_id = failure_table['missing']['id']
    failure_ids = [failure_id] * len(ids)

    h = rhnSQL.prepare(_query_mark_failed_diff_files)
    h.execute_bulk({
        'action_config_revision_id': ids,
        'failure_id': failure_ids,
    })


def _process_diffs(server_id, action_id, diffs):
    _disable_old_diffs(server_id)
    for file_path, diff in diffs.items():
        action_config_revision_id = _lookup_action_revision_id(server_id,
                                                               action_id, file_path)
        if action_config_revision_id is None:
            log_error(
                "Missing config file for action id %s, server id %s, path %s"
                % (server_id, action_id, file_path))
            continue
        _add_result(action_config_revision_id, diff)

_query_lookup_action_revision_id = rhnSQL.Statement("""
    select acr.id
      from rhnConfigRevision cr, rhnConfigFile cf, rhnActionConfigRevision acr
     where acr.action_id = :action_id
       and acr.server_id = :server_id
       and acr.config_revision_id = cr.id
       and cr.config_file_id = cf.id
       and cf.config_file_name_id = lookup_config_filename(:path)
""")


def _lookup_action_revision_id(server_id, action_id, path):
    h = rhnSQL.prepare(_query_lookup_action_revision_id)
    h.execute(server_id=server_id, action_id=action_id, path=path)
    row = h.fetchone_dict()
    if not row:
        return None
    return row['id']

_query_add_result_diff = rhnSQL.Statement("""
    insert into rhnActionConfigRevisionResult
           (action_config_revision_id, result)
    values (:action_config_revision_id, :result)
""")


def _add_result(action_config_revision_id, diff):

    log_debug(4, action_config_revision_id, diff)

    if diff:
        blob_map = {'result': 'result'}
        diff = to_string(diff)
    else:
        blob_map = None
        diff = None

    h = rhnSQL.prepare(_query_add_result_diff, blob_map=blob_map)
    h.execute(action_config_revision_id=action_config_revision_id,
              result=diff)

_query_lookup_old_diffs = rhnSQL.Statement("""
    select acr.id
      from rhnActionConfigRevision acr
     where acr.server_id = :server_id
""")

_query_delete_old_diffs = rhnSQL.Statement("""
    delete from rhnActionConfigRevisionResult
     where action_config_revision_id = :action_config_revision_id
""")


def _disable_old_diffs(server_id):
    h = rhnSQL.prepare(_query_lookup_old_diffs)
    h.execute(server_id=server_id)
    old_acr_ids = [x['id'] for x in h.fetchall_dict() or []]
    if not old_acr_ids:
        # Nothing to do here
        return

    h = rhnSQL.prepare(_query_delete_old_diffs)
    h.execute_bulk({'action_config_revision_id': old_acr_ids})
