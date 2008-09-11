--
-- $Id$
--

create or replace function
lookup_config_info (
    username_in     in varchar2,
    groupname_in    in varchar2,
    filemode_in     in varchar2
) return number
deterministic
is
    pragma autonomous_transaction;
    v_id    number;
    cursor lookup_cursor is
        select id
          from rhnConfigInfo
         where 1=1
           and username = username_in
           and groupname = groupname_in
           and filemode = filemode_in;
begin
    for r in lookup_cursor loop
        return r.id;
    end loop;
    -- If we got here, we don't have the id
    select rhn_confinfo_id_seq.nextval
      into v_id
      from dual;
    insert into rhnConfigInfo (id, username, groupname, filemode)
    values (v_id, username_in, groupname_in, filemode_in);
    commit;
    return v_id;
end lookup_config_info;
/
show errors

-- $Log$
-- Revision 1.1  2003/11/10 15:36:27  pjones
-- bugzilla: 109083 -- lookup for rhnConfigInfo
--
-- Revision 1.1  2003/10/15 18:30:34  misa
-- bugzilla: 106911 Added a lookup function for rhnConfigFileInfo
--
--
