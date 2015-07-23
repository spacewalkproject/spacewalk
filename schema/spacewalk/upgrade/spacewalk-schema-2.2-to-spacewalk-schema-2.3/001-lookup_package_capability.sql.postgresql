-- oracle equivalent source sha1 b14267384bc104605623a41b755e68e0103b5aa8

-- Note: intentionally not thread-safe! You must aquire a write lock on the
-- rhnPackageCapability tabel if you are going to use this proc!
create or replace function lookup_package_capability_fast(name_in in varchar, version_in in varchar default null)
returns numeric
as
$$
declare
    name_id numeric;
begin
    if version_in is null then
        select id
          into name_id
          from rhnpackagecapability
         where name = name_in and
               version is null;
    else
        select id
          into name_id
          from rhnpackagecapability
         where name = name_in and
               version = version_in;
    end if;

    if not found then
        name_id = nextval('rhn_pkg_capability_id_seq');
        insert into rhnPackageCapability(id, name, version) values (
               name_id, name_in, version_in);
    end if;

    return name_id;
end;
$$
language plpgsql;
