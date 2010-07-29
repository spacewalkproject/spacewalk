--
-- Copyright (c) 2008 Red Hat, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
-- 
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation. 
--
--
--
--

create or replace function
lookup_config_info (
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
show errors

--
-- Revision 1.1  2003/11/10 15:36:27  pjones
-- bugzilla: 109083 -- lookup for rhnConfigInfo
--
-- Revision 1.1  2003/10/15 18:30:34  misa
-- bugzilla: 106911 Added a lookup function for rhnConfigFileInfo
--
--
