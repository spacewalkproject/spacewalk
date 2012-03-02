-- oracle equivalent source sha1 c2038f056ed1f3b7edac1d1a75ca21f06c7a620b
-- retrieved from ./1241057068/d2f16725f65bddae85cd4782cd82e0c84c0a776d/schema/spacewalk/oracle/triggers/web_contact.sql
--
-- Copyright (c) 2008--2012 Red Hat, Inc.
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

create or replace function web_contact_ins_trig_fun() returns trigger
as
$$
begin
        new.modified := current_timestamp;
        new.login_uc := UPPER(new.login);

        return new;
end;
$$
language plpgsql;

create trigger
web_contact_ins_trig
before insert on web_contact
for each row
execute procedure web_contact_ins_trig_fun();


create or replace function web_contact_upd_trig_fun() returns trigger
as
$$
begin
        new.modified := current_timestamp;
        new.login_uc := UPPER(new.login);
        IF new.password IS DISTINCT FROM old.password THEN
                new.old_password := old.password;
        END IF;

        return new;
end;
$$
language plpgsql;

create trigger
web_contact_upd_trig
before update on web_contact
for each row
execute procedure web_contact_upd_trig_fun();
