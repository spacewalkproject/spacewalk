-- created by Oraschemadoc Mon Aug 31 10:54:41 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "MIM1"."LOOKUP_CONFIG_INFO" (
    username_in     in varchar2,
    groupname_in    in varchar2,
    filemode_in     in varchar2,
    selinux_ctx_in  in varchar2
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
           and filemode = filemode_in
           and nvl(selinux_ctx, ' ') = nvl(selinux_ctx_in, ' ');
begin
    for r in lookup_cursor loop
        return r.id;
    end loop;
    -- If we got here, we don't have the id
    select rhn_confinfo_id_seq.nextval
      into v_id
      from dual;
    insert into rhnConfigInfo (id, username, groupname, filemode, selinux_ctx)
    values (v_id, username_in, groupname_in, filemode_in, selinux_ctx_in);
    commit;
    return v_id;
end lookup_config_info;
 
/
