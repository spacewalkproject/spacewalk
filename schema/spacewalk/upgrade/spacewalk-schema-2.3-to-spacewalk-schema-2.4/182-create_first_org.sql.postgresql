-- oracle equivalent source sha1 1cc44c8913e3bf46dde9525f625eebb63e195c25
--
-- Copyright (c) 2008--2012 Red Hat, Inc.
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
--
-- This creates an org with ID of 1, and errors if there already is one
--

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

	select nextval('rhn_user_group_id_seq') into group_val from dual;

	select	id
	into	ug_type
	from	rhnUserGroupType
	where	label = 'config_admin';

	insert into rhnUserGroup (
		id, name,
		description,
		max_members, group_type, org_id
	) values (
		group_val, 'Configuration Administrators',
		'Configuration Administrators for Org ' || name_in || ' (1)',
		NULL, ug_type, 1
	);

	-- there aren't any users yet, so we don't need to update
	-- rhnUserServerPerms

        insert into rhnServerGroup
                ( id, name, description, group_type, org_id )
                select nextval('rhn_server_group_id_seq'), sgt.name, sgt.name,
                        sgt.id, 1
                from rhnServerGroupType sgt
                where sgt.label = 'bootstrap_entitled';

        insert into rhnServerGroup
                ( id, name, description, group_type, org_id )
                select nextval('rhn_server_group_id_seq'), sgt.name, sgt.name,
                        sgt.id, 1
                from rhnServerGroupType sgt
                where sgt.label = 'enterprise_entitled';
	
        insert into rhnServerGroup
                ( id, name, description, group_type, org_id )
                select nextval('rhn_server_group_id_seq'), sgt.name, sgt.name,
                        sgt.id, 1
                from rhnServerGroupType sgt
                where sgt.label = 'virtualization_host';

end
$$ language plpgsql;

