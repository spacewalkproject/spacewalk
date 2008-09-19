--
-- $Id: create_new_org.sql 118829 2007-08-03 00:04:50Z mmccune $
--
--

create or replace procedure
create_new_org
(
	name_in      in varchar2,
	password_in  in varchar2,
	org_id_out   out number
) is
	ug_type			number;
	group_val		number;
	new_org_id              number;
begin
    
        select web_customer_id_seq.nextval into new_org_id from dual;

	insert into web_customer (
		id, name, password,
		oracle_customer_id, oracle_customer_number,
		customer_type
	) values (
		new_org_id, name_in, password_in,
		new_org_id, new_org_id, 'B'
	);

	select rhn_user_group_id_seq.nextval into group_val from dual;

	select	id
	into	ug_type
	from	rhnUserGroupType
	where	label = 'org_admin';

	insert into rhnUserGroup (
		id, name,
		description,
		max_members, group_type, org_id
	) values (
		group_val, 'Organization Administrators',
		'Organization Administrators for Org ' || name_in,
		NULL, ug_type, new_org_id
	);

	select rhn_user_group_id_seq.nextval into group_val from dual;

	select	id
	into	ug_type
	from	rhnUserGroupType
	where	label = 'org_applicant';

	insert into rhnUserGroup (
		id, name,
		description,
		max_members, group_type, org_id
	) VALues (
		group_val, 'Organization Applicants',
		'Organization Applicants for Org ' || name_in,
		NULL, ug_type, new_org_id
	);

	select rhn_user_group_id_seq.nextval into group_val from dual;

	select	id
	into	ug_type
	from	rhnUserGroupType
	where	label = 'system_group_admin';

	insert into rhnUserGroup (
		id, name,
		description,
		max_members, group_type, org_id
	) values (
		group_val, 'System Group Administrators',
		'System Group Administrators for Org ' || name_in,
		NULL, ug_type, new_org_id
	);


	select rhn_user_group_id_seq.nextval into group_val from dual;

	select	id
	into	ug_type
	from	rhnUserGroupType
	where	label = 'activation_key_admin';

	insert into rhnUserGroup (
		id, name,
		description,
		max_members, group_type, org_id
	) values (
		group_val, 'Activation Key Administrators',
		'Activation Key Administrators for Org ' || name_in,
		NULL, ug_type, new_org_id
	);

	-- config admin is special; it gets created in
	-- rhn_entitlements.set_customer_provisioning instead.
	
	select rhn_user_group_id_seq.nextval into group_val from dual;

	select	id
	into	ug_type
	from	rhnUserGroupType
	where	label = 'channel_admin';

	insert into rhnUserGroup (
		id, name,
		description,
		max_members, group_type, org_id
	) values (
		group_val, 'Channel Administrators',
		'Channel Administrators for Org ' || name_in,
		NULL, ug_type, new_org_id
	);

	-- there aren't any users yet, so we don't need to update
	-- rhnUserServerPerms
        insert into rhnServerGroup 
		( id, name, description, max_members, group_type, org_id )
		select rhn_server_group_id_seq.nextval, sgt.name, sgt.name, 
			0, sgt.id, new_org_id
		from rhnServerGroupType sgt
		where sgt.label = 'sw_mgr_entitled';
	
	org_id_out := new_org_id;
		
end create_new_org;
/
show errors;



--
-- $Id: create_new_org.sql 118829 2007-08-03 00:04:50Z mmccune $
--
--

create or replace procedure
create_new_org
(
	name_in      in varchar2,
	password_in  in varchar2,
	org_id_out   out number
) is
	ug_type			number;
	group_val		number;
	new_org_id              number;
begin
    
        select web_customer_id_seq.nextval into new_org_id from dual;

	insert into web_customer (
		id, name, password,
		oracle_customer_id, oracle_customer_number,
		customer_type
	) values (
		new_org_id, name_in, password_in,
		new_org_id, new_org_id, 'B'
	);

	select rhn_user_group_id_seq.nextval into group_val from dual;

	select	id
	into	ug_type
	from	rhnUserGroupType
	where	label = 'org_admin';

	insert into rhnUserGroup (
		id, name,
		description,
		max_members, group_type, org_id
	) values (
		group_val, 'Organization Administrators',
		'Organization Administrators for Org ' || name_in,
		NULL, ug_type, new_org_id
	);

	select rhn_user_group_id_seq.nextval into group_val from dual;

	select	id
	into	ug_type
	from	rhnUserGroupType
	where	label = 'org_applicant';

	insert into rhnUserGroup (
		id, name,
		description,
		max_members, group_type, org_id
	) VALues (
		group_val, 'Organization Applicants',
		'Organization Applicants for Org ' || name_in,
		NULL, ug_type, new_org_id
	);

	select rhn_user_group_id_seq.nextval into group_val from dual;

	select	id
	into	ug_type
	from	rhnUserGroupType
	where	label = 'system_group_admin';

	insert into rhnUserGroup (
		id, name,
		description,
		max_members, group_type, org_id
	) values (
		group_val, 'System Group Administrators',
		'System Group Administrators for Org ' || name_in,
		NULL, ug_type, new_org_id
	);


	select rhn_user_group_id_seq.nextval into group_val from dual;

	select	id
	into	ug_type
	from	rhnUserGroupType
	where	label = 'activation_key_admin';

	insert into rhnUserGroup (
		id, name,
		description,
		max_members, group_type, org_id
	) values (
		group_val, 'Activation Key Administrators',
		'Activation Key Administrators for Org ' || name_in,
		NULL, ug_type, new_org_id
	);

	-- config admin is special; it gets created in
	-- rhn_entitlements.set_customer_provisioning instead.
	
	select rhn_user_group_id_seq.nextval into group_val from dual;

	select	id
	into	ug_type
	from	rhnUserGroupType
	where	label = 'channel_admin';

	insert into rhnUserGroup (
		id, name,
		description,
		max_members, group_type, org_id
	) values (
		group_val, 'Channel Administrators',
		'Channel Administrators for Org ' || name_in,
		NULL, ug_type, new_org_id
	);

	-- there aren't any users yet, so we don't need to update
	-- rhnUserServerPerms
        insert into rhnServerGroup 
		( id, name, description, max_members, group_type, org_id )
		select rhn_server_group_id_seq.nextval, sgt.name, sgt.name, 
			0, sgt.id, new_org_id
		from rhnServerGroupType sgt
		where sgt.label = 'sw_mgr_entitled';
	
	org_id_out := new_org_id;
		
end create_new_org;
/
show errors;


drop function xxrh_contact_del_check;

drop function is_satellite;

drop function xxrh_contact_del_check_num;

insert into rhnException
values (-20290,
        'not_enough_entitlements_in_base_org',
        'You do not have enough entitlements in the base org.');

insert into rhnException
values (-20291,
        'cannot_delete_base_org',
        'You cannot delete the base org.');

insert into rhnUserGroupType (id, label, name) values (
 	rhn_usergroup_type_seq.nextval,
	'satellite_admin',
    'Satellite Administrator'
);


--
-- $Id: rhnServerGroup_triggers.sql 119651 2007-08-22 15:36:31Z jslagle $
--

create or replace trigger
rhn_sg_del_trig
before delete on rhnServerGroup
for each row
declare
	cursor snapshots is
		select	snapshot_id id
		from	rhnSnapshotServerGroup
		where	server_group_id = :old.id;
begin
	for snapshot in snapshots loop
		update rhnSnapshot
			set invalid = lookup_snapshot_invalid_reason('sg_removed')
			where id = snapshot.id;
		delete from rhnSnapshotServerGroup
			where snapshot_id = snapshot.id
				and server_group_id = :old.id;
	end loop;
end;
/
show errors

--
-- $Log$
-- Revision 1.12  2003/11/09 18:18:03  pjones
-- bugzilla: 109083 -- triggers for snapshot invalidation on confchan change
-- bugfix in server group snapshot invalidation
--
-- Revision 1.11  2003/11/09 18:13:20  pjones
-- bugzilla: 109083 -- re-enable snapshot invalidation
--
-- Revision 1.10  2003/11/07 18:05:42  pjones
-- bugzilla: 109083
-- kill old config file schema (currently just an exclude except for
--   rhnConfigFile which is replaced)
-- exclude the snapshot stuff, and comment it from triggers and procs
-- more to come, but the basic config file stuff is in.
--
-- Revision 1.9  2003/10/23 19:14:56  pjones
-- bugzilla: 105745
-- remove rhnSnapshotServerGroup after setting the snapshot invalid
--
-- Revision 1.8  2003/10/07 20:49:18  pjones
-- bugzilla: 106188
--
-- snapshot invalidation
--
-- Revision 1.7  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--


drop trigger rhn_ug_del_trig;
 
-- $Log$
-- Revision 1.22  2004/10/29 04:50:49  pjones
-- bugzilla: 135179 -- fix org admin swapping during user deletion
--
-- Revision 1.21  2004/07/13 22:46:04  pjones
-- bugzilla: 125938 -- nothing uses update_errata_cache() any more, remove it
--
-- Revision 1.20  2004/07/02 22:24:38  pjones
-- bugzilla: none -- typo fix
--
-- Revision 1.19  2004/07/02 19:19:02  pjones
-- bugzilla: 125937 -- use rhn_user to grant roles to users
--
-- Revision 1.18  2004/05/28 22:21:36  pjones
-- bugzilla: none -- update for monitoring schema
--
-- Revision 1.17  2004/04/05 16:31:07  pjones
-- bugzilla: 120032 -- raise "cannot_delete_user" if web_contact or web_customer
-- has a cascade problem
--
-- Revision 1.16  2004/03/15 17:10:28  pjones
-- bugzilla: 118244 -- delete servers explicitly while deleting lone users
--
-- Revision 1.15  2004/02/09 17:14:54  pjones
-- bugzilla: none -- fix log garbage
--
-- Revision 1.14  2004/01/22 19:44:42  pjones
-- bugzilla: 106562 -- fix exceptions on delete_user()
--
-- Revision 1.13  2004/01/20 17:00:48  pjones
-- bugzilla: none -- try to make delete_user() succeed when there are
-- server groups that have been snapshotted
--
-- Revision 1.12  2004/01/14 20:22:03  pjones
-- bugzilla: 113344 -- no deleting from rhnServerGroup, use the api instead
--
-- Revision 1.11  2003/03/20 17:08:16  pjones
-- avoid the server group members trigger that updates last_modified; it'll
-- cause a mutating table error
--
-- Revision 1.10  2003/03/17 16:31:25  pjones
-- use "on delete set null" where applicable
--
-- Revision 1.9  2003/03/15 00:31:07  pjones
-- bugzilla: none
--
-- tested wrong table for perms on a server group
--
-- Revision 1.8  2003/03/15 00:23:36  pjones
-- bugzilla: 83631
--
-- working delete_user
--
-- Revision 1.7  2003/03/03 23:39:36  pjones
-- different delete_user; this one might actually work.
--
-- Takes about 18 seconds, which seems kindof slow, but isn't
-- intolerable I don't think...
--
-- Revision 1.6  2003/03/02 18:07:00  pjones
-- make it use marty's test instead of is_satellite(); in the sat env,
-- marty's test _is_ is_satellite()
--
-- Revision 1.5  2003/02/18 16:35:45  pjones
-- delete_user
--
-- Revision 1.4  2002/05/10 22:08:23  pjones
-- id/log
--

create or replace
package rhn_entitlements
is
	body_version varchar2(100) := '$Id: rhn_entitlements.pks 119213 2007-08-15 18:06:11Z jslagle $';

   type ents_array is varray(10) of rhnServerGroupType.label%TYPE;

    procedure remove_org_entitlements (
        org_id_in number
    );

    function entitlement_grants_service (
	    entitlement_in in varchar2,
		service_level_in in varchar2
	) return number;

	function lookup_entitlement_group (
		org_id_in in number,
		type_label_in in varchar2 := 'sw_mgr_entitled'
	) return number;

	function create_entitlement_group (
		org_id_in in number,
		type_label_in in varchar2 := 'sw_mgr_entitled'
	) return number;

   function can_entitle_server ( 
      server_id_in   in number, 
      type_label_in  in varchar2
   )
   return number;

   function can_switch_base ( 
      server_id_in   in    integer, 
      type_label_in  in    varchar2
   )
   return number;

   function find_compatible_sg (
      server_id_in in number,
      type_label_in in varchar2,
      sgid_out out number
   )
   return boolean;

	procedure entitle_server (
		server_id_in in number,
		type_label_in in varchar2 := 'sw_mgr_entitled'
	);

	procedure remove_server_entitlement (
		server_id_in in number,
		type_label_in in varchar2 := 'sw_mgr_entitled',
        repoll_virt_guests in number := 1
	);

	procedure unentitle_server (
		server_id_in in number
	);

    procedure repoll_virt_guest_entitlements(
        server_id_in in number
    );

	function get_server_entitlement (
		server_id_in in number
	) return ents_array;

	procedure modify_org_service (
		org_id_in in number,
		service_label_in in varchar2,
		enable_in in char
	);

    procedure set_customer_enterprise (
		customer_id_in in number
	);

	procedure set_customer_provisioning (
		customer_id_in in number
	);

	procedure set_customer_nonlinux (
		customer_id_in in number
	);

    procedure unset_customer_enterprise (
		customer_id_in in number
	);

	procedure unset_customer_provisioning (
		customer_id_in in number
	);

	procedure unset_customer_nonlinux (
		customer_id_in in number
	);

    procedure assign_system_entitlement(
        group_label_in in varchar2,
        from_org_id_in in number,
        to_org_id_in in number,
        quantity_in in number
    );

    procedure assign_channel_entitlement(
        channel_family_label_in in varchar2,
        from_org_id_in in number,
        to_org_id_in in number,
        quantity_in in number
    );

    procedure activate_system_entitlement(
        org_id_in in number,
        group_label_in in varchar2,
        quantity_in in number
    );

    procedure activate_channel_entitlement(
        org_id_in in number,
        channel_family_label_in in varchar2,
        quantity_in in number
    );

    procedure set_group_count (
		customer_id_in in number,	-- customer_id
		type_in in char,			-- 'U' or 'S'
		group_type_in in number,	-- rhn[User|Server]GroupType.id
		quantity_in in number		-- quantity
    );

    procedure set_family_count (
		customer_id_in in number,		-- customer_id
		channel_family_id_in in number,	-- 246
		quantity_in in number			-- 3
    );

    -- this makes NO checks that the quantity is within max,
    -- so we should NEVER run this unless we KNOW that we won't be
    -- violating the max
    procedure entitle_last_modified_servers (
		customer_id_in in number,	-- customer_id
		type_label_in in varchar2,	-- 'enterprise_entitled'
		quantity_in in number		-- 3
    );

	procedure prune_everything (
		customer_id_in in number
	);

	procedure subscribe_newest_servers (
		customer_id_in in number
	);
end rhn_entitlements;
/
show errors

-- $Log$
-- Revision 1.19  2004/05/26 19:45:48  pjones
-- bugzilla: 123639
-- 1) reformat "entitlement_grants_service"
-- 2) make the .pks and .pkb be in the same order.
-- 3) add "modify_org_service" (to be used instead of set_customer_SERVICELEVEL)
-- 4) add monitoring specific data.
--
-- Revision 1.18  2004/02/19 20:17:49  pjones
-- bugzilla: 115896 -- add sgt and oet data for nonlinux, add
-- [un]set_customer_nonlinux
--
-- Revision 1.17  2004/01/13 23:37:08  pjones
-- bugzilla: none -- mate provisioning and management slots.
--
-- Revision 1.16  2003/09/23 22:14:41  bretm
-- bugzilla:  103655
--
-- need something in the db that knows provisioning boxes are management boxes too, etc.
--
-- Revision 1.15  2003/09/19 22:35:07  pjones
-- bugzilla: none
--
-- provisioning and config management entitlement support
--
-- Revision 1.14  2003/09/02 22:22:54  pjones
-- bugzilla: none
--
-- attempt to autoentitle upon entitlement changes
--
-- Revision 1.13  2003/06/05 21:43:40  pjones
-- bugzilla: none
--
-- add rhn_entitlements.prune_everything(customer_id_in in number);
--
-- Revision 1.12  2003/05/22 16:01:14  pjones
-- reformat
-- remove update_[server|user]group_counts (unused)
--
-- Revision 1.11  2002/06/03 16:07:29  pjones
-- make prune_group and prune_family update respective max_members
-- correctly.
--
-- Revision 1.10  2002/05/29 19:10:31  pjones
-- code to entitle the last N modified servers to a particular service
-- level
--
-- Revision 1.9  2002/05/10 22:08:23  pjones
-- id/log
--


--
-- $Id: rhn_entitlements.pkb 119705 2007-08-22 17:43:55Z jslagle $
--

create or replace
package body rhn_entitlements
is
	body_version varchar2(100) := '$Id: rhn_entitlements.pkb 119705 2007-08-22 17:43:55Z jslagle $';


    -- *******************************************************************
    -- PROCEDURE: remove_org_entitlements
    --
    -- Removes both system entitlements and channel subscriptions
    -- that are currently assigned to an org and re-assigns to the
    -- master org (org_id = 1).
    --
    -- When we call this we expect everything to already be unentitled
    -- which shoul be handled by delete_org.
    --
    -- Called by: delete_org
    -- *******************************************************************
    procedure remove_org_entitlements(
        org_id_in in number
    )
    is

        cursor system_ents is
        select sg.id, sg.max_members, sg.group_type
        from rhnServerGroup sg
        where group_type is not null
          and org_id = org_id_in;

        cursor channel_subs is
        select pcf.channel_family_id, pcf.max_members
        from rhnChannelFamily cf,
             rhnPrivateChannelFamily pcf
        where pcf.org_id = org_id_in
          and pcf.channel_family_id = cf.id
          and cf.org_id is null;

    begin

        for system_ent in system_ents loop
            update rhnServerGroup
            set max_members = max_members + system_ent.max_members
            where org_id = 1
              and group_type = system_ent.group_type;
        end loop;

        update rhnServerGroup
        set max_members = 0
        where org_id = org_id_in;

        for channel_sub in channel_subs loop
            update rhnPrivateChannelFamily
            set max_members = max_members + channel_sub.max_members
            where org_id = 1
              and channel_family_id = channel_sub.channel_family_id;
        end loop;
        
        update rhnPrivateChannelFamily
        set max_members = 0
        where org_id = org_id_in;

    end remove_org_entitlements;
 
	function entitlement_grants_service (
	    entitlement_in in varchar2,
	    service_level_in in varchar2
	) return number	is
	begin
		if service_level_in = 'provisioning' then
			if entitlement_in = 'provisioning_entitled' then
				return 1;
			else
				return 0;
			end if;
		elsif service_level_in = 'management' then
			if entitlement_in = 'enterprise_entitled' then
				return 1;
			else
				return 0;
			end if;
		elsif service_level_in = 'monitoring' then
			if entitlement_in = 'monitoring_entitled' then
				return 1;
			end if;
		elsif service_level_in = 'updates' then
			return 1;			
		else
			return 0;
		end if;
	end entitlement_grants_service;

	function lookup_entitlement_group (
		org_id_in in number,
		type_label_in in varchar2 := 'sw_mgr_entitled'
	) return number is
		cursor server_groups is
			select	sg.id				server_group_id
			from	rhnServerGroup		sg,
					rhnServerGroupType	sgt
			where	sgt.label = type_label_in
				and sgt.id = sg.group_type
				and sg.org_id = org_id_in;
	begin
		for sg in server_groups loop
			return sg.server_group_id;
		end loop;
		return rhn_entitlements.create_entitlement_group(
				org_id_in, 
				type_label_in
			);
	end lookup_entitlement_group;

	function create_entitlement_group (
		org_id_in in number,
		type_label_in in varchar2 := 'sw_mgr_entitled'
	) return number is
		sg_id_val number;
	begin
		select	rhn_server_group_id_seq.nextval
		into	sg_id_val
		from	dual;

		insert into rhnServerGroup (
				id, name, description, max_members, current_members,
				group_type, org_id
			) (
				select	sg_id_val, sgt.label, sgt.label,
						0, 0, sgt.id, org_id_in
				from	rhnServerGroupType sgt
				where	sgt.label = type_label_in
			);

		return sg_id_val;
	end create_entitlement_group;

   function can_entitle_server ( 
        server_id_in in number, 
        type_label_in in varchar2 ) 
   return number is
      cursor addon_servergroups (base_label_in in varchar2, 
                                 addon_label_in in varchar2) is
         select
            addon_id
         from
            rhnSGTypeBaseAddonCompat
         where base_id = lookup_sg_type (base_label_in)
           and addon_id = lookup_sg_type (addon_label_in);

      previous_ent        rhn_entitlements.ents_array;
      is_base_in          char   := 'N';
      is_base_current     char   := 'N';
      i                   number := 0;
      sgid                number := 0;

   begin

      previous_ent := rhn_entitlements.ents_array();
      previous_ent := rhn_entitlements.get_server_entitlement(server_id_in);

      select distinct is_base
      into is_base_in
      from rhnServerGroupType
      where label = type_label_in;

      if previous_ent.count = 0 then
         if (is_base_in = 'Y' and rhn_entitlements.find_compatible_sg (server_id_in, type_label_in, sgid)) then
            -- rhn_server.insert_into_servergroup (server_id_in, sgid);
            return 1;
         else
            -- rhn_exception.raise_exception ('invalid_base_entitlement');
            return 0;
         end if;

      -- there are previous ents, first make sure we're not trying to entitle a base ent
      elsif is_base_in = 'Y' then
         -- rhn_exception.raise_exception ('invalid_addon_entitlement');
         return 0;

      -- it must be an addon, so proceed with the entitlement
      else

         -- find the servers base ent
         is_base_current := 'N';
         i := 0;
         while is_base_current = 'N' and i <= previous_ent.count
         loop
            i := i + 1;
            select is_base
            into is_base_current
            from rhnServerGroupType
            where label = previous_ent(i);
         end loop;

         -- never found a base ent, that would be strange
         if is_base_current  = 'N' then
            -- rhn_exception.raise_exception ('invalid_base_entitlement');
            return 0;
         end if;

         -- this for loop verifies the validity of the addon path
         for addon_servergroup in addon_servergroups  (previous_ent(i), type_label_in) loop
            -- find an appropriate sgid for the addon and entitle the server
            if rhn_entitlements.find_compatible_sg (server_id_in, type_label_in, sgid) then
               -- rhn_server.insert_into_servergroup (server_id_in, sgid);
               return 1;
            else
               -- rhn_exception.raise_exception ('invalid_addon_entitlement');
               return 0;
            end if;
         end loop;

      end if;

      return 0;

   end can_entitle_server;

   function can_switch_base (
      server_id_in   in    integer,
      type_label_in  in    varchar2
   ) return number is

      type_label_in_is_base   char(1);
      sgid                    number;

   begin

      begin
         select is_base into type_label_in_is_base
         from rhnServerGroupType
         where label = type_label_in;
      exception
         when no_data_found then
            rhn_exception.raise_exception ( 'invalid_entitlement' );
      end;

      if type_label_in_is_base = 'N' then
         rhn_exception.raise_exception ( 'invalid_entitlement' );
      elsif rhn_entitlements.find_compatible_sg ( server_id_in, 
                                                  type_label_in, sgid ) then
         return 1;
      else
         return 0;
      end if;

   end can_switch_base;


   function find_compatible_sg (
      server_id_in    in   number,
      type_label_in   in   varchar2,
      sgid_out        out  number
   ) return boolean is

      cursor servergroups is
         select sg.id            id
           from rhnServerGroupType             sgt,
                rhnServerGroup                 sg,
                rhnServer                     s,
                rhnServerServerGroupArchCompat ssgac
          where s.id = server_id_in
            and s.org_id = sg.org_id
            and sgt.label = type_label_in
            and sg.group_type = sgt.id
            and ssgac.server_group_type = sgt.id
            and ssgac.server_arch_id = s.server_arch_id
            and not exists ( 
                     select 1
                      from rhnServerGroupMembers sgm
                     where sgm.server_group_id = sg.id 
                       and sgm.server_id = s.id);

         
   begin
      for servergroup in servergroups loop
         sgid_out := servergroup.id;
         return true;      
      end loop;

      --no servergroup found
      sgid_out := 0;
      return false;
   end find_compatible_sg;

	procedure entitle_server (
		server_id_in in number,
		type_label_in in varchar2 := 'sw_mgr_entitled'
	) is
      sgid  number := 0;
      is_virt number := 0;

	begin

          begin
          select 1 into is_virt
            from rhnServerEntitlementView
           where server_id = server_id_in
             and label in ('virtualization_host', 'virtualization_host_platform');
	  exception
            when no_data_found then
              is_virt := 0;
          end;
      
      if is_virt = 0 and (type_label_in = 'virtualization_host' or
                          type_label_in = 'virtualization_host_platform') then

        is_virt := 1;
      end if;



      if rhn_entitlements.can_entitle_server(server_id_in, 
                                             type_label_in) = 1 then
         if rhn_entitlements.find_compatible_sg (server_id_in, 
                                                 type_label_in, sgid) then
            insert into rhnServerHistory ( id, server_id, summary, details )
            values ( rhn_event_id_seq.nextval, server_id_in,
                     'added system entitlement ',
                      case type_label_in
                       when 'enterprise_entitled' then 'Management'
                       when 'sw_mgr_entitled' then 'Update'
                       when 'provisioning_entitled' then 'Provisioning'
                       when 'monitoring_entitled' then 'Monitoring'  
                       when 'virtualization_host' then 'Virtualization'
                       when 'virtualization_host_platform' then 
                            'Virtualization Platform' end  );

            rhn_server.insert_into_servergroup (server_id_in, sgid);

            if is_virt = 1 then
              rhn_entitlements.repoll_virt_guest_entitlements(server_id_in);
            end if;

         else
            rhn_exception.raise_exception ('no_available_server_group');
         end if;
      else
         rhn_exception.raise_exception ('invalid_entitlement');
      end if;
   end entitle_server;

	procedure remove_server_entitlement (
		server_id_in in number,
		type_label_in in varchar2 := 'sw_mgr_entitled',
        repoll_virt_guests in number := 1
	) is
		group_id number;
      type_is_base char;
      is_virt number := 0;
	begin
      begin


      -- would be nice if there were a virt attribute of entitlement types, not have to specify 2 different ones...
        begin
          select 1 into is_virt
            from rhnServerEntitlementView
           where server_id = server_id_in
             and label in ('virtualization_host', 'virtualization_host_platform');
        exception
          when no_data_found then
            is_virt := 0;
        end;

		select	sg.id, sgt.is_base
  		into	group_id, type_is_base
  		from	rhnServerGroupType sgt,
   			rhnServerGroup sg,
  				rhnServerGroupMembers sgm,
  				rhnServer s
  		where	s.id = server_id_in
  			and s.id = sgm.server_id
  			and sgm.server_group_id = sg.id
  			and sg.org_id = s.org_id
  			and sgt.label = type_label_in
  			and sgt.id = sg.group_type;

      if ( type_is_base = 'Y' ) then
         -- unentitle_server should handle everything, don't really need to do anything else special here
         unentitle_server ( server_id_in );
      else

         insert into rhnServerHistory ( id, server_id, summary, details )
         values ( rhn_event_id_seq.nextval, server_id_in,
                  'removed system entitlement ',
                   case type_label_in
                    when 'enterprise_entitled' then 'Management'
                    when 'sw_mgr_entitled' then 'Update'
                    when 'provisioning_entitled' then 'Provisioning'
                    when 'monitoring_entitled' then 'Monitoring'
                    when 'virtualization_host' then 'Virtualization'
                    when 'virtualization_host_platform' then 
                         'Virtualization Platforrm' end  );

         rhn_server.delete_from_servergroup(server_id_in, group_id);

         -- special case: clean up related monitornig data
         if type_label_in = 'monitoring_entitled' then
           DELETE
             FROM state_change
            WHERE o_id IN (SELECT probe_id
                             FROM rhn_check_probe
                            WHERE host_id = server_id_in);
           DELETE
             FROM time_series
            WHERE SUBSTR(o_id, INSTR(o_id, '-') + 1, 
                        (INSTR(o_id, '-', INSTR(o_id, '-') + 1) - INSTR(o_id, '-')) - 1)
              IN (SELECT probe_id
                    FROM rhn_check_probe
                   WHERE host_id = server_id_in);
           DELETE
             FROM rhn_probe
            WHERE recid IN (SELECT probe_id
                              FROM rhn_check_probe
                             WHERE host_id = server_id_in);
         end if;

         if is_virt = 1 and repoll_virt_guests = 1 then
           rhn_entitlements.repoll_virt_guest_entitlements(server_id_in);
         end if;
      end if;

  		exception
  		when no_data_found then
  				rhn_exception.raise_exception('invalid_server_group_member');	
      end;

 	end remove_server_entitlement;


   procedure unentitle_server (server_id_in in number) is

      cursor servergroups is
         select distinct sgt.label, sg.id server_group_id
         from  rhnServerGroupType sgt,
               rhnServerGroup sg,
               rhnServer s,
               rhnServerGroupMembers sgm
         where s.id = server_id_in
            and s.org_id = sg.org_id
            and sg.group_type = sgt.id
            and sgm.server_group_id = sg.id
            and sgm.server_id = s.id;
            
     is_virt number := 0;

   begin

      begin
        select 1 into is_virt
          from rhnServerEntitlementView
         where server_id = server_id_in
           and label in ('virtualization_host', 'virtualization_host_platform');
      exception
        when no_data_found then
          is_virt := 0;
      end;

      for servergroup in servergroups loop

         insert into rhnServerHistory ( id, server_id, summary, details )
         values ( rhn_event_id_seq.nextval, server_id_in,
                  'removed system entitlement ',
                   case servergroup.label
                    when 'enterprise_entitled' then 'Management'
                    when 'sw_mgr_entitled' then 'Update'
                    when 'provisioning_entitled' then 'Provisioning'
                    when 'monitoring_entitled' then 'Monitoring'
                    when 'virtualization_host' then 'Virtualization'
                    when 'virtualization_host_platform' then 
                         'Virtualization Platform' end  );
  
         rhn_server.delete_from_servergroup(server_id_in, 
                                            servergroup.server_group_id );
      end loop;

      if is_virt = 1 then
        rhn_entitlements.repoll_virt_guest_entitlements(server_id_in);
      end if;

   end unentitle_server;


    -- *******************************************************************
    -- PROCEDURE: repoll_virt_guest_entitlements
    --
    --   Whenever we add/remove a virtualization_host* entitlement from 
    --   a host, we can call this procedure to update what type of slots
    --   the guests are consuming.  
    -- 
    --   If you're removing the entitlement, it's 
    --   possible the guests will become unentitled if you don't have enough
    --   physical slots to cover them.
    --
    --   If you're adding the entitlement, you end up freeing up physical
    --   slots for other systems.
    --
    -- *******************************************************************
    procedure repoll_virt_guest_entitlements(server_id_in in number)
    is

        -- All channel families associated with the guests of server_id_in
        cursor families is 
            select distinct cfs.channel_family_id
            from
                rhnChannelFamilyServers cfs,
                rhnVirtualInstance vi
            where
                vi.host_system_id = server_id_in
                and vi.virtual_system_id = cfs.server_id;
        
        -- All of server group types associated with the guests of
        -- server_id_in
        cursor group_types is
            select distinct sg.group_type, sgt.label
            from
                rhnServerGroupType sgt,
                rhnServerGroup sg,
                rhnServerGroupMembers sgm,
                rhnVirtualInstance vi
            where
                vi.host_system_id = server_id_in
                and vi.virtual_system_id = sgm.server_id
                and sgm.server_group_id = sg.id
                and sg.group_type = sgt.id;

        -- Virtual servers from a certain family belonging to a speicifc
        -- host that are consuming physical channel slots over the limit.
        cursor virt_servers_cfam(family_id_in in number, quantity_in in number)  is
            select virtual_system_id
            from (
                select rownum, vi.virtual_system_id
                from
                    rhnChannelFamilyMembers cfm,
                    rhnServerChannel sc,
                    rhnVirtualInstance vi
                where
                    vi.host_system_id = server_id_in
                    and vi.virtual_system_id = sc.server_id
                    and sc.channel_id = cfm.channel_id
                    and cfm.channel_family_id = family_id_in
                order by sc.modified desc
                )
            where rownum <= quantity_in;                

        -- Virtual servers from a certain family belonging to a speicifc
        -- host that are consuming physical system slots over the limit.
        cursor virt_servers_sgt(group_type_in in number, quantity_in in number)  is
            select virtual_system_id
            from (
                select rownum, vi.virtual_system_id
                from
                    rhnServerGroup sg,
                    rhnServerGroupMembers sgm,
                    rhnVirtualInstance vi
                where
                    vi.host_system_id = server_id_in
                    and vi.virtual_system_id = sgm.server_id
                    and sgm.server_group_id = sg.id
                    and sg.group_type = group_type_in
                order by sgm.modified desc
                )
            where rownum <= quantity_in;                
        
        org_id_val number;
        max_members_val number;
        current_members_calc number;
        sg_id number;

    begin

        select org_id
        into org_id_val
        from rhnServer
        where id = server_id_in;

        -- deal w/ channel entitlements first ...
        for family in families loop
            -- get the current (physical) members of the family
            current_members_calc := 
                rhn_channel.channel_family_current_members(family.channel_family_id,
                                                           org_id_val); -- fixed transposed args

            -- get the max members of the family
            select max_members
            into max_members_val
            from rhnPrivateChannelFamily
            where channel_family_id = family.channel_family_id
            and org_id = org_id_val;

            if current_members_calc > max_members_val then
                -- A virtualization_host* ent must have been removed, so we'll
                -- unsubscribe guests from the host first.

                -- hm, i don't think max_members - current_members_calc yielding a negative number
                -- will work w/ rownum, swaping 'em in the body of this if...
                for virt_server in virt_servers_cfam(family.channel_family_id,
                                current_members_calc - max_members_val) loop 

                    rhn_channel.unsubscribe_server_from_family(
                                virt_server.virtual_system_id,
                                family.channel_family_id);
                end loop;                               

                -- if we're still over the limit, which would be odd,
                -- just prune the group to max_members
                --
                -- er... wouldn't we actually have to refresh the values of
                -- current_members_calc and max_members_val to actually ever
                -- *skip this??
                if current_members_calc > max_members_val then
                    -- argh, transposed again?!
                    set_family_count(org_id_val,
                                     family.channel_family_id,
                                     max_members_val);
                end if; 

           end if;

            -- update current_members for the family.  This will set the value
            -- to reflect adding/removing the entitlement.
            --
            -- what's the difference of doing this vs the unavoidable set_family_count above?
            rhn_channel.update_family_counts(family.channel_family_id,
                                             org_id_val);
        end loop;

        for a_group_type in group_types loop
          -- get the current *physical* members of the system entitlement type for the org...
          -- 
          -- unlike channel families, it appears the standard rhnServerGroup.max_members represents
          -- *physical* slots, vs physical+virt ... boy that's confusing...

          select max_members, id
            into max_members_val, sg_id
            from rhnServerGroup
            where group_type = a_group_type.group_type
            and org_id = org_id_val;


	  select count(sep.server_id) into current_members_calc
            from rhnServerEntitlementPhysical sep
           where sep.server_group_id = sg_id
             and sep.server_group_type_id = a_group_type.group_type;
          
          if current_members_calc > max_members_val then
            -- A virtualization_host* ent must have been removed, and we're over the limit, so unsubscribe guests
            for virt_server in virt_servers_sgt(a_group_type.group_type,
                                                current_members_calc - max_members_val) loop
              rhn_entitlements.remove_server_entitlement(virt_server.virtual_system_id, a_group_type.label);

              -- decrement current_members_calc, we'll use it to reset current_members for the group at the end...
              current_members_calc := current_members_calc - 1;
            end loop;

          end if;

          update rhnServerGroup set current_members = current_members_calc
           where org_id = org_id_val
             and group_type = a_group_type.group_type;

          -- I think that's all the house-keeping we have to do...
        end loop;

    end repoll_virt_guest_entitlements;


	function get_server_entitlement (
		server_id_in in number
	) return ents_array is

		cursor server_groups is
			select	sgt.label
			from	rhnServerGroupType		sgt,
					rhnServerGroup			sg,
					rhnServerGroupMembers	sgm
			where	1=1
				and sgm.server_id = server_id_in
				and sg.id = sgm.server_group_id
				and sgt.id = sg.group_type
				and sgt.label in (
					'sw_mgr_entitled','enterprise_entitled',
					'provisioning_entitled', 'nonlinux_entitled',
					'monitoring_entitled', 'virtualization_host',
                                        'virtualization_host_platform'
					);

         ent_array ents_array;

	begin
      
      ent_array := ents_array();

		for sg in server_groups loop
         ent_array.extend;
         ent_array(ent_array.count) := sg.label;
		end loop;

		return ent_array;

	end get_server_entitlement;


	-- this desperately needs to be table driven.
	procedure modify_org_service (
		org_id_in in number,
		service_label_in in varchar2,
		enable_in in char
	) is
		type roles_v is varray(10) of rhnUserGroupType.label%TYPE;
		roles_to_process roles_v;
		cursor roles(role_label_in in varchar2) is
			select	label, id
			from	rhnUserGroupType
			where	label = role_label_in;
		cursor org_roles(role_label_in in varchar2) is
			select	1
			from	rhnUserGroup ug,
					rhnUserGroupType ugt
			where	ugt.label = role_label_in
				and ug.org_id = org_id_in
				and ugt.id = ug.group_type;
				
		type ents_v is varray(10) of rhnOrgEntitlementType.label%TYPE;
		ents_to_process ents_v;
		cursor ents(ent_label_in in varchar2) is
			select	label, id
			from	rhnOrgEntitlementType
			where	label = ent_label_in;
		cursor org_ents(ent_label_in in varchar2) is
			select	1
			from	rhnOrgEntitlements oe,
					rhnOrgEntitlementType oet
			where	oet.label = ent_label_in
				and oe.org_id = org_id_in
				and oet.id = oe.entitlement_id;
		create_row char(1);
	begin
		ents_to_process := ents_v();
		roles_to_process := roles_v();
		-- a bit kludgy, but only for 3.4 really.  Certainly no
		-- worse than the old code...
		if service_label_in = 'enterprise' or 
           service_label_in = 'management' then
			ents_to_process.extend;
			ents_to_process(ents_to_process.count) := 'sw_mgr_enterprise';

			roles_to_process.extend;
			roles_to_process(roles_to_process.count) := 'org_admin';

			roles_to_process.extend;
			roles_to_process(roles_to_process.count) := 'system_group_admin';

			roles_to_process.extend;
			roles_to_process(roles_to_process.count) := 'activation_key_admin';

			roles_to_process.extend;
			roles_to_process(roles_to_process.count) := 'org_applicant';
		elsif service_label_in = 'provisioning' then
			ents_to_process.extend;
			ents_to_process(ents_to_process.count) := 'rhn_provisioning';

			roles_to_process.extend;
			roles_to_process(roles_to_process.count) := 'system_group_admin';

			roles_to_process.extend;
			roles_to_process(roles_to_process.count) := 'activation_key_admin';

			roles_to_process.extend;
			roles_to_process(roles_to_process.count) := 'config_admin';
			-- another nasty special case...
			if enable_in = 'Y' then
				ents_to_process.extend;
				ents_to_process(ents_to_process.count) := 'sw_mgr_enterprise';
			end if;
		elsif service_label_in = 'monitoring' then
			ents_to_process.extend;
			ents_to_process(ents_to_process.count) := 'rhn_monitor';

			roles_to_process.extend;
			roles_to_process(roles_to_process.count) := 'monitoring_admin';
		elsif service_label_in = 'virtualization' then
			ents_to_process.extend;
			ents_to_process(ents_to_process.count) := 'rhn_virtualization';

			roles_to_process.extend;
			roles_to_process(roles_to_process.count) := 'config_admin';
        elsif service_label_in = 'virtualization_platform' then
			ents_to_process.extend;
			ents_to_process(ents_to_process.count) := 'rhn_virtualization_platform'; 
			roles_to_process.extend;
			roles_to_process(roles_to_process.count) := 'config_admin';
	elsif service_label_in = 'nonlinux' then
			ents_to_process.extend;
			ents_to_process(ents_to_process.count) := 'rhn_nonlinux';
			roles_to_process.extend;
			roles_to_process(roles_to_process.count) := 'config_admin';
		end if;

		if enable_in = 'Y' then
			for i in 1..ents_to_process.count loop
				for ent in ents(ents_to_process(i)) loop
					create_row := 'Y';
					for oe in org_ents(ent.label) loop
						create_row := 'N';
					end loop;
					if create_row = 'Y' then
						insert into rhnOrgEntitlements(org_id, entitlement_id)
							values (org_id_in, ent.id);
					end if;
				end loop;
			end loop;
			for i in 1..roles_to_process.count loop
				for role in roles(roles_to_process(i)) loop
					create_row := 'Y';
					for o_r in org_roles(role.label) loop
						create_row := 'N';
					end loop;
					if create_row = 'Y' then
						insert into rhnUserGroup(
								id, name, description, current_members,
								group_type, org_id
							) (
								select	rhn_user_group_id_seq.nextval,
										ugt.name || 's',
										ugt.name || 's for Org ' ||
											o.name || ' ('|| o.id ||')',
										0, ugt.id, o.id
								from	rhnUserGroupType ugt,
										web_customer o
								where	o.id = org_id_in
									and ugt.id = role.id
							);
					end if;
				end loop;
			end loop;
		else
			for i in 1..ents_to_process.count loop
				for ent in ents(ents_to_process(i)) loop
					delete from rhnOrgEntitlements
					 where org_id = org_id_in
					   and entitlement_id = ent.id;
				end loop;
			end loop;
		end if;
	end modify_org_service;

	procedure set_customer_enterprise (
		customer_id_in in number
	) is
	begin
		modify_org_service(customer_id_in, 'enterprise', 'Y');
	end set_customer_enterprise;

	procedure set_customer_provisioning (
		customer_id_in in number
	) is
	begin
		modify_org_service(customer_id_in, 'provisioning', 'Y');
	end set_customer_provisioning;

	procedure set_customer_nonlinux (
		customer_id_in in number
	) is
	begin
		modify_org_service(customer_id_in, 'nonlinux', 'Y');
	end set_customer_nonlinux;

	procedure unset_customer_enterprise (
		customer_id_in in number
	) is
	begin
		modify_org_service(customer_id_in, 'enterprise', 'N');
	end unset_customer_enterprise;

	procedure unset_customer_provisioning (
		customer_id_in in number
	) is
	begin
		modify_org_service(customer_id_in, 'provisioning', 'N');
	end unset_customer_provisioning;

	procedure unset_customer_nonlinux (
		customer_id_in in number
	) is
	begin
		modify_org_service(customer_id_in, 'nonlinux', 'N');
	end unset_customer_nonlinux;

    -- *******************************************************************
    -- PROCEDURE: prune_group
    -- Unsubscribes servers consuming physical slots that over the org's
    --   limit.
    -- Called by: set_group_count, prune_everything, repoll_virt_guest_entitlements
    -- *******************************************************************
	procedure prune_group (
		group_id_in in number,
		type_in in char,
		quantity_in in number
	) is
		cursor usergroups is
			select	user_id, user_group_id, ugt.label
			from	rhnUserGroupType	ugt,
					rhnUserGroup		ug,
					rhnUserGroupMembers	ugm
			where	1=1
				and ugm.user_group_id = group_id_in
				and ugm.user_id in (
					select	user_id
					from	(
						select	rownum row_number,
								user_id,
								time
						from	(
							select	user_id,
									modified time
							from	rhnUserGroupMembers
							where	user_group_id = group_id_in
							order by time asc
						)
					)
					where	row_number > quantity_in
				)
				and ugm.user_group_id = ug.id
				and ug.group_type = ugt.id;
        cursor servergroups is
           select  server_id, server_group_id, sgt.id group_type_id, sgt.label
            from    rhnServerGroupType              sgt,
                            rhnServerGroup                  sg,
                            rhnServerGroupMembers   sgm
            where   1=1
                    and sgm.server_group_id = group_id_in
                    and sgm.server_id in (
                            select  server_id
                            from    (
                                    select  rownum row_number,
                                                    server_id,
                                                    time
                                    from    (
                                            select  sep.server_id,
                                                    sep.modified time
                                            from
                                                rhnServerEntitlementPhysical sep
                                            where
                                                sep.server_group_id = group_id_in
                                            order by time asc
                                    )
                            )
                            where   row_number > quantity_in
                    )
                    and sgm.server_group_id = sg.id
                    and sg.group_type = sgt.id;
      type_is_base char;
	begin
		if type_in = 'U' then
			update		rhnUserGroup
				set		max_members = quantity_in
				where	id = group_id_in;

			for ug in usergroups loop
				rhn_user.remove_from_usergroup(ug.user_id, ug.user_group_id);
			end loop;
		elsif type_in = 'S' then
			update		rhnServerGroup
				set		max_members = quantity_in
				where	id = group_id_in;

			for sg in servergroups loop
				remove_server_entitlement(sg.server_id, sg.label);
            
            select is_base 
            into type_is_base
            from rhnServerGroupType sgt
            where sgt.id = sg.group_type_id;
 
            -- if we're removing a base ent, then be sure to
            -- remove the server's channel subscriptions.
            if ( type_is_base = 'Y' ) then
				   rhn_channel.clear_subscriptions(sg.server_id);
            end if;

			end loop;
		end if;
	end prune_group;

    -- *******************************************************************
    -- PROCEDURE: assign_system_entitlement
    --
    -- Moves system entitlements from from_org_id_in to to_org_id_in.
    -- Can raise not_enough_entitlements_in_base_org if from_org_id_in
    -- does not have enough entitlements to cover the move.
    -- Takes care of unentitling systems if necessary by calling 
    -- set_group_count
    -- *******************************************************************
    procedure assign_system_entitlement(
        group_label_in in varchar2,
        from_org_id_in in number,
        to_org_id_in in number,
        quantity_in in number
    )
    is
        prev_ent_count number;
        new_ent_count number;
        group_type number;
    begin

        begin
            select max_members
            into prev_ent_count
            from rhnServerGroupType sgt,
                 rhnServerGroup sg
            where sg.org_id = from_org_id_in
              and sg.group_type = sgt.id
              and sgt.label = group_label_in;
        exception
            when NO_DATA_FOUND then
                rhn_exception.raise_exception(
                              'not_enough_entitlements_in_base_org');
        end;

        begin
            select id
            into group_type
            from rhnServerGroupType
            where label = group_label_in;
        exception
            when NO_DATA_FOUND then
                rhn_exception.raise_exception(
                              'invalid_server_group');
        end;

        new_ent_count := prev_ent_count - quantity_in;

        if new_ent_count < 0 then
            rhn_exception.raise_exception(
                          'not_enough_entitlements_in_base_org');
        end if;

        rhn_entitlements.set_group_count(from_org_id_in,
                                         'S',
                                         group_type,
                                         new_ent_count);

        rhn_entitlements.set_group_count(to_org_id_in,
                                         'S',
                                         group_type,
                                         quantity_in);
    end assign_system_entitlement;

    -- *******************************************************************
    -- PROCEDURE: assign_channel_entitlement
    --
    -- Moves channel entitlements from from_org_id_in to to_org_id_in.
    -- Can raise not_enough_entitlements_in_base_org if from_org_id_in
    -- does not have enough entitlements to cover the move.
    -- Takes care of unentitling systems if necessary by calling 
    -- set_family_count
    -- *******************************************************************
    procedure assign_channel_entitlement(
        channel_family_label_in in varchar2,
        from_org_id_in in number,
        to_org_id_in in number,
        quantity_in in number
    )
    is
        prev_ent_count number;
        new_ent_count number;
        cfam_id       number;
    begin

        begin
            select max_members
            into prev_ent_count
            from rhnChannelFamily cf,
                 rhnPrivateChannelFamily pcf
            where pcf.org_id = from_org_id_in
              and pcf.channel_family_id = cf.id
              and cf.label = channel_family_label_in;
        exception
            when NO_DATA_FOUND then
                rhn_exception.raise_exception(
                              'not_enough_entitlements_in_base_org');
        end;

        begin
            select id
            into cfam_id
            from rhnChannelFamily
            where label = channel_family_label_in;
        exception
            when NO_DATA_FOUND then
                rhn_exception.raise_exception(
                              'invalid_channel_family');
        end;                              

        new_ent_count := prev_ent_count - quantity_in;

        if new_ent_count < 0 then
            rhn_exception.raise_exception(
                          'not_enough_entitlements_in_base_org');
        end if;

        rhn_entitlements.set_family_count(from_org_id_in,
                                          cfam_id,
                                          new_ent_count);

        rhn_entitlements.set_family_count(to_org_id_in,
                                          cfam_id,
                                          quantity_in);

    end assign_channel_entitlement;

    -- *******************************************************************
    -- PROCEDURE: activate_system_entitlement
    --
    -- Sets the values in rhnServerGroup for a given rhnServerGroupType.
    -- 
    -- Calls: set_group_count to update, prune, or create the group.
    -- Called by: the code that activates a satellite cert. 
    --
    -- Raises not_enough_entitlements_in_base_org if there are not enough
    -- entitlements in the base org to cover the difference when you are
    -- descreasing the number of entitlements.
    -- *******************************************************************
    procedure activate_system_entitlement(
        org_id_in in number,
        group_label_in in varchar2,
        quantity_in in number
    )
    is
        prev_ent_count number; 
        prev_ent_count_sum number; 
        group_type number;
    begin

        -- Fetch the current entitlement count for the base org
        -- into prev_ent_count
        begin
            select max_members
            into prev_ent_count
            from rhnServerGroupType sgt,
                 rhnServerGroup sg
            where sg.group_type = sgt.id
              and sgt.label = group_label_in
              and sg.org_id = org_id_in;
        exception
            when NO_DATA_FOUND then
                prev_ent_count := 0;
        end;

        -- Fetch the current total entitlement count across all orgs
        begin
            select sum(max_members)
            into prev_ent_count_sum
            from rhnServerGroupType sgt,
                 rhnServerGroup sg
            where sg.group_type = sgt.id
              and sgt.label = group_label_in;
        exception
            when NO_DATA_FOUND then
                prev_ent_count_sum := 0;
        end;

        begin
            select id
            into group_type
            from rhnServerGroupType
            where label = group_label_in;
        exception
            when NO_DATA_FOUND then
                rhn_exception.raise_exception(
                              'invalid_server_group');
        end;

        -- If we're setting the total entitlemnt count to a lower value,
        -- and that value is less than the count in the base org,
        -- we need to raise an exception.
        if quantity_in < prev_ent_count_sum and 
           quantity_in < prev_ent_count then
            rhn_exception.raise_exception(
                          'not_enough_entitlements_in_base_org');
        else
            rhn_entitlements.set_group_count(org_id_in,
                                             'S',
                                             group_type,
                                             quantity_in);
        end if;


    end activate_system_entitlement;

    -- *******************************************************************
    -- PROCEDURE: activate_channel_entitlement
    --
    -- Calls: set_family_count to update, prune, or create the family
    --        permission bucket.
    -- Called by: the code that activates a satellite cert. 
    --
    -- Raises not_enough_entitlements_in_base_org if there are not enough
    -- entitlements in the base org to cover the difference when you are
    -- descreasing the number of entitlements.
    -- *******************************************************************
    procedure activate_channel_entitlement(
        org_id_in in number,
        channel_family_label_in in varchar2,
        quantity_in in number
    )
    is
        prev_ent_count number; 
        prev_ent_count_sum number; 
        cfam_id number;
    begin

        -- Fetch the current entitlement count for the base org
        -- into prev_ent_count
        begin
            select max_members
            into prev_ent_count
            from rhnChannelFamily cf,
                 rhnPrivateChannelFamily pcf
            where pcf.org_id = org_id_in
              and pcf.channel_family_id = cf.id
              and cf.label = channel_family_label_in;
        exception
            when NO_DATA_FOUND then
                prev_ent_count := 0;
        end;

        -- Fetch the current total entitlement count across all orgs
        begin
            select sum(max_members)
            into prev_ent_count_sum
            from rhnChannelFamily cf,
                 rhnPrivateChannelFamily pcf
            where pcf.channel_family_id = cf.id
              and cf.label = channel_family_label_in;
        exception
            when NO_DATA_FOUND then
                prev_ent_count_sum := 0;
        end;

        begin
            select id
            into cfam_id
            from rhnChannelFamily
            where label = channel_family_label_in;
        exception
            when NO_DATA_FOUND then
                rhn_exception.raise_exception(
                              'invalid_channel_family');
        end;                              

        -- If we're setting the total entitlemnt count to a lower value,
        -- and that value is less than the count in the base org,
        -- we need to raise an exception.
        if quantity_in < prev_ent_count_sum and 
           quantity_in < prev_ent_count then
            rhn_exception.raise_exception(
                          'not_enough_entitlements_in_base_org');
        else
            rhn_entitlements.set_family_count(org_id_in,
                                              cfam_id,
                                              quantity_in);
        end if;

    end activate_channel_entitlement;


	procedure set_group_count (
		customer_id_in in number,
		type_in in char,
		group_type_in in number,
		quantity_in in number
	) is
		group_id number;
		quantity number;
	begin
		quantity := quantity_in;
		if quantity is not null and quantity < 0 then
			quantity := 0;
		end if;

		if type_in = 'U' then
			select	rug.id
			into	group_id
			from	rhnUserGroup rug
			where	1=1
				and rug.org_id = customer_id_in
				and rug.group_type = group_type_in;
		elsif type_in = 'S' then
			select	rsg.id
			into	group_id
			from	rhnServerGroup rsg
			where	1=1
				and rsg.org_id = customer_id_in
				and rsg.group_type = group_type_in;
		end if;

		rhn_entitlements.prune_group(
			group_id,
			type_in,
			quantity
		);
	exception
		when no_data_found then
			if type_in = 'U' then
				insert into rhnUserGroup (
						id, name, description, max_members, current_members,
						group_type, org_id, created, modified
					) (
						select	rhn_user_group_id_seq.nextval, name, name,
								quantity, 0, id, customer_id_in,
								sysdate, sysdate
						from	rhnUserGroupType
						where	id = group_type_in
				);
			elsif type_in = 'S' then
				insert into rhnServerGroup (
						id, name, description, max_members, current_members,
						group_type, org_id, created, modified
					) (
						select	rhn_server_group_id_seq.nextval, name, name,
								quantity, 0, id, customer_id_in,
								sysdate, sysdate
						from	rhnServerGroupType
						where	id = group_type_in
				);
			end if;
	end set_group_count;

    -- *******************************************************************
    -- PROCEDURE: prune_family
    -- Unsubscribes servers consuming physical slots from the channel family 
    --   that are over the org's limit.
    -- Called by: set_family_count, prune_everything
    -- *******************************************************************
	procedure prune_family (
		customer_id_in in number,
		channel_family_id_in in number,
		quantity_in in number
	) is
		cursor serverchannels is
			select	sc.server_id,
					sc.channel_id
			from	rhnServerChannel sc,
					rhnChannelFamilyMembers cfm
			where	1=1
				and cfm.channel_family_id = channel_family_id_in
				and cfm.channel_id = sc.channel_id
				and server_id in (
					select	server_id
					from	(
						select	server_id,
								time,
								rownum row_number
						from	(
							select	rs.id					server_id,
									rcfm.modified			time
							from	
									rhnServerChannel		rsc,
									rhnChannelFamilyMembers	rcfm,
                                    rhnServer				rs
							where	1=1
								and rs.org_id = customer_id_in
								and rs.id = rsc.server_id
								and rsc.channel_id = rcfm.channel_id
								and rcfm.channel_family_id =
									channel_family_id_in
                                -- we only want to grab servers consuming
                                -- physical slots.
                                and exists (
                                    select 1
                                    from rhnChannelFamilyServerPhysical cfsp
                                    where cfsp.server_id = rs.id
                                    and cfsp.channel_family_id = 
                                        channel_family_id_in
                                    )
							order by time asc
						)
					)
					where row_number > quantity_in
				);
	begin
		-- if we get a null customer_id, this is completely bogus.
		if customer_id_in is null then
			return;
		end if;

		update		rhnPrivateChannelFamily
			set		max_members = quantity_in
			where	1=1
				and org_id = customer_id_in
				and channel_family_id = channel_family_id_in;

		for sc in serverchannels loop
			rhn_channel.unsubscribe_server(sc.server_id, sc.channel_id, 1, 1);
		end loop;
	end prune_family;
		
	procedure set_family_count (
		customer_id_in in number,
		channel_family_id_in in number,
		quantity_in in number
	) is
		cursor privperms is
			select	1
			from	rhnPrivateChannelFamily
			where	org_id = customer_id_in
				and channel_family_id = channel_family_id_in;
		cursor pubperms is
			select	o.id org_id
			from	web_customer o,
					rhnPublicChannelFamily pcf
			where	pcf.channel_family_id = channel_family_id_in;
		quantity number;
		done number := 0;
	begin
		quantity := quantity_in;
		if quantity is not null and quantity < 0 then
			quantity := 0;
		end if;

		if customer_id_in is not null then
			for perm in privperms loop
				rhn_entitlements.prune_family(
					customer_id_in,
					channel_family_id_in,
					quantity
				);
				update rhnPrivateChannelFamily
					set max_members = quantity
					where org_id = customer_id_in
						and channel_family_id = channel_family_id_in;
				return;
			end loop;
			
			insert into rhnPrivateChannelFamily (
					channel_family_id, org_id, max_members, current_members
				) values (
					channel_family_id_in, customer_id_in, quantity, 0
				);
			return;
		end if;

		for perm in pubperms loop
			if quantity = 0 then
				rhn_entitlements.prune_family(
					perm.org_id,
					channel_family_id_in,
					quantity
				);
				if done = 0 then
					delete from rhnPublicChannelFamily
						where channel_family_id = channel_family_id_in;
				end if;
			end if;
			done := 1;
		end loop;
		-- if done's not 1, then we don't have any entitlements
		if done != 1 then
			insert into rhnPublicChannelFamily (
					channel_family_id
				) values (
					channel_family_id_in
				);
		end if;
	end set_family_count;

	-- this expects quantity_in to be the number of available slots, not the
	-- max_members of the server group.  If you give it too many, it'll fail
	-- and raise servergroup_max_members.
	-- We should NEVER run this unless we're SURE that we won't
	-- be violating the max.
	procedure entitle_last_modified_servers (
		customer_id_in in number,
		type_label_in in varchar2,
		quantity_in in number
	) is
		-- find the servers that aren't currently in slots
		cursor servers(cid_in in number, quant_in in number) is
			select	server_id
			from	(
						select	rownum row_number,
								server_id
						from	(
									select	rs.id server_iD
									from	rhnServer rs
									where	1=1
										and rs.org_id = cid_in
										and not exists (
											select	1
											from	rhnServerGroup sg,
													rhnServerGroupMembers rsgm
											where	rsgm.server_id = rs.id
												and rsgm.server_group_id = sg.id
												and sg.group_type is not null
										)
                                        and not exists (
                                            select 1
                                            from rhnVirtualInstance vi
                                            where vi.virtual_system_id =
                                                  rs.id
                                        )                                                                           order by modified desc
								)
					)
			where	row_number <= quant_in;
	begin
		for server in servers(customer_id_in, quantity_in) loop
			rhn_entitlements.entitle_server(server.server_id, type_label_in);
		end loop;
	end entitle_last_modified_servers;

	procedure prune_everything (
		customer_id_in in number
	) is
		cursor everything is
			-- all our server groups
			select	sg.id					id,
					'S'						type,
					sg.max_members			quantity
			from	rhnServerGroup			sg
			where	sg.org_id = customer_id_in
			union
			-- all our user groups
			select	ug.id					id,
					'U'						type,
					ug.max_members 			quantity
			from	rhnUserGroup			ug
			where	ug.org_id = customer_id_in
			union ( 
			-- all the channel families we have perms to
			select	cfp.channel_family_id	id,
					'C'						type,
					cfp.max_members			quantity
			from	rhnOrgChannelFamilyPermissions cfp
			where	cfp.org_id = customer_id_in
			union
			-- plus all the ones we're using that we have no perms for
			select	cfm.channel_family_id	id,
					'C'						type,
					0						quantity
			from	rhnChannelFamily		cf,
					rhnChannelFamilyMembers	cfm,
					rhnServerChannel		sc,
					rhnServer				s
			where	s.org_id = customer_id_in
				and s.id = sc.server_id
				and sc.channel_id = cfm.channel_id
				and cfm.channel_family_id = cf.id
				and cf.org_id is not null
				and cf.org_id != customer_id_in
				and not exists (
					select	1
					from	rhnOrgChannelFamilyPermissions cfp
					where	cfp.org_id = customer_id_in
						and cfp.channel_family_id = cfm.channel_family_id
					)
			);
	begin
		for one in everything loop
			if one.type in ('U','S') then
				prune_group(one.id, one.type, one.quantity);
			else
				prune_family(customer_id_in, one.id, one.quantity);
			end if;
		end loop;
	end prune_everything;

	procedure subscribe_newest_servers (
		customer_id_in in number
	) is
		-- find servers without base channels
		cursor servers(cid_in in number) is
			select	s.id
			from	rhnServer			s
			where	1=1
				and s.org_id = cid_in
				and not exists (
						select 1
						from	rhnChannel			c,
								rhnServerChannel	sc
						where	sc.server_id = s.id
							and sc.channel_id = c.id
							and c.parent_channel is null
					)
                and not exists (
                        select 1
                        from rhnVirtualInstance vi
                        where vi.virtual_system_id = s.id
                    )                        
			order by s.modified desc;
		channel_id number;
	begin
		for server in servers(customer_id_in) loop
			channel_id := rhn_channel.guess_server_base(server.id);
			if channel_id is not null then
				begin
					rhn_channel.subscribe_server(server.id, channel_id);
					commit;
				-- exception is really channel_family_no_subscriptions
				exception
					when others then
						null;
				end;
			end if;
		end loop;
	end subscribe_newest_servers;
end rhn_entitlements;
/
show errors

--
-- $Log$
-- Revision 1.56  2004/07/21 21:27:36  nhansen
-- bug 128196: use rhn_monitor instead of rhn_monitoring as the rhnOrgEntitlementType
--
-- Revision 1.55  2004/07/20 15:38:57  pjones
-- bugzilla: 128196 -- make entitling "monitoring" work.
--
-- Revision 1.54  2004/07/14 19:13:13  pjones
-- bugzilla: 126461 -- entitlement changes for new user roles
--
-- Revision 1.53  2004/07/02 19:18:20  pjones
-- bugzilla: 125937 -- use rhn_user to remove user roles
--
-- Revision 1.52  2004/05/26 19:45:48  pjones
-- bugzilla: 123639
-- 1) reformat "entitlement_grants_service"
-- 2) make the .pks and .pkb be in the same order.
-- 3) add "modify_org_service" (to be used instead of set_customer_SERVICELEVEL)
-- 4) add monitoring specific data.
--
-- Revision 1.51  2004/04/19 18:18:51  pjones
-- bugzilla: none -- misa's using set_family_count() to set null org entitlements
--
-- Revision 1.50  2004/04/14 00:09:24  pjones
-- bugzilla: 120761 -- split rhnChannelPermissions into two tables, eliminating
-- a frequent full table scan
--
-- Revision 1.49  2004/03/26 16:53:42  pjones
-- bugzilla: none -- make rhn_nonlinux give config_admin too on sat.
--
-- Revision 1.48  2004/03/25 22:29:56  pjones
-- bugzilla: none -- only create config_admin in set_customer_prov if we're
-- on a satellite



--
-- $Id: rhn_org.pks 119120 2007-08-10 18:56:44Z jslagle $
--

CREATE OR REPLACE
PACKAGE rhn_org
IS
	version varchar2(100) := '$Id: rhn_org.pks 119120 2007-08-10 18:56:44Z jslagle $';

    CURSOR server_group_by_label(org_id_in NUMBER, group_label_in VARCHAR2) IS
    	   SELECT SG.*
	     FROM rhnServerGroupType SGT,
	     	  rhnServerGroup SG
	    WHERE SG.group_type = SGT.id
	      AND SGT.label = group_label_in
	      AND SG.org_id = org_id_in;
	    
    FUNCTION find_server_group_by_type(org_id_in NUMBER, 
                                       group_label_in VARCHAR2) 
    RETURN NUMBER;

    procedure delete_org(org_id_in in number);
    procedure delete_user(user_id_in in number);

END rhn_org;
/
SHOW ERRORS;



--
-- $Id: rhn_org.pkb 120076 2007-08-27 20:18:08Z jslagle $
--

CREATE OR REPLACE
PACKAGE BODY rhn_org
IS
	body_version varchar2(100) := '$Id: rhn_org.pkb 120076 2007-08-27 20:18:08Z jslagle $';

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
    
    procedure delete_org (
        org_id_in in number
    )
    is

        cursor users is
        select id
        from web_contact
        where org_id = org_id_in;

		cursor servers(org_id_in in number) is
        select	id
        from	rhnServer
        where	org_id = org_id_in;

        cursor config_channels is
        select id
        from rhnConfigChannel
        where org_id = org_id_in;

    begin

        if org_id_in = 1 then
            rhn_exception.raise_exception('cannot_delete_base_org');
        end if;

        -- Delete all users.
        for u in users loop
            rhn_org.delete_user(u.id);
        end loop;

        -- Delete all servers.
        for s in servers(org_id_in) loop
            delete_server(s.id);
        end loop;

        -- Delete all config channels.
        for c in config_channels loop
            rhn_config.delete_channel(c.id);
        end loop;

        -- Give the org's entitlements back to the main org.
        rhn_entitlements.remove_org_entitlements(org_id_in);

        -- Clean up tables where we don't have a cascading delete.
        delete from rhnChannel where org_id = org_id_in;
        delete from rhnDailySummaryQueue where org_id = org_id_in;
        delete from rhnOrgQuota where org_id = org_id_in;
        delete from rhnOrgInfo where org_id = org_id_in;
        delete from rhnFileList where org_id = org_id_in;
        delete from rhnServerGroup where org_id = org_id_in;
        delete from rhn_check_suites where customer_id = org_id_in;
        delete from rhn_command_target where customer_id = org_id_in;
        delete from rhn_contact_groups where customer_id = org_id_in;
        delete from rhn_notification_formats where customer_id = org_id_in;
        delete from rhn_probe where customer_id = org_id_in;
        delete from rhn_redirects where customer_id = org_id_in;
        delete from rhn_sat_cluster where customer_id = org_id_in;
        delete from rhn_schedules where customer_id = org_id_in;

        -- Delete the org.
        delete from web_customer where id = org_id_in;

    end delete_org;

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
		cursor messages is
			select	message_id id
			from	rhnUserMessage
			where	user_id = user_id_in;
		users			number;
		our_org_id		number;
		other_users		number;
		other_org_admin	number;
        other_user_id  number;
	begin
		select	wc.org_id
		into	our_org_id
		from	web_contact wc
		where	id = user_id_in;

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
        -- Just Delete the user
		else
            begin
                delete from web_contact where id = user_id_in;
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


begin
    dbms_utility.compile_schema('RHNSAT');
end;
/

exit;
