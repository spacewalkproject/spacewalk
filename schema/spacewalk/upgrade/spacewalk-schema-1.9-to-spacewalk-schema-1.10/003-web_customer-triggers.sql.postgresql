-- oracle equivalent source sha1 8a2376491cf7605f5e6657876299569d2a0961bb
--
-- Copyright (c) 2013 Red Hat, Inc.
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

create or replace function web_customer_insert_trig_fun() returns trigger
as
$$
begin
        insert into rhnOrgConfiguration (org_id) values (new.id);

        return new;
end;
$$
language plpgsql;


create trigger
web_customer_insert_trig
after insert on web_customer
for each row
execute procedure web_customer_insert_trig_fun();
