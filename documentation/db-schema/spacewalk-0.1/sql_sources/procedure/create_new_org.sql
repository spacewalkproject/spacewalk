-- created by Oraschemadoc Fri Jun 13 14:06:11 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE PROCEDURE "RHNSAT"."CREATE_NEW_ORG" 
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
        insert into rhnServerGroup
		( id, name, description, max_members, group_type, org_id )
		select rhn_server_group_id_seq.nextval, sgt.name, sgt.name,
			0, sgt.id, new_org_id
		from rhnServerGroupType sgt
		where sgt.label = 'sw_mgr_entitled';
	org_id_out := new_org_id;
end create_new_org;
 
/
