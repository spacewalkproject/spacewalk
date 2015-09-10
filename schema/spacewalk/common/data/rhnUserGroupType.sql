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
--
--
-- data for rhnUserGroupType

insert into rhnUserGroupType (id, label, name) values (
	sequence_nextval('rhn_usergroup_type_seq'),
	'satellite_admin',
	'Satellite Administrator'
);

insert into rhnUserGroupType (id, label, name) values (
	sequence_nextval('rhn_usergroup_type_seq'),
	'org_admin',
	'Organization Administrator'
);

insert into rhnUserGroupType (id, label, name) values (
	sequence_nextval('rhn_usergroup_type_seq'),
	'channel_admin',
	'Channel Administrator'
);

insert into rhnUserGroupType (id, label, name) values (
	sequence_nextval('rhn_usergroup_type_seq'),
	'config_admin',
	'Configuration Administrator'
);

insert into rhnUserGroupType (id, label, name) values (
	sequence_nextval('rhn_usergroup_type_seq'),
	'system_group_admin',
	'System Group Administrator'
);

insert into rhnUserGroupType (id, label, name) values (
	sequence_nextval('rhn_usergroup_type_seq'),
	'activation_key_admin',
	'Activation Key Administrator'
);

commit;

