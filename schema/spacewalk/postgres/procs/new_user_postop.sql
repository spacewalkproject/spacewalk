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
create or replace function new_user_postop
(
    user_id_in IN numeric
)
returns void
as $$
declare
    org_id_val          numeric;
    admin_group_val     numeric;
begin
    select org_id into strict org_id_val
      from web_contact
     where id = user_id_in;

    select id into strict admin_group_val
      from rhnUserGroup
     where org_id = org_id_val
       and group_type = (
                select  id
                from    rhnUserGroupType
                where   label = 'org_admin'
           );

    insert into rhnUserGroupMembers
        (user_group_id, user_id)
    values
        (admin_group_val, user_id_in);

    insert into rhnUserInfo
        (user_id)
    values
        (user_id_in);
end;
$$ language plpgsql;

-- TODO: Convert the below anonymous block to a plpgsql function
/* NOT SURE WHAT THIS IS SUPPOSED TO BE
declare
    CURSOR user_cursor
    is
    select wc.id
      from web_contact wc
     where not exists (select 1
                         from rhnUserGroupMembers
                        where user_id = wc.id);
   i NUMBER;
begin
    i := 0;
    for user_rec in user_cursor
    loop
        new_user_postop(user_rec.id);

        i := i + 1;
        if mod(i, 500) = 0
        then
            commit;
        end if;
    end loop;

    commit;
end;
*/
