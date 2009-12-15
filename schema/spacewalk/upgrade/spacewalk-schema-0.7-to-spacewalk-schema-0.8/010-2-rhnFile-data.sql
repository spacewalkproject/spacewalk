update rhnFile f
   set checksum_id = lookup_checksum('md5', md5sum);

commit;
