insert into rhnChecksum (id, checksum_type_id, checksum)
        (select p.id, md5.id, p.md5sum
           from rhnPackageFile p,
                (select id from rhnChecksumType where label = 'md5') md5
        );

update rhnPackageFile p
   set checksum_id = (select c.id from rhnChecksum c where c.checksum = p.md5sum);

commit;

