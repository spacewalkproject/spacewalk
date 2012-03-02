-- created by Oraschemadoc Fri Mar  2 05:58:11 2012
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "SPACEWALK"."INSERT_CONFIG_INFO" (
    username_in         in varchar2,
    groupname_in        in varchar2,
    filemode_in         in number,
    selinux_ctx_in      in varchar2,
    symlink_target_id   in number
) return number
is
    pragma autonomous_transaction;
    v_id    number;
begin
    select rhn_confinfo_id_seq.nextval
      into v_id
      from dual;
    insert into rhnConfigInfo (id, username, groupname, filemode, selinux_ctx, symlink_target_filename_id)
    values (v_id, username_in, groupname_in, filemode_in, selinux_ctx_in, symlink_target_id);
    commit;
    return v_id;
end;
 
/
