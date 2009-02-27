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
-- triggers for rhnServerGroupMembers WRT email notification
--
-- EXCLUDE: all
-- XXX devel code, back off

create or replace function rhn_sg_member_email_mod_trig_fun() returns trigger
as
$$
begin
        perform rhn_email.add_for_server(new.server_id);

        return new;
end;
$$
language plpgsql;




create trigger
rhn_sg_member_email_mod_trig
before insert or update on rhnServerGroupMembers
for each row
execute procedure rhn_sg_member_email_mod_trig_fun();



-- this will catch rhnServerGroup deletions and server deletions
create or replace function rhn_sg_member_email_del_trig_fun() returns trigger as
$$
begin
        perform rhn_email.add_for_server(old.server_id);
        return new;
end;
$$
language plpgsql;


create or replace trigger
rhn_sg_member_email_del_trig
after delete on rhnServerGroupMembers
for each row
execute procedure rhn_sg_member_email_del_trig_fun();



