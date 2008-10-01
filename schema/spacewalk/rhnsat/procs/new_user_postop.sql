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

create or replace procedure
new_user_postop
(
    user_id_in IN number
)
is
    org_id_val		number;
    admin_group_val	number;
begin
    select org_id into org_id_val
      from web_contact
     where id = user_id_in;

    select id into admin_group_val
      from rhnUserGroup
     where org_id = org_id_val
       and group_type = (
		select	id
		from	rhnUserGroupType
		where	label = 'org_admin'
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
/
show errors

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
/
show errors

--
-- Revision 1.5  2002/05/13 22:53:38  pjones
-- cvs id/log
-- some (note enough) readability fixes
--
-- Revision 1.4  2002/05/09 06:45:18  gafton
-- haestaetics
--
-- Revision 1.3  2002/05/09 06:43:31  gafton
-- move the grants to grants.sql so we can import this one for satellite
-- functionality. Do we need this fucntion for the satellite?
--
