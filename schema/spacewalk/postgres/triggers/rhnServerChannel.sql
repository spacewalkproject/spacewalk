-- oracle equivalent source sha1 7a120275ba756bbf664049a8cc72e23a772b8655

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


create or replace function rhn_server_channel_mod_trig_fun() returns trigger
as
$$
begin
        new.modified := current_timestamp;

	return new;
end;
$$
language plpgsql;


create trigger
rhn_server_channel_mod_trig
before insert or update on rhnServerChannel
for each row
execute procedure rhn_server_channel_mod_trig_fun();




