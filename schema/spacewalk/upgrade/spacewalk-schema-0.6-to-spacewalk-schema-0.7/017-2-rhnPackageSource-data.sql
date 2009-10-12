insert into rhnChecksum (id, checksum_type_id, checksum)
        (select s.id, md5.id, s.sigmd5
           from rhnPackageSource s,
                (select id from rhnChecksumType where label = 'md5') md5
        );

update rhnPackageSource s
   set sigchecksum_id = (select c.id from rhnChecksum c where c.checksum = s.sigmd5);

commit;

insert into rhnChecksum (id, checksum_type_id, checksum)
        (select s.id, md5.id, s.md5sum
           from rhnPackageSource s,
                (select id from rhnChecksumType where label = 'md5') md5
        );

update rhnPackageSource s
   set checksum_id = (select c.id from rhnChecksum c where c.checksum = s.md5sum);

commit;
