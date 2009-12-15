update rhnPackageSource s
   set sigchecksum_id = lookup_checksum('md5', sigmd5);

commit;

update rhnPackageSource s
   set checksum_id = lookup_checksum('md5', md5sum);

commit;
