-- oracle equivalent source sha1 5219cb378d3877a851c71395c5dec6b5e672809d
-- retrieved from ./1241057068/d2f16725f65bddae85cd4782cd82e0c84c0a776d/schema/spacewalk/oracle/procs/does_user_have_role.sql
--
-- Copyright (c) 2008--2015 Red Hat, Inc.
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
does_user_have_role
(
        user_id_in in numeric,
        role_in in varchar
)
returns numeric
as $$
declare
        org_admin       numeric;
begin
        select  1
        into    org_admin
        from
                rhnUserGroupType        ugt,
                rhnUserGroup            ug,
                rhnUserGroupMembers     ugm
        where   1=1
                and ugm.user_id = user_id_in
                and ugm.user_group_id = ug.id
                and ugt.label = role_in
                and ugt.id = ug.group_type;

        if not found then 
		return 0;
	end if;
        return org_admin;
end; $$ language plpgsql;

