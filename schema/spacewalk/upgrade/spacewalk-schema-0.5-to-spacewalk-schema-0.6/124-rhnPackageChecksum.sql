-- The types of checksum associated with a package... md5sum, sha1, sha256...?

create table
rhnPackageChecksum
(
        package_id      number
                        constraint rhn_pkgcs_nn not null
                        constraint rhn_pkgcs_id_fk
                                references rhnPackage(id),
        md5sum          varchar2(64)
                        constraint rhn_pkgcs_md5_nn not null,
        sha256          varchar2(128)
                        constraint rhn_pkgcs_sha256_nn not null
)
        enable row movement
  ;

create index rhn_pkg_id_n_idx
        on rhnPackageChecksum (package_id, md5sum, sha256)
        tablespace [[64k_tbs]];

alter table rhnPackageChecksum add constraint rhn_pkgcs_id_pk primary key ( package_id);
alter table rhnPackageChecksum add constraint rhn_pkgcs_id_uq unique ( package_id, md5sum, sha256 );

--
-- Revision 1.1  2009/06/19 00:37:16  pkilambi
-- 
