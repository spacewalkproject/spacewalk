-- oracle equivalent source sha1 381e28a0593ced4bb7bb04840a783711f42347c9

create or replace function
create_first_org
(
	name_in in varchar,
	password_in in varchar
)
returns void as
$$
declare
	ug_type			numeric;
	group_val		numeric;
begin
	insert into web_customer (
		id, name
	) values (
		1, name_in
	);

	select nextval( 'rhn_user_group_id_seq' ) into group_val from dual;

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
		'Organization Administrators for Org ' || name_in || ' (1)',
		NULL, ug_type, 1
	);

	select nextval('rhn_user_group_id_seq') into group_val from dual;

	select	id
	into	ug_type
	from	rhnUserGroupType
	where	label = 'org_applicant';

	insert into rhnUserGroup (
		id, name,
		description,
		max_members, group_type, org_id
	) values (
		group_val, 'Organization Applicants',
		'Organization Applicants for Org ' || name_in || ' (1)',
		NULL, ug_type, 1
	);

	select nextval('rhn_user_group_id_seq') into group_val from dual;

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
		'System Group Administrators for Org ' || name_in || ' (1)',
		NULL, ug_type, 1
	);


	select nextval('rhn_user_group_id_seq') into group_val from dual;

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
		'Activation Key Administrators for Org ' || name_in || ' (1)',
		NULL, ug_type, 1
	);

	-- config admin is special; it gets created in
	-- rhn_entitlements.set_customer_provisioning instead.
	
	select nextval('rhn_user_group_id_seq') into group_val from dual;

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
		'Channel Administrators for Org ' || name_in || ' (1)',
		NULL, ug_type, 1
	);

	select nextval('rhn_user_group_id_seq') into group_val from dual;

	select	id
	into	ug_type
	from	rhnUserGroupType
	where	label = 'satellite_admin';

	insert into rhnUserGroup (
		id, name,
		description,
		max_members, group_type, org_id
	) values (
		group_val, 'Satellite Administrators',
		'Satellite Administrators for Org ' || name_in || ' (1)',
		NULL, ug_type, 1
	);


	-- there aren't any users yet, so we don't need to update
	-- rhnUserServerPerms
        insert into rhnServerGroup 
		( id, name, description, max_members, group_type, org_id )
		select nextval('rhn_server_group_id_seq'), sgt.name, sgt.name, 
			0, sgt.id, 1
		from rhnServerGroupType sgt
		where sgt.label = 'sw_mgr_entitled';
		
end
$$ language plpgsql;

