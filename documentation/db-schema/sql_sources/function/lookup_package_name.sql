-- created by Oraschemadoc Fri Mar  2 05:58:12 2012
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "SPACEWALK"."LOOKUP_PACKAGE_NAME" (name_in in varchar2, ignore_null in number := 0)
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
