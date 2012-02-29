-- oracle equivalent source sha1 6750c771494ff37bb3d153ccd8ef433020c075d8

create or replace function
lookup_source_name(name_in in varchar)
returns numeric
as
$$
declare
    source_id   numeric;
begin
    select id
      into source_id
      from rhnSourceRPM
     where name = name_in;

    if not found then
        source_id := nextval('rhn_sourcerpm_id_seq');
        begin
            perform pg_dblink_exec(
                'insert into rhnSourceRPM(id, name) values (' ||
                source_id || ', ' || coalesce(quote_literal(name_in), 'NULL') || ')');
        exception when unique_violation then
            select id
              into strict source_id
              from rhnSourceRPM
             where name = name_in;
        end;
    end if;

    return source_id;
end;
$$
language plpgsql immutable;
