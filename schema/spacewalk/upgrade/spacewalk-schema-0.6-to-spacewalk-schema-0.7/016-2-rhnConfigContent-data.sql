insert into rhnChecksum (id, checksum_type_id, checksum)
        (select cc.id, md5.id, cc.md5sum
           from rhnConfigContent cc,
                (select id from rhnChecksumType where label = 'md5') md5
        );

update rhnConfigContent cc
   set checksum_id = (select c.id from rhnChecksum c where c.checksum = cc.md5sum);

commit;

