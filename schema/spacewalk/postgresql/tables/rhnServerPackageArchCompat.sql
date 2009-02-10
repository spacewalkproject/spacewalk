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
rhnServerPackageArchCompat
(
        server_arch_id	numeric
                        not null
                        constraint rhn_sp_ac_said_fk 
				references rhnServerArch(id),
	package_arch_id	numeric
			not null
			constraint rhn_sp_ac_paid_fk
				references rhnPackageArch(id),
        preference      numeric
                        not null,
	created		date default(current_date)
			not null,
	modified	date default(current_date)
			not null,
                        constraint rhn_sp_ac_said_paid_uq
                        unique( server_arch_id, package_arch_id ),
                        constraint rhn_sp_ac_pref_said_uq
                        unique( preference, server_arch_id )
--                      using index tablespace [[64k_tbs]]
)
  ;

create index rhn_sp_ac_said_paid_pref
	on rhnServerPackageArchCompat(
		server_arch_id, package_arch_id, preference)
--	tablespace [[64k_tbs]]
  ;

create index rhn_sp_ac_paid_said_pref
	on rhnServerPackageArchCompat(
	 	package_arch_id, server_arch_id, preference)
--	tablespace [[64k_tbs]]
  ;


/*
create or replace trigger
rhn_sp_ac_mod_trig
before insert or update on rhnServerPackageArchCompat
for each row
begin
        :new.modified := sysdate;
end;
/
show errors
*/
--
-- Revision 1.2  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.1  2002/11/13 21:50:21  pjones
-- new arch system
--
