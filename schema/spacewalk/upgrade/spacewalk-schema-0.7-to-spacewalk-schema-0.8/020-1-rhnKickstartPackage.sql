declare
  i number;
begin
  for rec in (
    select kickstart_id kid
    from rhnKickstartPackage
    where position = 0
    group by kickstart_id
    having count(*) > 1
  ) loop
    i := 0;
    for erec in (
      select rhnKickstartPackage.rowid rid
      from rhnKickstartPackage, rhnPackageName
      where rhnKickstartPackage.package_name_id = rhnPackageName.id
        and rhnKickstartPackage.kickstart_id = rec.kid
      order by rhnKickstartPackage.position, rhnPackageName.name
    ) loop
      update rhnKickstartPackage
      set position = i
      where rhnKickstartPackage.rowid = erec.rid;
      i := i + 1;
    end loop;
  end loop;
end;
/

commit;
