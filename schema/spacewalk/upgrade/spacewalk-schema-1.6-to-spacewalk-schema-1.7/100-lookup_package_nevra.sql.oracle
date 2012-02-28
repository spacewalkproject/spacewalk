create or replace function insert_package_nevra(
    name_id_in in varchar2,
    evr_id_in in varchar2,
    package_arch_id_in in varchar2
) return number
is
    pragma autonomous_transaction;
    nevra_id number;
begin
    insert into rhnPackageNEVRA(id, name_id, evr_id, package_arch_id) values
        (rhn_pkgnevra_id_seq.nextval,
         name_id_in,
         evr_id_in,
         package_arch_id_in) returning id into nevra_id;
    commit;
    return nevra_id;
end;
/
show errors

create or replace function
lookup_package_nevra(
	name_id_in in varchar2,
	evr_id_in in varchar2,
	package_arch_id_in in varchar2,
	ignore_null_name in number := 0
) return number
deterministic
is
	nevra_id number;
begin
    if ignore_null_name = 1 and name_id_in is null then
        return null;
    end if;

    select id
      into nevra_id
      from rhnPackageNEVRA
     where 1=1 and
           name_id = name_id_in and
           evr_id = evr_id_in and
           (package_arch_id = package_arch_id_in or
            (package_arch_id is null and package_arch_id_in is null));

    return nevra_id;
exception when no_data_found then
    begin
        nevra_id := insert_package_nevra(name_id_in, evr_id_in, package_arch_id_in);
    exception when dup_val_on_index then
        select id
          into nevra_id
          from rhnPackageNEVRA
         where 1=1 and
               name_id = name_id_in and
               evr_id = evr_id_in and
               (package_arch_id = package_arch_id_in or
                (package_arch_id is null and package_arch_id_in is null));
    end;
    return nevra_id;
end;
/
show errors
