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

create or replace function
lookup_config_info
(
    username_in     in varchar,
    groupname_in    in varchar,
    filemode_in     in numeric
)
returns numeric
as
$$
declare
    r numeric;
    v_id    numeric;
    lookup_cursor cursor  for
        select id
          from rhnConfigInfo
         where username = username_in
           and groupname = groupname_in
           and filemode = filemode_in;
begin
    for r in lookup_cursor loop
        return r.id;
    end loop;
    -- If we got here, we don't have the id
    select nextval('rhn_confinfo_id_seq') into v_id;
    insert into rhnConfigInfo
        (id, username, groupname, filemode)
    values (v_id, username_in, groupname_in, filemode_in);
    return v_id;
end;
$$ language plpgsql;
