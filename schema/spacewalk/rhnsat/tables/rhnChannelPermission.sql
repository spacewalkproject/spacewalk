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
--
--
--

create table
rhnChannelPermission
(
	channel_id	number
			constraint rhn_cperm_cid_nn not null
			constraint rhn_cperm_cidffk
				references rhnChannel(id)
				on delete cascade,
	user_id		number
			constraint rhn_cperm_uid_nn not null
			constraint rhn_cperm_uid_fk
				references web_contact(id)
				on delete cascade,
	role_id		number
			constraint rhn_cperm_rid_nn not null
			constraint rhn_cperm_rid_fk
				references rhnChannelPermissionRole(id),
	created		date default(sysdate)
			constraint rhn_cperm_created_nn not null,
	modified	date default(sysdate)
			constraint rhn_cperm_modified_nn not null
)
	enable row movement
  ;

create unique index rhn_cperm_cid_uid_rid_idx
	on rhnChannelPermission(channel_id, user_id, role_id)
	tablespace [[2m_tbs]]
  ;

create or replace trigger
rhn_cperm_mod_trig
before insert or update on rhnChannelPermission
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

--
-- Revision 1.1  2003/07/15 17:36:50  pjones
-- bugzilla: 98933
--
-- channel permissions
--
