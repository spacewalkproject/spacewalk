-- oracle equivalent source sha1 65eff98afb7636fef45db31369ce6c5dd5ae1a37
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
lookup_tag(org_id_in in numeric, name_in in varchar)
returns numeric
as $$
declare
    tag_id  numeric;
begin
    select id
      into tag_id
      from rhnTag
     where org_id = org_id_in and
           name_id = lookup_tag_name(name_in);

    if not found then
        tag_id := nextval('rhn_tag_id_seq');
        begin
            perform pg_dblink_exec(
                'insert into rhnTag(id, org_id, name_id) values (' ||
                tag_id || ', ' || org_id_in || ', ' ||
                coalesce(quote_literal(lookup_tag_name(name_in), 'NULL')) || ')');
        exception when unique_violation then
            select id
              into strict tag_id
              from rhnTag
             where org_id = org_id_in and
                   name_id = lookup_tag_name(name_in);
        end;
    end if;

    return tag_id;
end; $$
language plpgsql immutable;
