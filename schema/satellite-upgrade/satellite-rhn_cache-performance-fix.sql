SET ECHO OFF;

whenever sqlerror exit;
spool satellite-rhn_cache-performance-fix.log;

variable evr_id number;
variable epoch varchar2(16);
variable version varchar2(64);
variable release varchar2(64);

variable message varchar2(80);

declare
   cursor evrs is
      select   e.id, e.epoch, e.version, e.release, e.evr
      from  rhnPackageEVR e,
         rhnVersionInfo rvi
      where rvi.label = 'schema'
         and rvi.name_id =
            lookup_package_name('rhn-satellite-schema')
         and rvi.evr_id = e.id;
   cursor valid_evrs is
      select   1
      from  dual
      where :evr_id in (
         lookup_evr('','4.0','214'),
         lookup_evr('','4.0.5','2'),
         lookup_evr('','3.7','116'),
         lookup_evr('', '4.1.0', '45')
         );
begin
   :evr_id := null;
   :message := 'XXX Invalid satellite schema version.';
   for evr in evrs loop
      :evr_id := evr.id;
      :epoch := evr.epoch;
      :version := evr.version;
      :release := evr.release;
      :message :=  '*** Schema version is currently ' ||
         evr.evr.as_vre_simple() ||
         ', and will NOT be upgraded';
      for vevr in valid_evrs loop
         :message :=  '*** Schema version is currently ' ||
            evr.evr.as_vre_simple() ||
            ', and will be upgraded';
      end loop;
      return;
   end loop;
end;
/
show errors;


set heading off;
select :message from dual;
set heading on;

declare
   invalid_schema_version exception;
   cursor valid_evrs is
      select   1
      from  dual
      where :evr_id in (
         lookup_evr('','4.0','214'),
         lookup_evr('','4.0.5','2'),
         lookup_evr('','3.7','116'),
         lookup_evr('', '4.1.0', '45')
         );
begin
   for vevr in valid_evrs loop
      return;
   end loop;
   raise invalid_schema_version;
end;
/
show errors;

set define off;

create or replace package body
rhn_cache
is
	body_version varchar2(100) := '$Id: rhn_cache.pkb 46007 2004-07-09 14:59:08Z pjones $';

	-- this searches out all users who get perms...
	procedure update_perms_for_server(
		server_id_in in number
	) is
	begin
		delete from rhnUserServerPerms where server_id = server_id_in;
		insert into rhnUserServerPerms(user_id, server_id) (
				select	distinct user_id, server_id_in
				from	rhnUserServerPermsDupes
				where	server_id = server_id_in
			);
	end update_perms_for_server;

	procedure update_perms_for_user(
		user_id_in in number
	) is
	begin
    delete from rhnUserServerPerms
    where user_id = user_id_in
        and server_id in
        (select server_id
         from rhnUserServerPerms
         where user_id = user_id_in
         minus
         select server_id
         from rhnUserServerPermsDupes uspd
         where uspd.user_id = user_id_in);
    
    insert into rhnUserServerPerms (user_id, server_id)
    select distinct user_id_in, server_id
    from rhnUserServerPermsDupes uspd
    where uspd.user_id = user_id_in
        and not exists
        (select 1
         from rhnUserServerPerms usp
         where usp.user_id = user_id_in
             and usp.server_id = uspd.server_id);
	end update_perms_for_user;

	-- this means a server got added or removed, so we
	-- can't key off of a server anywhere.
	procedure update_perms_for_server_group(
		server_group_id_in in number
	) is
		cursor users is
			-- org admins aren't affected, so don't test for them
			select	usgp.user_id id
			from	rhnUserServerGroupPerms usgp
			where	usgp.server_group_id = server_group_id_in
				and not exists (
					select	1
					from	rhnUserGroup ug,
							rhnUserGroupMembers ugm,
							rhnServerGroup sg,
							rhnUserGroupType ugt
					where	ugt.label = 'org_admin'
						and sg.id = server_group_id_in
						and ugm.user_id = usgp.user_id
						and ug.org_id = sg.org_id
						and ugm.user_group_id = ug.id
					);
	begin
		for u in users loop
			update_perms_for_user(u.id);
		end loop;
	end update_perms_for_server_group;
end rhn_cache;
/
show errors

declare
   schema_name varchar2(30);
begin
   select owner
   into schema_name
   from all_tables
   where table_name = 'RHNSERVER';

   dbms_utility.compile_schema (schema_name);
end;
/
show errors;

alter type evr_t compile body;

set echo off
set heading off;
select 'SQL applied successfully'
from dual;
set termout off;
set heading on;

commit;

spool off;

exit;
