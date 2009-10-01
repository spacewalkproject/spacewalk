
insert into rhnPackageChecksum (package_id, checksum_type_id, checksum)
        values ( select id, (select id from rhnChecksumType where label = 'md5'), md5sum from rhnPackage );

commit;

drop index rhn_package_md5_oid_uq;

alter table rhnPackage drop column md5sum;


