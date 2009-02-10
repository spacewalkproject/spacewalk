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
rhnServerPackage
(
        server_id         numeric not null
                          constraint rhn_serverpackage_sid_fk
                          references rhnServer(id) 
                          on delete cascade,
        name_id           numeric not null
                          constraint rhn_serverpackage_nid_fk
                          references rhnPackageName(id),
        evr_id            numeric not null
                          constraint rhn_serverpackage_eid_fk
                          references rhnPackageEVR(id),
        package_arch_id   numeric not null
                          constraint rhn_serverpackage_paid_fk
                          references rhnPackageArch(id)
)
--	tablespace [[server_package_tablespace]]
  ;

create index rhn_sp_snep_idx on
        rhnServerPackage(server_id, name_id, evr_id, package_arch_id)
--        tablespace [[128m_tbs]]
        ;

create sequence rhn_server_package_id_seq;

--
-- Revision 1.13  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.12  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
-- Revision 1.11  2002/05/09 03:13:24  gafton
-- Fix storage clauses to have saner defaults for people at large...
--
-- Revision 1.10  2002/04/26 15:05:09  pjones
-- trim logs that have satconish words in them
--
