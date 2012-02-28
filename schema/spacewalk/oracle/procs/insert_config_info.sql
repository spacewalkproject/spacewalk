-- Copyright (c) 2012 Red Hat, Inc.
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


create or replace function insert_config_info (
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
