#
# Copyright (c) 2012 Red Hat, Inc.
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

import xml.dom.minidom
from base64 import decodestring
from spacewalk.common.rhnLog import log_debug, log_error
from spacewalk.server import rhnSQL

__rhnexport__ = ['xccdf_eval']

def xccdf_eval(server_id, action_id, data={}):
    log_debug(3)
    h = rhnSQL.prepare(_query_clear_tresult)
    h.execute(server_id=server_id, action_id=action_id)
    if not data:
        log_debug(4, "No data sent by client")
        return

    for item in ('resume', 'errors'):
        data[item] = decodestring(data[item])

    resume = xml.dom.minidom.parseString(data['resume'])
    benchmark = resume.getElementsByTagName('benchmark-resume')[0]
    profiles = benchmark.getElementsByTagName('profile') or [_dummyDefaultProfile()]
    testresults = benchmark.getElementsByTagName('TestResult')
    if len(profiles) < 1 or len(testresults) < 1:
        log_error('Scap report misses profile or testresult element')
        return
    if len(profiles) != 1 or len(testresults) != 1:
        log_error('Scap report containst multiple results',
            len(profiles), len(testresults))
    _process_testresult(testresults[0], server_id, action_id, benchmark,
        profiles[0], data['errors'])


def _process_testresult(tr, server_id, action_id, benchmark, profile, errors):
    start_time = None
    if tr.hasAttribute('start-time'):
        start_time = tr.getAttribute('start-time')

    h = rhnSQL.prepare(_query_insert_tresult, blob_map={'errors': 'errors'})
    h.execute(server_id=server_id,
        action_id=action_id,
        bench_id=_truncate(benchmark.getAttribute('id'), 120),
        bench_version=_truncate(benchmark.getAttribute('version'), 80),
        profile_id=profile.getAttribute('id'),
        profile_title=_truncate(profile.getAttribute('title'), 120),
        identifier=_truncate(tr.getAttribute('id'), 120),
        start_time=start_time.replace('T',' '),
        end_time=tr.getAttribute('end-time').replace('T', ' '),
        errors=errors
        )
    h = rhnSQL.prepare(_query_get_tresult)
    h.execute(server_id=server_id, action_id=action_id)
    testresult_id = h.fetchone()[0]
    if not _process_ruleresults(testresult_id, tr):
        h = rhnSQL.prepare(_query_update_errors, blob_map={'errors': 'errors'})
        h.execute(testresult_id=testresult_id,
            errors=errors +
            '\nSome text strings were truncated when saving to the database.')

truncated = False

def _process_ruleresults(testresult_id, tr):
    global truncated
    truncated = False
    inserts = {'rr_id': [], 'system': [], 'ident': []}
    for result in tr.childNodes:
        for rr in result.childNodes:
            rr_id = _create_rresult(testresult_id, result.nodeName)

            inserts['rr_id'].append(rr_id)
            inserts['system'].append('#IDREF#')
            inserts['ident'].append(_truncate(rr.getAttribute('id'), 100))
            for ident in rr.childNodes:
                inserts['rr_id'].append(rr_id)
                inserts['system'].append(_truncate(ident.getAttribute('system'), 80))
                inserts['ident'].append(_truncate(_get_text(ident), 100))
    _store_idents(inserts)
    return not truncated

def _truncate(string, max_len):
    global truncated
    if len(string) > max_len:
        truncated = True
        return string[:max_len-3] + "..."
    return string

def _create_rresult(testresult_id, result_label):
    rr_id = rhnSQL.Sequence("rhn_xccdf_rresult_id_seq")()
    h = rhnSQL.prepare(_query_insert_rresult)
    h.execute(rr_id=rr_id, testresult_id=testresult_id,
            result_label=result_label)
    return rr_id

def _store_idents(data):
    h = rhnSQL.prepare(_query_insert_identmap)
    rowcount = h.execute_bulk(data)
    log_debug(5, "Inserted xccdf_ruleresults rows:", rowcount)

def _get_text(node):
    rc = []
    for node in node.childNodes:
        if node.nodeType == node.TEXT_NODE:
            rc.append(node.data)
    return ''.join(rc)

class _dummyDefaultProfile:
    def getAttribute(self, name):
        if name == 'id':
            return 'None'
        elif name == 'title':
            return 'No profile selected. Using defaults.'
        return ''

_query_clear_tresult = rhnSQL.Statement("""
delete from rhnXccdfTestresult
 where server_id = :server_id
   and action_scap_id = (
    select id from rhnActionScap
     where action_id = :action_id)
""")

_query_insert_tresult = rhnSQL.Statement("""
insert into rhnXccdfTestresult(
    id,
    server_id,
    action_scap_id,
    benchmark_id,
    profile_id,
    identifier,
    start_time,
    end_time,
    errors)
values (
    sequence_nextval('rhn_xccdf_tresult_id_seq'),
    :server_id,
    (select ras.id
       from rhnActionScap ras
      where ras.action_id = :action_id),
    lookup_xccdf_benchmark(:bench_id, :bench_version),
    lookup_xccdf_profile(:profile_id, :profile_title),
    :identifier,
    TO_TIMESTAMP(:start_time, 'YYYY-MM-DD HH24:MI:SS'),
    TO_TIMESTAMP(:end_time, 'YYYY-MM-DD HH24:MI:SS'),
    :errors
    )
""")

_query_get_tresult = rhnSQL.Statement("""
select id from rhnXccdfTestresult
    where server_id = :server_id
    and action_scap_id = (
        select ras.id
            from rhnActionScap ras
             where ras.action_id = :action_id
    )
""")

_query_insert_rresult = """
insert into rhnXccdfRuleresult (id, testresult_id, result_id)
values (
    :rr_id,
    :testresult_id,
    (select rt.id
        from rhnXccdfRuleresultType rt
        where rt.label = :result_label)
    )
"""

_query_insert_identmap = rhnSQL.Statement("""
insert into rhnXccdfRuleIdentMap (rresult_id, ident_id)
values (
    :rr_id,
    lookup_xccdf_ident(:system, :ident)
    )
""")

_query_update_errors = rhnSQL.Statement("""
update rhnXccdfTestresult
set errors = :errors
where id = :testresult_id
""")

