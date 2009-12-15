begin
  loop
      update rhnPackageChangelog
         set id = rhn_pkg_cl_id_seq.nextval
       where id is null and rownum <= 1000000;
  exit when sql%rowcount = 0;
      commit;
  end loop;
  commit;
end;
/

