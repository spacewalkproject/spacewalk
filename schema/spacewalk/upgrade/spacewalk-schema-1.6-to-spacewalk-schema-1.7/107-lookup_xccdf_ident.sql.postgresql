-- oracle equivalent source sha1 32fa76082aad7e0505467f86e5ed19f5586debe0

create or replace function
lookup_xccdf_ident(system_in in varchar, identifier_in in varchar)
returns numeric
as
$$
declare
    xccdf_ident_id numeric;
    ident_sys_id numeric;
begin
    select id
      into ident_sys_id
      from rhnXccdfIdentSystem
     where system = system_in;
    if not found then
        ident_sys_id := nextval('rhn_xccdf_identsytem_id_seq');
        begin
            perform pg_dblink_exec(
                'insert into rhnXccdfIdentSystem (id, system) values (' ||
                ident_sys_id || ', ' || coalesce(quote_literal(system_in)) || ')');
        exception when unique_violation then
            select id
              into strict ident_sys_id
              from rhnXccdfIdentSystem
             where system = system_in;
        end;
    end if;

    select id
      into xccdf_ident_id
      from rhnXccdfIdent
     where identsystem_id = ident_sys_id and identifier = identifier_in;
    if not found then
        xccdf_ident_id := nextval('rhn_xccdf_ident_id_seq');
        begin
            perform pg_dblink_exec(
                'insert into rhnXccdfIdent (id, identsystem_id, identifier) values (' ||
                xccdf_ident_id || ', ' || ident_sys_id || ', ' ||
                coalesce(quote_literal( identifier_in)) || ')');
        exception when unique_violation then
            select id
              into strict xccdf_ident_id
              from rhnXccdfIdent
             where identsystem_id = ident_sys_id and identifier = identifier_in;
        end;
    end if;
    return xccdf_ident_id;
end;
$$ language plpgsql immutable;
