SET ECHO OFF;

whenever sqlerror exit;
spool satellite-delete_user-procedure-fix-4.x-upgrades.log;

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

CREATE OR REPLACE
PACKAGE BODY rhn_org
IS
	body_version varchar2(100) := '$Id: rhn_org.pkb 63289 2005-08-08 18:38:03Z jesusr $';

    FUNCTION find_server_group_by_type(org_id_in NUMBER, group_label_in VARCHAR2) 
    RETURN NUMBER
    IS
	server_group       server_group_by_label%ROWTYPE;
    BEGIN
    	OPEN server_group_by_label(org_id_in, group_label_in);
	FETCH server_group_by_label INTO server_group;
	CLOSE server_group_by_label;

	RETURN server_group.id;
    END find_server_group_by_type;
    
	procedure delete_user(user_id_in in number) is
		cursor is_admin is
			select	1
			from	rhnUserGroupType	ugt,
					rhnUserGroup		ug,
					rhnUserGroupMembers	ugm
			where	ugm.user_id = user_id_in
				and ugm.user_group_id = ug.id
				and ug.group_type = ugt.id
				and ugt.label = 'org_admin';
		cursor servergroups_needing_admins is
			select	usgp.server_group_id	server_group_id
			from	rhnUserServerGroupPerms	usgp
			where	1=1
				and usgp.user_id = user_id_in
				and not exists (
					select	1
					from	rhnUserServerGroupPerms	sq_usgp
					where	1=1
						and sq_usgp.server_group_id = usgp.server_group_id
						and	sq_usgp.user_id != user_id_in
				);
		cursor servergroups_for_deletion(org_id_in in number) is
			select	sgm.server_id, sgm.server_group_id, sgt.label
			from	rhnServerGroupMembers sgm,
               rhnServerGroupType sgt,
					rhnServerGroup sg
			where	sg.org_id = org_id_in
				and sg.id = sgm.server_group_id
            and sg.group_type = sgt.id;
		cursor servers_for_deletion(org_id_in in number) is
			select	id
			from	rhnServer
			where	org_id = org_id_in;
		cursor snapshots(sgid_in in number) is
			select	snapshot_id id
			from	rhnSnapshotServerGroup
			where	server_group_id = sgid_in;
		cursor messages is
			select	message_id id
			from	rhnUserMessage
			where	user_id = user_id_in;
		users			number;
		our_org_id		number;
		del_check_ok	number;
		other_users		number;
		other_org_admin	number;
      other_user_id  number;
	begin
		select	wc.org_id, xxrh_contact_del_check_num(user_id_in)
		into	our_org_id, del_check_ok
		from	web_contact wc
		where	id = user_id_in;

		-- bail early if we know it won't work
		if del_check_ok != 1 then
			rhn_exception.raise_exception('cannot_delete_user');
			return;
		end if;

		-- find any other users
		begin
			select	id, 1
			into	other_user_id, other_users
			from	web_contact
			where	1=1
				and org_id = our_org_id
				and id != user_id_in
				and rownum = 1;
		exception
			when no_data_found then
				other_users := 0;
		end;

		-- now do org admin stuff
		if other_users != 0 then
			for ignore in is_admin loop
				begin 
					select	new_ugm.user_id
					into	other_org_admin
					from	rhnUserGroupMembers	new_ugm,
							rhnUserGroupType	ugt,
							rhnUserGroup		ug,
							rhnUserGroupMembers	ugm
					where	ugm.user_id = user_id_in
						and ugm.user_group_id = ug.id
						and ug.group_type = ugt.id
						and ugt.label = 'org_admin'
						and ug.id = new_ugm.user_group_id
						and new_ugm.user_id != user_id_in
						and rownum = 1;
				exception
					when no_data_found then
						rhn_exception.raise_exception('cannot_delete_user');
				end;

				for sg in servergroups_needing_admins loop
					rhn_user.add_servergroup_perm(other_org_admin,
						sg.server_group_id);
				end loop;
			end loop;
		end if;

		-- and now things for every user
		for message in messages loop
			delete
				from	rhnUserMessage
				where	user_id = user_id_in
					and message_id = message.id;
			begin
				select	1
				into	users
				from	rhnUserMessage
				where	message_id = message.id
					and rownum = 1;
				delete
					from	rhnMessage
					where	id = message.id;
			exception
				when no_data_found then
					null;
			end;
		end loop;
		delete from rhn_command_queue_sessions where contact_id = user_id_in;
		delete from rhn_contact_methods where contact_id = user_id_in;
		delete from rhn_redirects where contact_id = user_id_in;
		delete from rhnUserServerPerms where user_id = user_id_in;
		if other_users != 0 then
			update		rhnRegToken
				set		user_id = nvl(other_org_admin, other_user_id)
				where	org_id = our_org_id
					and user_id = user_id_in;
			begin
				delete from web_contact where id = user_id_in;
			exception
				when others then
					rhn_exception.raise_exception('cannot_delete_user');
			end;
		else
			-- so that the delete trigger doesn't bite us
			for sgm in servergroups_for_deletion(our_org_id) loop
				for snapshot in snapshots(sgm.server_group_id) loop
					update rhnSnapshot
						set invalid =
							lookup_snapshot_invalid_reason('sg_removed')
						where id = snapshot.id;
					delete from rhnSnapshotServerGroup
						where snapshot_id = snapshot.id
						and server_group_id = sgm.server_group_id;
				end loop;


            insert into rhnServerHistory ( id, server_id, summary, details )
            values ( rhn_event_id_seq.nextval, sgm.server_id,
                   'removed system entitlement ',
                    case sgm.label 
                    when 'enterprise_entitled' then 'Management'
                    when 'sw_mgr_entitled' then 'Update'
                    when 'provisioning_entitled' then 'Provisioning'
                    when 'monitoring_entitled' then 'Monitoring'  end  );

				rhn_server.delete_from_servergroup(
						sgm.server_id, sgm.server_group_id);
			end loop;
			update rhnServerGroup set group_type = null
				where org_id = our_org_id;
			delete from rhnServerGroup where org_id = our_org_id;
			for s in servers_for_deletion(our_org_id) loop
				delete_server(s.id);
			end loop;
			begin
				delete from rhn_check_suites where customer_id = our_org_id;
				delete from rhn_command_target where customer_id = our_org_id;
				delete from rhn_contact_groups where customer_id = our_org_id;
				delete from rhn_notification_formats
					where customer_id = our_org_id;
				delete from rhn_probe where customer_id = our_org_id;
				delete from rhn_redirects where customer_id = our_org_id;
				delete from rhn_sat_cluster where customer_id = our_org_id;
				delete from rhn_schedules where customer_id = our_org_id;
				delete from web_contact where id = user_id_in;
				delete from web_customer where id = our_org_id;
			exception
				when others then
					rhn_exception.raise_exception('cannot_delete_user');
			end;
		end if;
		return;
	end delete_user;
END rhn_org;
/
SHOW ERRORS

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
