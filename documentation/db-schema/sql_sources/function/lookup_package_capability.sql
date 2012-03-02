-- created by Oraschemadoc Fri Mar  2 05:58:12 2012
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "SPACEWALK"."LOOKUP_PACKAGE_CAPABILITY" (name_in in varchar2, version_in in varchar2 default null)
return number
is
    name_id		number;
begin
    if version_in is null then
        select id
          into name_id
          from rhnPackageCapability
         where name = name_in and
               version is null;
    else
        select id
          into name_id
          from rhnPackageCapability
         where name = name_in and
               version = version_in;
	end if;
	return name_id;
exception when no_data_found then
    begin
        name_id := insert_package_capability(name_in, version_in);
    exception when dup_val_on_index then
        if version_in is null then
            select id
              into name_id
              from rhnPackageCapability
             where name = name_in and
                   version is null;
        else
            select id
              into name_id
              from rhnPackageCapability
             where name = name_in and
                   version = version_in;
	end if;

    end;
	return name_id;
end;
 
/
