-- oracle equivalent source sha1 3c24c29e86ab45cf77a411446eb99b2452437942
-- retrieved from ./1239053651/49a123cbe214299834e6ce97b10046d8d9c7642a/schema/spacewalk/oracle/triggers/rhnPrivateChannelFamily.sql
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

create or replace function rhn_privcf_mod_trig_fun() returns trigger
as
$$
begin
    new.modified := current_timestamp;

    return new;
end;
$$
language plpgsql;


create trigger
rhn_privcf_mod_trig
before insert or update on rhnPrivateChannelFamily
for each row
execute procedure rhn_privcf_mod_trig_fun();



