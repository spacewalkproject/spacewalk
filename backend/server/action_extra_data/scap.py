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
    profiles = benchmark.getElementsByTagName('profile')
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
        bench_id=benchmark.getAttribute('id'),
        bench_version=benchmark.getAttribute('version'),
        profile_id=profile.getAttribute('id'),
        profile_title=profile.getAttribute('title'),
        identifier=tr.getAttribute('id'),
        start_time=start_time.replace('T',' '),
        end_time=tr.getAttribute('end-time').replace('T', ' '),
        errors=errors
        )
    h = rhnSQL.prepare(_query_get_tresult)
    h.execute(server_id=server_id, action_id=action_id)
    _process_ruleresults(h.fetchone()[0], tr)

def _process_ruleresults(testresult_id, tr):
    inserts = {'tr_id': [], 'system': [], 'ident': [], 'type': []}
    for rule_result in tr.childNodes:
        for ident in rule_result.childNodes:
            inserts['tr_id'].append(testresult_id)
            inserts['system'].append(ident.getAttribute('system'))
            inserts['ident'].append(_get_text(ident))
            inserts['type'].append(rule_result.nodeName)
    _store_ruleresults(inserts)

def _store_ruleresults(data):
    h = rhnSQL.prepare(_query_insert_ruleresult)
    rowcount = h.execute_bulk(data)
    log_debug(5, "Inserted xccdf_ruleresults rows:", rowcount)

def _get_text(node):
    rc = []
    for node in node.childNodes:
        if node.nodeType == node.TEXT_NODE:
            rc.append(node.data)
    return ''.join(rc)

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

_query_insert_ruleresult = rhnSQL.Statement("""
insert into rhnXccdfRuleresult (testresult_id, ident_id, result_id)
values (
    :tr_id,
    lookup_xccdf_ident(:system, :ident),
    (select rt.id
        from rhnXccdfRuleresultType rt
        where rt.label = :type)
    )
""")
