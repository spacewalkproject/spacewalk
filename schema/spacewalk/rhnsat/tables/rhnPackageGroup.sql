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
--/

create table
rhnPackageGroup
(
        id              number
			constraint rhn_package_group_id_nn not null
                        constraint rhn_package_group_id_pk primary key
                        using index tablespace [[2m_tbs]],
        name            varchar2(100)
			constraint rhn_package_group_name_nn not null,
        created         date default(sysdate)
			constraint rhn_package_group_created_nn not null,
        modified        date default(sysdate)
			constraint rhn_package_group_modified_nn not null
)
	enable row movement
  ;

create sequence rhn_package_group_id_seq;

create unique index rhn_package_group_name_uq
	on rhnPackageGroup(name)
	tablespace [[64k_tbs]]
  ;

create or replace trigger
rhn_package_group_mod_trig
before insert or update on rhnPackageGroup
for each row
begin
        :new.modified := sysdate;
end;
/
show errors

--
-- Revision 1.11  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.10  2002/04/26 15:05:09  pjones
-- trim logs that have satconish words in them
--
