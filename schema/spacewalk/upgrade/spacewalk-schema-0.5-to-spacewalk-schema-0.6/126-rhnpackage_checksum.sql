
drop index rhn_package_md5_oid_uq;
alter table rhnPackage drop column md5sum;

show errors

