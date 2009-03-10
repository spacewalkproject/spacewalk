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

create table
rhnPackageConflicts
(
        package_id      numeric
                        not null
                        constraint rhn_pkg_conflicts_package_fk
                        references rhnPackage(id)
                        on delete cascade,
        capability_id   numeric
                        not null
                        constraint rhn_pkg_conflicts_cap_fk
                        references rhnPackageCapability(id),
        sense           numeric default(0) -- comes from RPMSENSE_*
                        not null,
        created         date default (current_date)
                        not null,
        modified        date default (current_date)
                        not null,
                        constraint rhn_pkg_confl_pid_cid_s_uq
                        unique(package_id, capability_id, sense)
--                      using index tablespace [[64k_tbs]]
)
  ;

create index rhn_pkg_conflicts_cid_idx
	on rhnPackageConflicts(capability_id)
--      tablespace [[64k_tbs]]
	;

/*
create or replace trigger
rhn_pkg_conflicts_mod_trig
before insert or update on rhnPackageConflicts
for each row
begin
        :new.modified := sysdate;
end;
/
show errors
*/

-- create or replace trigger
-- rhn_pkg_csense_map_trig
-- after insert or update on rhnPackageConflicts
-- for each row
-- begin
--	buildPackageSenseMap(:new.sense);
-- end;
-- /
-- show errors

--
--
-- Revision 1.9  2004/12/07 20:18:56  cturner
-- bugzilla: 142156, simplify the triggers
--
-- Revision 1.8  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.7  2003/01/24 16:42:23  pjones
-- last_modified on rhnPackage and rhnPackageSource
--
-- Revision 1.6  2002/05/09 05:23:29  gafton
-- new style comments
--
-- Revision 1.5  2002/04/13 21:29:19  misa
-- Commented out everything related to bitwiseAnd
--
-- Revision 1.4  2002/03/19 22:41:31  pjones
-- index tablespace names to match current dev/qa/prod (rhn_ind_xxx)
--
-- Revision 1.3  2002/02/21 16:27:19  pjones
-- rhn_ind -> [[64k_tbs]]
-- rhn_ind_02 -> [[server_package_index_tablespace]]
-- rhn_tbs_02 -> [[server_package_tablespace]]
--
-- for perl-Satcon so satellite can be created more directly.
--
-- Revision 1.2  2001/09/24 16:33:36  pjones
-- index renames
--
-- Revision 1.1  2001/09/13 18:05:29  pjones
-- new provides/requires/conflicts/obsoletes...
--
