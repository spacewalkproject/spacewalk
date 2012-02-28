create or replace function insert_package_capability(name_in in varchar2, version_in in varchar2 default null)
return number
is
    pragma autonomous_transaction;
    name_id number;
begin
    insert into rhnPackageCapability (id, name, version)
        values (rhn_pkg_capability_id_seq.nextval, name_in, version_in) returning id into name_id;
    commit;
    return name_id;
end;
/

create or replace function
lookup_package_capability(name_in in varchar2, version_in in varchar2 default null)
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
show errors
