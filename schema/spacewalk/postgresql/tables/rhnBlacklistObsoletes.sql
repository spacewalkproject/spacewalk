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

create table rhnBlacklistObsoletes
(
	name_id			numeric
				not null
				constraint rhn_bl_obs_nid_fk
					references rhnPackageName(id),
	evr_id			numeric
				not null
				constraint rhn_bl_obs_eid_fk
					references rhnPackageEVR(id),
	package_arch_id		numeric
				not null
				constraint rhn_bl_obs_paid_fk
					references rhnPackageArch(id),
	ignore_name_id		numeric
				not null
				constraint rhn_bl_obs_inid_fk
					references rhnPackageName(id),
	created			date default(current_date)
				not null,
	modified		date default(current_date)
				not null,
                                constraint rhn_bl_obs_nepi_uq
                                unique( name_id, evr_id, package_arch_id, ignore_name_id )
)
  ;

create index rhn_bl_obs_nepi_idx
	on rhnBlacklistObsoletes ( name_id, evr_id, package_arch_id, 
		ignore_name_id )
--	tablespace [[64k_tbs]]
  ;

/*
create or replace trigger
rhn_bl_obs_mod_trig
before insert or update on rhnBlacklistObsoletes
for each row
begin
	:new.modified := sysdate;
end;
/
show errors
*/
--
-- Revision 1.5  2003/02/10 22:35:07  misa
-- bugzilla: 83597 Refine the trigger
--
-- Revision 1.4  2003/02/10 22:17:52  misa
-- bugzilla: 83597 Trigger to upate last_modified for all channels upon table changes
--
-- Revision 1.3  2003/02/07 17:46:46  pjones
-- rework rhnBlacklistObsoletes
--
