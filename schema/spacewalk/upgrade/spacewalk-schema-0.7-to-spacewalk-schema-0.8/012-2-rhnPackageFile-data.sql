declare
 md5_id number;
 min_pid number;
 max_pid number;
 lmin number;
 lmax number;
 incr number;
begin
  select id
    into md5_id
    from rhnChecksumType
   where label = 'md5';

  select min(package_id)
    into min_pid
    from rhnPackageFile;
  select max(package_id)
    into max_pid
    from rhnPackageFile;

  incr := 80000;
  lmin := min_pid;
  lmax := lmin + incr - 1;
  while lmin < max_pid loop
    insert into rhnChecksum (id, checksum_type_id, checksum)
           (select rhnChecksum_seq.nextval, md5_id, csum
              from (select /*+ index(p rhn_package_file_pid_cid_uq) */
                           distinct md5 as csum
                      from rhnPackageFile p
                     where package_id between lmin and lmax
                       and md5 is not null
                       and not exists (select /*+ index(c rhnChecksum_chsum_uq) */ 1
                                         from rhnChecksum c
                                        where p.md5 = c.checksum
                                          and c.checksum_type_id = md5_id)
                   )
           );
    commit;
    lmin := lmax + 1;
    lmax := lmin + incr -1;
  end loop;

  incr := 10000;
  lmin := min_pid;
  lmax := lmin + incr - 1;
  while lmin < max_pid loop
    update /*+ index(p rhn_package_file_pid_cid_uq) */ rhnPackageFile p
       set checksum_id = (select id
                            from rhnChecksum c
                           where checksum_type_id = md5_id
                             and p.md5 =  c.checksum)
     where package_id between lmin and lmax
       and md5 is not null;
    commit;
    lmin := lmax + 1;
    lmax := lmin + incr -1;
  end loop;
end;
/

