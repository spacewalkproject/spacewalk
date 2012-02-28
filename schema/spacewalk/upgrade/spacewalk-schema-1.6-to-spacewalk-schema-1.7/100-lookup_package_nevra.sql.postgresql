-- oracle equivalent source sha1 4f0e9a5a6bff289dca86b67b9a97926d6b18f87e

create or replace function
lookup_package_nevra(
        name_id_in in numeric,
        evr_id_in in numeric,
        package_arch_id_in in numeric,
        ignore_null_name in numeric default 0
) returns numeric
as
$$
declare
    nevra_id numeric;
begin
    if ignore_null_name = 1 and name_id_in is null then
        return null;
    end if;

    select id
      into nevra_id
      from rhnPackageNEVRA
     where name_id = name_id_in and
           evr_id = evr_id_in and
           (package_arch_id = package_arch_id_in or
            (package_arch_id is null and package_arch_id_in is null));

    if not found then
        nevra_id := nextval('rhn_pkgnevra_id_seq');
        begin
            perform pg_dblink_exec(
                'insert into rhnPackageNEVRA(id, name_id, evr_id, package_arch_id) values (' ||
                    nevra_id || ', ' ||
                    coalesce(quote_literal(name_id_in), 'NULL') || ', ' ||
                    coalesce(quote_literal(evr_id_in), 'NULL') || ', ' ||
                    coalesce(quote_literal(package_arch_id_in), 'NULL') || ')');
                nevra_id := currval('rhn_pkgnevra_id_seq');
        exception when unique_violation then
            select id
              into strict nevra_id
              from rhnPackageNEVRA
             where name_id = name_id_in and
                   evr_id = evr_id_in and
                   (package_arch_id = package_arch_id_in or
                    (package_arch_id is null and package_arch_id_in is null));
        end;
    end if;

    return nevra_id;
end;
$$ language plpgsql immutable;
