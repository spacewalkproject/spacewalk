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
rhnSatelliteServerGroup
(
	server_id		number
				constraint rhn_satsg_sid_nn not null
				constraint rhn_satsg_sid_fk
					references rhnSatelliteInfo(server_id)
					on delete cascade,
	server_group_type	number
				constraint rhn_satsg_sgtype_nn not null
				constraint rhn_satsg_sgtype_fk
					references rhnServerGroupType(id),
	max_members		number,
	created			date default(sysdate)
				constraint rhn_satsg_creat_nn not null,
	modified		date default(sysdate)
				constraint rhn_satsg_mod_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create unique index rhn_satsg_sid_sgt_uq
	on rhnSatelliteServerGroup( server_id, server_group_type )
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_satsg_mod_trig
before insert or update on rhnSatelliteServerGroup
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

--
-- $Log$
-- Revision 1.1  2003/10/21 19:35:19  pjones
-- bugzilla: 107200 -- rhnSatelliteServerGroup now, so we can handle
-- arbitrary server group entitlements for satellite
--
