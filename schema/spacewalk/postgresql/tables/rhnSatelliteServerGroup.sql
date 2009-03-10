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
	server_id		numeric
				not null
				constraint rhn_satsg_sid_fk
				references rhnSatelliteInfo(server_id)
				on delete cascade,
	server_group_type	numeric
				not null
				constraint rhn_satsg_sgtype_fk
				references rhnServerGroupType(id),
	max_members		numeric,
	created			date default(current_date)
				not null,
	modified		date default(current_date)
				not null,
                                constraint rhn_satsg_sid_sgt_uq 
                                unique( server_id, server_group_type )
--                              using index tablespace [[64k_tbs]]
)
  ;

/*
create or replace trigger
rhn_satsg_mod_trig
before insert or update on rhnSatelliteServerGroup
for each row
begin
	:new.modified := sysdate;
end;
/
show errors
*/
--
--
-- Revision 1.1  2003/10/21 19:35:19  pjones
-- bugzilla: 107200 -- rhnSatelliteServerGroup now, so we can handle
-- arbitrary server group entitlements for satellite
--
