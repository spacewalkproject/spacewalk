declare
 md5_id number;
 min_pid number;
 max_pid number;
 lmin number;
 lmax number;
begin
  select id
    into md5_id
    from rhnChecksumType
   where label = 'md5';

  select min(package_id), max(package_id)
    into min_pid, max_pid
    from rhnPackageFile;

  lmin := min_pid;
  lmax := lmin + 99999;
  while lmin < max_pid loop
    insert into rhnChecksum (id, checksum_type_id, checksum)
           (select rhnChecksum_seq.nextval, md5_id, csum
              from (select distinct md5 as csum
                      from rhnPackageFile
                     where package_id between lmin and lmax
                     minus
                    select checksum as csum
                      from rhnChecksum
                     where checksum_type_id = md5_id));
    commit;
    update rhnPackageFile p
       set checksum_id = (select id
                            from rhnChecksum c
                           where checksum_type_id = md5_id
                             and p.md5 =  c.checksum)
     where package_id between lmin and lmax;
    commit;
    lmin := lmax + 1;
    lmax := lmin + 99999;
  end loop;
end;
/

