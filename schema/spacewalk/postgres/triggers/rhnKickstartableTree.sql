-- oracle equivalent source sha1 c45cd255b9c4c2b269de03d887589658321e4144
-- retrieved from ./1241132947/9984c41fb98d15becf3c29432c19cd7a266dece4/schema/spacewalk/oracle/triggers/rhnKickstartableTree.sql
--
-- Copyright (c) 2008-2010 Red Hat, Inc.
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

create or replace function rhn_kstree_mod_trig_fun() returns trigger as
$$
begin
        if tg_op='UPDATE' then
                if new.cobbler_id = old.cobbler_id
                        and new.cobbler_xen_id = old.cobbler_xen_id
                        and new.last_modified = old.last_modified
                        or new.last_modified is null
                        then
                        new.last_modified := current_timestamp;
                end if;
        elseif tg_op='INSERT' and new.last_modified is null then
                new.last_modified := current_timestamp;
        end if;

        new.modified := current_timestamp;

        return new;
end;
$$ language plpgsql;

create trigger
rhn_kstree_mod_trig
before insert or update on rhnKickstartableTree
for each row
execute procedure rhn_kstree_mod_trig_fun();

