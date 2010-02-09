-- created by Oraschemadoc Fri Jan 22 13:40:42 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "SPACEWALK"."RHNHISTORYVIEW_REFRESH" ("EVENT_ID", "SERVER_ID", "SUMMARY", "DETAILS", "CREATED", "MODIFIED") AS
  select
    sa.action_id event_id,
    sa.server_id,
    -- summary
    at.name || ' scheduled by ' || contact.login || ' (' || astat.name || ')' summary,
    -- details
    'This action will be executed after ' ||
        to_char(a.earliest_action, 'YYYY-MM-DD HH24:MI:SS') || ' EST' || chr(10) || chr(10) ||
	'The current action status is: ' || astat.name || chr(10) ||
	nvl2(sa.pickup_time,
	    'The client picked up this action on ' ||
	        to_char(sa.pickup_time, 'YYYY-MM-DD HH24:MI:SS') || ' EST',
	    'This action has not been picked up') || chr(10) ||
	nvl2(sa.completion_time,
	    'The client reported completion on execution on ' ||
	        to_char(sa.completion_time, 'YYYY-MM-DD HH24:MI:SS') || ' EST',
	    'This action has not been fully executed') || chr(10) ||
	nvl2(sa.result_code,
	    'Client execution returned code '||to_char(sa.result_code)||
	        ' ('||nvl(sa.result_msg, 'SUCCESS')||')',
	    '') ||
	chr(10) ||
	'' details,
    a.created,
    sa.modified
from
    rhnAction a, rhnServerAction sa,
    rhnActionType at, rhnActionStatus astat,
    web_contact contact
where
    sa.action_id = a.id
and a.action_type = at.id
and a.scheduler = contact.id
and sa.status = astat.id
and at.label in ('packages.refresh_list', 'hardware.refresh_list', 'reboot.reboot', 'rollback.rollback')
with
    read only
 
/
