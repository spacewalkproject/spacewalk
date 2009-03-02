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
-- triggers for rhnUserGroupMembers WRT email notification
--
-- EXCLUDE: all
-- XXX devel code, back off


create or replace function rhn_ug_member_email_mod_trig_fun() returns trigger
as
$$
begin
        perform rhn_email.add_for_user(new.user_id);

        return new;
end;
$$ language plpgsql;


create trigger
rhn_ug_member_email_mod_trig
before insert or update on rhnUserGroupMembers
for each row
execute procedure rhn_ug_member_email_mod_trig_fun();


-- this will catch rhnUserGroup deletions as well
create or replace function rhn_ug_member_email_del_trig_fun() returns trigger
as
$$
begin
        perform rhn_email.add_for_user(old.user_id);

        return new;
end;
$$ language plpgsql;



create trigger
rhn_ug_member_email_del_trig
after delete on rhnUserGroupMembers
for each row
execute procedure rhn_ug_member_email_del_trig_fun();




