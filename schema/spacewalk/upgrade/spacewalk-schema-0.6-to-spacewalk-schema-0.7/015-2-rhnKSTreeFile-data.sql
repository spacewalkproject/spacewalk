insert into rhnChecksum (id, checksum_type_id, checksum)
        (select k.id, md5.id, k.md5sum
           from rhnKSTreeFile k,
                (select id from rhnChecksumType where label = 'md5') md5
        );

update rhnKSTreeFile k
   set checksum_id = (select c.id from rhnChecksum c where c.checksum = k.md5sum);

commit;

