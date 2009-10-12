insert into rhnChecksum (id, checksum_type_id, checksum)
        (select f.id, md5.id, f.md5sum
           from rhnFile f,
                (select id from rhnChecksumType where label = 'md5') md5
        );

update rhnFile f
   set checksum_id = (select id from rhnChecksum c where c.checksum = f.md5sum);

commit;
