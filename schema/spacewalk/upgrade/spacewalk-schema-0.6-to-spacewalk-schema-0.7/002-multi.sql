

ALTER TABLE web_user_personal_info
 ADD (  password  VARCHAR2(38),
        old_password VARCHAR2(38),
        login     VARCHAR2(64),
        login_uc           VARCHAR2(64));



update web_user_personal_info pinfo
  set (password, old_password, login, login_uc)  = ( select password, old_password, login, login_uc 
        from web_contact WC where pinfo.web_user_id = WC.id);

alter table web_user_personal_info 
   modify ( password  VARCHAR2(38) NOT NULL,
            login     VARCHAR2(64) NOT NULL,
            login_uc           VARCHAR2(64) NOT NULL  CONSTRAINT web_personal_login_uc_unq UNIQUE);

 alter table web_contact drop column password;
 alter table web_contact drop column login;
 alter table web_contact drop column login_uc;
 alter table web_contact drop column old_password;


create or replace trigger
web_contact_mod_trig
before insert or update on web_contact
for each row
begin
        :new.modified := sysdate;
end
/

create or replace trigger
web_user_pi_timestamp
BEFORE INSERT OR UPDATE ON web_user_personal_info
FOR EACH ROW
BEGIN
  :new.modified := sysdate;
  :new.login_uc := UPPER(:new.login);
  IF :new.password <> :old.password THEN
         :new.old_password := :old.password;
  END IF;
END;
/

CREATE SEQUENCE web_user_personal_id_seq;

alter table web_user_personal_info add id number;
update web_user_personal_info set id = web_user_personal_id_seq.nextval;
alter table web_user_personal_info modify id number not null CONSTRAINT web_user_personal_pk PRIMARY KEY;



 alter table web_contact add  personal_info_id number; 
 update web_contact wc set personal_info_id = ( select pinfo.id from web_user_personal_info pinfo where pinfo.web_user_id = wc.id);
 alter table web_contact modify personal_info_id number NOT NULL CONSTRAINT web_contact_personal_id_fk
                               REFERENCES web_user_personal_info (id);
 alter table web_user_personal_info drop column web_user_id;

 alter table web_user_personal_info add default_org number;
 update web_user_personal_info pinfo set default_org = ( select org_id from web_contact wc where wc.personal_info_id = pinfo.id);
 alter table web_user_personal_info modify default_org number NOT NULL CONSTRAINT web_user_per_info_def_org_fk REFERENCES web_customer (id);



create or replace view rhnUsersInOrgOverview as
select    
        u.org_id                                        as org_id,
        u.id                                            as user_id,
        pi.login                                         as user_login,
        pi.first_names                                  as user_first_name,
        pi.last_name                                    as user_last_name,
        u.modified                                      as user_modified,
        (       select  count(server_id)
                from    rhnUserServerPerms sp
                where   sp.user_id = u.id)
                                                        as server_count,
        (       select  count(server_group_id)
                from    rhnUserManagedServerGroups umsg
                where   umsg.user_id = u.id and exists (
                        select  1
                        from    rhnVisibleServerGroup sg
                        where   sg.id = umsg.server_group_id))
                                                        as server_group_count,
        (       select  coalesce(utcv.names, '(normal user)')
                from    rhnUserTypeCommaView utcv
                where   utcv.user_id = u.id)
                                                        as role_names
from    web_user_personal_info pi, 
        web_contact u 
where
        u.personal_info_id = pi.id;




create or replace view
rhnWebContactDisabled
as
select
   wcon.id,
   wcon.org_id,
   pi.login,
   pi.login_uc,
   pi.password,
   pi.old_password,
   wcon.oracle_contact_id,
   wcon.created,
   wcon.modified,
   wcon.ignore_flag
from
   rhnWebContactChangeLog   wccl,
   rhnWebContactChangeState wccs,
   web_contact              wcon,
   web_user_personal_info   pi
where wccl.change_state_id = wccs.id
   and wccs.label = 'disabled'
   and wccl.web_contact_id = wcon.id
   and wcon.personal_info_id = pi.id
   and wccl.date_completed =
              (select max(wccl_exists.date_completed)
                 from rhnWebContactChangeLog   wccl_exists
                where wccl.web_contact_id = wccl_exists.web_contact_id);


create or replace view
rhnWebContactEnabled
as
select
   wcon.id,
   wcon.org_id,
   pinfo.login,
   pinfo.login_uc,
   pinfo.password,
   pinfo.old_password,
   wcon.oracle_contact_id,
   wcon.created,
   wcon.modified,
   wcon.ignore_flag
from
   web_contact wcon inner join 
   web_user_personal_info PINFO on PINFO.id = wcon.personal_info_id
minus
select
   wcd.id,
   wcd.org_id,
   wcd.login,
   wcd.login_uc,
   wcd.password,
   wcd.old_password,
   wcd.oracle_contact_id,
   wcd.created,
   wcd.modified,
   wcd.ignore_flag
from
   rhnWebContactDisabled wcd;



CREATE OR REPLACE VIEW
rhnActionOverview
(
        org_id,
        action_id,
        type_id,
        type_name,
        name,
        scheduler,
        scheduler_login,
        earliest_action,
        total_count,
        successful_count,
        failed_count,
        in_progress_count,
        archived
)
AS
SELECT    A.org_id,
          A.id,
          AT.id,
          AT.name,
          A.name,
          A.scheduler,
          pinfo.login,
          A.earliest_action,
          (SELECT COUNT(*) FROM rhnServerAction WHERE action_id = A.id),
          (SELECT COUNT(*) FROM rhnServerAction WHERE action_id = A.id AND status = 2), -- XXX: don''t hard code status here :)
          (SELECT COUNT(*) FROM rhnServerAction WHERE action_id = A.id AND status = 3),
          (SELECT COUNT(*) FROM rhnServerAction WHERE action_id = A.id AND status NOT IN (2, 3)),
          A.archived
FROM
          rhnActionType AT,
          rhnAction A
                left outer join
          web_contact U
                on A.scheduler = U.id left outer join
          web_user_personal_info pinfo on  U.personal_info_id = pinfo.id
WHERE A.action_type = AT.id
ORDER BY  A.earliest_action;





create or replace
package body rhn_user
is
	body_version varchar2(100) := '';
	
    function check_role(user_id_in in number, role_in in varchar2)
    return number
    is
    	throwaway number;
    begin
    	-- the idea: if we get past this query, the org has the setting, else catch the exception and return 0
	select 1 into throwaway
	  from rhnUserGroupType UGT,
	       rhnUserGroup UG,
	       rhnUserGroupMembers UGM
	 where UGM.user_id = user_id_in
	   and UGM.user_group_id = UG.id
	   and UG.group_type = UGT.id
	   and UGT.label = role_in;
	   
	return 1;
    exception
    	when no_data_found
	    then
	    return 0;
    end check_role;
    
    function check_role_implied(user_id_in in number, role_in in varchar2)
    return number
    is
    	throwaway number;
    begin
    	-- if the user directly has the role, they win
    	if rhn_user.check_role(user_id_in, role_in) = 1
	then
	    return 1;
    	end if;

	-- config_admin and channel_admin are automatically implied for org admins	
	if role_in = 'config_admin' and rhn_user.check_role(user_id_in, 'org_admin') = 1
	then
	    return 1;
	end if;

	if role_in = 'channel_admin' and rhn_user.check_role(user_id_in, 'org_admin') = 1
	then
	    return 1;
	end if;

	return 0;	
    end check_role_implied;
    
    function get_org_id(user_id_in in number)
    return number
    is
    	org_id_out number;
    begin
    	select org_id into org_id_out
	  from web_contact
	 where id = user_id_in;
	 
	return org_id_out;
    end get_org_id;

	-- paid users often don't have verified email addresses, so
	-- try to find an address that is useful to us.
	function find_mailable_address(user_id_in in number)
	return varchar2 is
		PRAGMA AUTONOMOUS_TRANSACTION;
		-- this would be so much prettier if we just had an order built
		-- into rhnEmailAddressState
		cursor addrs is
			select	ea.state_id, ea.address
			from	rhnEmailAddressState eas,
					rhnEmailAddress ea
			where	ea.user_id = user_id_in
				and eas.label = 'verified'
				and ea.state_id = eas.id
			union all
			select	ea.state_id, ea.address
			from	rhnEmailAddressState eas,
					rhnEmailAddress ea
			where	ea.user_id = user_id_in
				and eas.label = 'unverified'
				and ea.state_id = eas.id
			union all
			select	ea.state_id, ea.address
			from	rhnEmailAddressState eas,
					rhnEmailAddress ea
			where	ea.user_id = user_id_in
				and eas.label = 'pending'
				and ea.state_id = eas.id
			union all
			select	ea.state_id, ea.address
			from	rhnEmailAddressState eas,
					rhnEmailAddress ea
			where	ea.user_id = user_id_in
				and eas.label = 'pending_warned'
				and ea.state_id = eas.id
			union all
			select	ea.state_id, ea.address
			from	rhnEmailAddressState eas,
					rhnEmailAddress ea
			where	ea.user_id = user_id_in
				and eas.label = 'needs_verifying'
				and ea.state_id = eas.id
			union all
			select	-1 state_id,
					email address
			from	web_user_personal_info pi inner join 
                    web_contact wc on wc.personal_info_id = pi.id
			where	wc.id = user_id_in;
		retval rhnEmailAddress.address%TYPE;
	begin
		for addr in addrs loop
			retval := addr.address;
			if addr.address is null then
				update web_user_contact_permission
					set email = 'N'
					where web_user_id = user_id_in;
				commit;
				return null;
			end if;
			if addr.state_id = -1 then
				insert into rhnEmailAddress (
						id, address,
						user_id, state_id
					) (
						select	rhn_eaddress_id_seq.nextval, addr.address,
								user_id_in, eas.id
						from	rhnEmailAddressState eas
						where	eas.label = 'unverified'
					);
			end if;
			commit;
			return retval;
		end loop;
		return null;
	end;

	procedure add_servergroup_perm(
		user_id_in in number,
		server_group_id_in in number
	) is
		cursor	orgs_match is
			select	1
			from	rhnServerGroup sg,
					web_contact u
			where	u.id = user_id_in
				and sg.id = server_group_id_in
				and sg.org_id = u.org_id;
	begin
		for okay in orgs_match loop
			insert into rhnUserServerGroupPerms(user_id, server_group_id)
				values (user_id_in, server_group_id_in);
			rhn_cache.update_perms_for_user(user_id_in);
			return;
		end loop;
		rhn_exception.raise_exception('usgp_different_orgs');
	exception when dup_val_on_index then
		rhn_exception.raise_exception('usgp_already_allowed');
	end add_servergroup_perm;

	procedure remove_servergroup_perm(
		user_id_in in number,
		server_group_id_in in number
	) is
		cursor perms is
			select	1
			from	rhnUserServerGroupPerms
			where	user_id = user_id_in
				and server_group_id = server_group_id_in;
	begin
		for perm in perms loop
			delete from rhnUserServerGroupPerms
				where	user_id = user_id_in
					and server_group_id = server_group_id_in;
			rhn_cache.update_perms_for_user(user_id_in);
			return;
		end loop;
		rhn_exception.raise_exception('usgp_not_allowed');
	end remove_servergroup_perm;

	procedure add_to_usergroup(
		user_id_in in number,
		user_group_id_in in number
	) is
		cursor perm_granting_usergroups is
			select	user_group_id_in
			from	rhnUserGroup		ug,
					rhnUserGroupType	ugt
			where	ugt.label in ('org_admin') -- and server_group_admin ?
				and ug.id = user_group_id_in
				and ug.group_type = ugt.id;
	begin
		insert into rhnUserGroupMembers(user_id, user_group_id)
			values (user_id_in, user_group_id_in);

		for ug in perm_granting_usergroups loop
			rhn_cache.update_perms_for_user(user_id_in);
			return;
		end loop;
	end add_to_usergroup;

	procedure add_users_to_usergroups(
		user_id_in in number
	) is
		cursor ugms is
			select	element user_id,
					element_two user_group_id
			from	rhnSet
			where	user_id = user_id_in
				and label = 'user_group_list';
	begin
		for ugm in ugms loop
			rhn_user.add_to_usergroup(ugm.user_id, ugm.user_group_id);
		end loop;
	end add_users_to_usergroups;

	procedure remove_from_usergroup(
		user_id_in in number,
		user_group_id_in in number
	) is
		cursor perm_granting_usergroups is
			select	label
			from	rhnUserGroupType	ugt,
					rhnUserGroupMembers	ugm,
					rhnUserGroup		ug
			where	1=1
				and ug.id = user_group_id_in
				and ugm.user_group_id = user_group_id_in
				and ug.group_type = ugt.id
				and ugm.user_id = user_id_in;
	begin
		-- we only do anything if you're really in the group, because
		-- testing is significantly cheaper than rebuilding the user's
		-- cache for no reason.
		for ug in perm_granting_usergroups loop
			delete from rhnUserGroupMembers
				where	user_id = user_id_in
					and user_group_id = user_group_id_in;
			if ug.label in ('org_admin') then
				rhn_cache.update_perms_for_user(user_id_in);
			end if;
		end loop;
	end remove_from_usergroup;

	procedure remove_users_from_servergroups(
		user_id_in in number
	) is
		cursor ugms is
			select	element user_id,
					element_two user_group_id
			from	rhnSet
			where	user_id = user_id_in
				and label = 'user_group_list';
	begin
		for ugm in ugms loop
			rhn_user.remove_from_usergroup(ugm.user_id, ugm.user_group_id);
		end loop;
	end remove_users_from_servergroups;
end rhn_user;
/
SHOW ERRORS
