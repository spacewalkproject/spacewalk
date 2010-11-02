-- created by Oraschemadoc Tue Nov  2 08:33:19 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "SPACEWALK"."LOOKUP_CONFIG_INFO" (
    username_in     in varchar2,
    groupname_in    in varchar2,
    filemode_in     in varchar2,
    selinux_ctx_in  in varchar2,
    symlink_target_id in number
) return number
deterministic
is
    pragma autonomous_transaction;
    v_id    number;
    cursor lookup_cursor is
        select id
          from rhnConfigInfo
         where 1=1
           and nvl(username, ' ') = nvl(username_in, ' ')
           and nvl(groupname,' ') = nvl(groupname_in, ' ')
           and nvl(filemode, -1) = nvl(filemode_in, -1)
           and nvl(selinux_ctx, ' ') = nvl(selinux_ctx_in, ' ')
           and nvl(symlink_target_filename_id, -1) = nvl(symlink_target_id, -1)
        ;
begin
    for r in lookup_cursor loop
        return r.id;
    end loop;
    -- If we got here, we don't have the id
    select rhn_confinfo_id_seq.nextval
      into v_id
      from dual;
    insert into rhnConfigInfo (id, username, groupname, filemode, selinux_ctx, symlink_target_filename_id)
    values (v_id, username_in, groupname_in, filemode_in, selinux_ctx_in, symlink_target_id);
    commit;
    return v_id;
end lookup_config_info;
 
/
