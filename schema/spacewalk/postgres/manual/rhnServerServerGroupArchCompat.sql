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
rhnServerServerGroupArchCompat
(
        server_arch_id	   numeric
                           not null
                           constraint rhn_ssg_ac_said_fk 
				references rhnServerArch(id),
	server_group_type  numeric
			   not null
			   constraint rhn_ssg_ac_sgt_fk
			   references rhnServerGroupType(id),
	created		   date default(current_date)
			   not null,
	modified           date default(current_date)
		 	   not null,
                           constraint rhn_ssg_ac_said_sgt_uq
                           unique(server_arch_id, server_group_type)
--                         using index tablespace [[64k_tbs]]
)
  ;

create index rhn_ssg_ac_sgt_said_idx
	on rhnServerServerGroupArchCompat(server_group_type, server_arch_id)
--	tablespace [[64k_tbs]]
        ;

/*
create or replace trigger
rhn_ssg_ac_mod_trig
before insert or update on rhnServerServerGroupArchCompat
for each row
begin
        :new.modified := sysdate;
end;
/
show errors
*/
--
--
-- Revision 1.1  2004/02/19 22:19:29  pjones
-- bugzilla: 115896 -- don't let servers subscribe to services for which
-- their server arch is not compatible
--
