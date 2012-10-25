begin
    for rec in (
        select id as old_id,
               min(id) over ( partition by rtrim(translate(name, chr(10), ' ')) ) as new_id
          from rhnPackageGroup
    ) loop
        if rec.new_id < rec.old_id then

            update rhnPackage
               set package_group = rec.new_id
             where package_group = rec.old_id;

            update rhnPackageSource
               set package_group = rec.new_id
             where package_group = rec.old_id;

            delete
              from rhnPackageGroup
             where id = rec.old_id;
        end if;
    end loop;

    update rhnPackageGroup
       set name = rtrim(translate(name, chr(10), ' '))
     where name <> rtrim(translate(name, chr(10), ' '));
end;
/

commit;
