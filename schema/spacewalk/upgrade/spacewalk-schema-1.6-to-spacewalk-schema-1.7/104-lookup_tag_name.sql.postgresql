-- oracle equivalent source sha1 7ee8c6969cbd24fb3e30636737486f2e470d02ab

create or replace function
lookup_tag_name(name_in in varchar)
returns numeric
as
$$
declare
    name_id numeric;
begin
    select id
      into name_id
      from rhnTagName
     where name = name_in;

    if not found then
        name_id := nextval('rhn_tagname_id_seq');
        begin
            perform pg_dblink_exec(
                'insert into rhnTagName(id, name) values (' ||
                name_id || ', ' || coalesce(quote_literal(name_in), 'NULL') || ')');
        exception when unique_violation then
            select id
              into strict name_id
              from rhnTagName
             where name = name_in;
        end;
    end if;

    return name_id;
end;
$$ language plpgsql immutable;
