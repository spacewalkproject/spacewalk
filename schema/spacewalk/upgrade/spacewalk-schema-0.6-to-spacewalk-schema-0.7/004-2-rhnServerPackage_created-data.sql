begin
  loop
    update rhnServerPackage
       set created = sysdate
     where created is null and rownum <= 1000000;
  exit when sql%rowcount = 0;
    commit;
  end loop;
  commit;
end;
/

