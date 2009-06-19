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
-- The types of checksum associated with a package... md5sum, sha1, sha256...?

create table
rhnPackageChecksum
(
        id              number
                        constraint rhn_pkgchecksum_type_id_nn not null,
        name           varchar2(128)
                        constraint rhn_pkgchecksum_type_name_nn not null
)
        enable row movement
  ;

create sequence rhn_package_checksum_id_seq start with 100;       

create index rhn_pkg_checksum_id_n_idx
        on rhnPackageChecksum (id, name )
        tablespace [[64k_tbs]]
  ;

alter table rhnPackageChecksum add constraint rhn_pkg_checksum_id_pk primary key (id);
alter table rhnPackageChecksum add constraint rhn_pkg_checksum_name_uq unique ( name );

--
-- Revision 1.1  2009/06/19 00:37:16  pkilambi
-- 
