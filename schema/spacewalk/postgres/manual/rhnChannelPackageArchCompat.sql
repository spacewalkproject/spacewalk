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
rhnChannelPackageArchCompat
(
        channel_arch_id	numeric
                        not null
                        constraint rhn_cp_ac_caid_fk 
			references rhnChannelArch(id),
	package_arch_id	numeric
			not null
			constraint rhn_cp_ac_paid_fk
			references rhnPackageArch(id),
	created		date default(current_date)
			not null,
	modified	date default(current_date)
			not null,
                        constraint rhn_cp_ac_caid_paid_uq 
                        unique ( channel_arch_id, package_arch_id )
)
  ;

create index rhn_cp_ac_caid_paid
	on rhnChannelPackageArchCompat(
		channel_arch_id, package_arch_id)
--	tablespace [[64k_tbs]]
  ;

create index rhn_cp_ac_paid_caid
	on rhnChannelPackageArchCompat(
	 	package_arch_id, channel_arch_id)
--	tablespace [[64k_tbs]]
  ;

/*
create or replace trigger
rhn_cp_ac_mod_trig
before insert or update on rhnChannelPackageArchCompat
for each row
begin
        :new.modified := sysdate;
end;
/
show errors
*/
--
-- Revision 1.3  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.2  2002/11/14 17:05:19  misa
-- Drop preference, we don't need it here
--
-- Revision 1.1  2002/11/13 21:50:21  pjones
-- new arch system
--
