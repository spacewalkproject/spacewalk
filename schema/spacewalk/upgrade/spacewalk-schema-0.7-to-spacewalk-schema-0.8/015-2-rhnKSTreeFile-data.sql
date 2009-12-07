update rhnKSTreeFile k
   set checksum_id = lookup_checksum('md5', md5sum);

commit;

