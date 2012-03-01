-- oracle equivalent source sha1 cbf75718e61e14bc1e042d56b023ed99ff74ff1c

create or replace function
lookup_xccdf_profile(identifier_in in varchar, title_in in varchar)
returns numeric
as
$$
declare
    profile_id numeric;
begin
    select id
      into profile_id
      from rhnXccdfProfile
     where identifier = identifier_in and title = title_in;

    if not found then
        profile_id := nextval('rhn_xccdf_profile_id_seq');
        begin
            perform pg_dblink_exec(
                'insert into rhnXccdfProfile (id, identifier, title) values (' ||
                profile_id || ', ' ||
                coalesce(quote_literal(identifier_in), 'NULL') || ', ' ||
                coalesce(quote_literal(title_in), 'NULL') || ')' );
        exception when unique_violation then
            select id
              into profile_id
              from rhnXccdfProfile
             where identifier = identifier_in and title = title_in;
        end;
    end if;

    return profile_id;
end;
$$ language plpgsql;
