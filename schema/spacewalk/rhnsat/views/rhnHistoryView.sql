--
-- Copyright (c) 2008 Red Hat, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
-- 
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation. 
--
-- This is a rather complex view that makes actions look more like History.
--
--

-- First the function that helps us collapse multiple rows into a single VARCHAR record
create or replace function 
rhnHistoryView_pkglist(action_id IN NUMBER, separator IN VARCHAR2 DEFAULT chr(10))
return VARCHAR2
is
    store_var  VARCHAR2(4000);
    store_tmp  VARCHAR2(4000);
    select_sql VARCHAR2(4000);
    trimmed NUMBER;
    cursor pkg_cursor(action_id_in IN NUMBER)
    is
       select
           pn.name||'-'||pevr.version||'-'||pevr.release||'.'||pa.name
       from
           rhnPackageName pn, rhnPackageEVR pevr, rhnPackageArch pa,
	   rhnActionPackage ap
       where
               ap.name_id = pn.id
	   and ap.evr_id = pevr.id
	   and ap.package_arch_id = pa.id(+)
	   and ap.action_id = action_id_in;
begin
    store_var := NULL;
    trimmed := 0;
    open pkg_cursor(action_id);
    loop
	fetch pkg_cursor into store_tmp;
	exit when pkg_cursor%NOTFOUND;
	if store_var is NULL then
	   store_var := store_tmp;
	else
	   trimmed := 1;
	   exit when length(store_var) + length(separator) + length(store_tmp) > 3700;
	   store_var := store_var || separator || store_tmp;
	   trimmed := 0;
	end if;
    end loop;
    close pkg_cursor;
    if trimmed <> 0 then
        store_var := store_var || separator || '...';
    end if;
    return store_var;
end;
/
show errors

-- same type of function for errata view
create or replace function 
rhnHistoryView_erratalist(action_id IN NUMBER, separator IN VARCHAR2 DEFAULT chr(10))
return VARCHAR2
is
    store_var  VARCHAR2(4000);
    store_tmp  VARCHAR2(4000);
    select_sql VARCHAR2(4000);
    trimmed NUMBER;
    cursor errata_cursor(action_id_in IN NUMBER, separator IN VARCHAR2 DEFAULT chr(10))
    is
       select
           'Errata Advisory: ' || e.advisory || separator ||
	   'Errata Synopsis: ' || e.synopsis || separator
       from
           rhnActionErrataUpdate ae, rhnErrata e
       where
           e.id = ae.errata_id
       and ae.action_id = action_id_in;
begin
    store_var := NULL;
    trimmed := 0;
    open errata_cursor(action_id);
    loop
	fetch errata_cursor into store_tmp;
	exit when errata_cursor%NOTFOUND;
	if store_var is NULL then
	   store_var := store_tmp;
	else
	   trimmed := 1;
	   exit when length(store_var) + length(separator) + length(store_tmp) > 3700;
	   store_var := store_var || separator || store_tmp;
	   trimmed := 0;
	end if;
    end loop;
    close errata_cursor;
    if trimmed <> 0 then
        store_var := store_var || separator || '...';
    end if;
    return store_var;
end;
/
show errors

-- show refresh actions as history items
create or replace view 
rhnHistoryView_refresh
as
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
    read only;

-- show the packages.* actions as history items
create or replace view
rhnHistoryView_packages
as
select 
    sa.action_id event_id, 
    sa.server_id, 
    -- summary
    at.name || ( select ' (' || count(name_id) || 
                        decode(count(name_id), 1, ' package) ',  ' packages) ')
                 from rhnActionPackage ap where ap.action_id = sa.action_id ) ||
    ' scheduled by ' || contact.login || ' (' || astat.name || ')' summary,
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
	chr(10) || chr(10) ||
	'Package list:' || chr(10) || rhnHistoryView_pkglist(sa.action_id) ||
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
and at.label in ('packages.update', 'packages.remove')
with
    read only;

-- show errata actions as history events
create or replace view
rhnHistoryView_errata
as
select 
    sa.action_id event_id, 
    sa.server_id, 
    -- summary
    at.name || ( select ' (' || count(errata_id) || 
                        decode(count(errata_id), 1, ' erratum) ', ' errata) ')
                 from rhnActionErrataUpdate aeu where aeu.action_id = sa.action_id ) ||
    ' scheduled by ' || contact.login || ' (' || astat.name || ')' summary,   
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
	chr(10) || chr(10) ||
	'Errata list:' || chr(10) || rhnHistoryView_erratalist(sa.action_id) ||
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
and at.label = 'errata.update'
with 
    read only;

--
-- and now the final big bad view - UNION everything in History
-- and misc action->history views in one big select
--
create or replace view
rhnHistoryView
as
select 
    id event_id, server_id, summary, details, created, modified
from
    rhnServerHistory
UNION
select * from rhnHistoryView_refresh
UNION
select * from rhnHistoryView_packages
UNION
select * from rhnHistoryView_errata
with
    read only;

--
-- Revision 1.8  2002/12/06 02:20:32  cturner
-- unify reboot.reboot and rollback.rollback with profile refresh scheduling for now for reporting.  needs improvement later, but it reports basic info now.
--
-- Revision 1.7  2002/11/14 17:20:34  pjones
-- arch -> *_arch_id and archCompat changes
--
-- Revision 1.6  2002/09/12 15:03:37  bretm
-- o  added reboot support to rhnHistoryView
--
-- Revision 1.5  2001/12/02 19:44:43  cturner
-- added timezone, fixed minute display problem, and changed to ISO date format for history fiew
--
-- Revision 1.4  2001/09/20 23:03:14  gafton
-- - split the big bad view in three little pieces
-- - use summary lines that are more informative (ie, how many
-- packages/errata and the surrect status of the action for
-- a particular server)
--
-- Revision 1.3  2001/08/24 03:18:47  gafton
-- show success where older clients don't give any status message
--
-- Revision 1.2  2001/08/09 12:05:09  gafton
-- Oops, we can have more than one errata per errata.update scheduled action
-- (kind of broken if you ask me, but what the heck)
--
-- Revision 1.1  2001/08/09 02:42:30  gafton
-- Implement rhnHistoryView
