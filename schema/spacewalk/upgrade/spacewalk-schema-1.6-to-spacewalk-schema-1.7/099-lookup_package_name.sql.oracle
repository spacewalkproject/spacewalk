create or replace function insert_package_name(name_in in varchar2)
return number
is
    pragma  autonomous_transaction;
    name_id number;
begin
    insert into rhnPackageName(id, name)
    values (rhn_pkg_name_seq.nextval, name_in) returning id into name_id;
    commit;
    return name_id;
end;
/

create or replace function
lookup_package_name(name_in in varchar2, ignore_null in number := 0)
return number
is
    name_id		number;
begin
    if ignore_null = 1 and name_in is null then
        return null;
    end if;

    select id
      into name_id
      from rhnPackageName 
     where name = name_in;

    return name_id;
exception when no_data_found then
    begin
        name_id := insert_package_name(name_in);
    exception when dup_val_on_index then
        select id
          into name_id
          from rhnPackageName 
         where name = name_in;
    end;
    return name_id;
end;
/
show errors
