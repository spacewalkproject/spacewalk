
insert into rhnPackageChecksum (package_id, checksum_type_id, checksum)
        (select p.id, md5.id, md5sum
           from test1064.rhnPackage p,
                (select id from rhnpackageChecksumType where label = 'md5') md5
        );

commit;

drop index rhn_package_md5_oid_uq;

alter table rhnPackage drop column md5sum;


