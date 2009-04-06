create or replace function
lookup_config_info_autonomous
(
    username_in     in varchar,
    groupname_in    in varchar,
    filemode_in     in varchar
)
returns numeric
as
$$
declare
    r numeric;
    v_id    numeric;
    lookup_cursor cursor  for
        select id
          from rhnConfigInfo
         where username = username_in
           and groupname = groupname_in
           and filemode = filemode_in;
begin
    loop
        fetch lookup_cursor into r;
            return r;
    end loop;
    -- If we got here, we don't have the id
    select nextval('rhn_confinfo_id_seq') into v_id;
    insert into rhnConfigInfo
        (id, username, groupname, filemode)
    values (v_id, username_in, groupname_in, filemode_in);
    return v_id;
end;
$$ language plpgsql stable;
