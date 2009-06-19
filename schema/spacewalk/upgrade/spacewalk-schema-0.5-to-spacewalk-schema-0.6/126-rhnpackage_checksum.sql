
alter table rhnPackage rename column md5sum TO checksum;

alter table rhnPackage
  add checksum_id number
constraint rhn_pkg_checksum_id_fk
    references rhnPackageChecksum(id);

show errors

