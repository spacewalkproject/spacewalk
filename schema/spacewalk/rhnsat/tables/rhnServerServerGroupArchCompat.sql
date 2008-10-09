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
        server_arch_id	number
                        constraint rhn_ssg_ac_said_nn not null
                        constraint rhn_ssg_ac_said_fk 
				references rhnServerArch(id),
	server_group_type number
			constraint rhn_ssg_ac_sgt_nn not null
			constraint rhn_ssg_ac_sgt_fk
				references rhnServerGroupType(id),
	created		date default(sysdate)
			constraint rhn_ssg_ac_created_nn not null,
	modified	date default(sysdate)
			constraint rhn_ssg_ac_modified_nn not null
)
	storage( freelists 16 )
	enable row movement
	initrans 32;

create unique index rhn_ssg_ac_said_sgt_uq
	on rhnServerServerGroupArchCompat(server_arch_id, server_group_type)
	tablespace [[64k_tbs]]
	storage( freelists 16 )
	initrans 32;

create index rhn_ssg_ac_sgt_said_idx
	on rhnServerServerGroupArchCompat(server_group_type, server_arch_id)
	tablespace [[64k_tbs]]
	storage( freelists 16 )
	initrans 32
	nologging;

create or replace trigger
rhn_ssg_ac_mod_trig
before insert or update on rhnServerServerGroupArchCompat
for each row
begin
        :new.modified := sysdate;
end;
/
show errors

--
--
-- Revision 1.1  2004/02/19 22:19:29  pjones
-- bugzilla: 115896 -- don't let servers subscribe to services for which
-- their server arch is not compatible
--
