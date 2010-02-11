update rhnChannel
   set checksum_type_id = (select id from rhnChecksumType where label = 'sha1')
 where checksum_type_id is null
   and (label like 'rhel-%-server-5'
     or label like 'rhel-%-client-5'
     or parent_channel in (select id from rhnChannel
                                    where label like 'rhel-%-server-5'
                                       or label like 'rhel-%-client-5'));
