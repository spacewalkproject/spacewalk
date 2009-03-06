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
create table rhnSolarisPatchPackages (
   patch_id             numeric
                        not null
                        constraint rhn_solaris_pp_fk references rhnPackage(id)
                        on delete cascade,
   package_nevra_id     numeric
                        not null
                        constraint rhn_solaris_pnid_fk references rhnPackageNEVRA(id)
                        on delete cascade
)
--   tablespace [[8m_data_tbs]]
  ;

create index rhn_solaris_pp_pid_pnid_idx
on rhnSolarisPatchPackages (patch_id, package_nevra_id)
  ;

create index rhn_solaris_pp_pnid_pid_idx
on rhnSolarisPatchPackages (package_nevra_id, patch_id)
  ;


--
