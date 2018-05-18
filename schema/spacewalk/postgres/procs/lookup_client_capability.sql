-- oracle equivalent source sha1 2791c71c582fbcee45ecfcecfefba45b1a839631
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

create or replace function
lookup_client_capability(name_in in varchar)
returns numeric
as $$
declare
    cap_name_id     numeric;
begin
    select id
      into cap_name_id
      from rhnclientcapabilityname
     where name = name_in;

    if not found then
        cap_name_id := nextval('rhn_client_capname_id_seq');

        insert into rhnClientCapabilityName(id, name)
            values (cap_name_id, name_in)
            on conflict do nothing;

        select id
            into strict cap_name_id
            from rhnclientcapabilityname
            where name = name_in;
    end if;

    return cap_name_id;
end;
$$ language plpgsql;
