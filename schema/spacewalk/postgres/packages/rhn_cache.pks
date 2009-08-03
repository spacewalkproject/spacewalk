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

create schema rhn_cache;

-- setup search_path so that these functions are created in appropriate schema.
update pg_settings set setting = 'rhn_cache,' || setting where name = 'search_path';

create or replace function update_perms_for_server
(
  server_id_in in numeric
)
returns void as
$$
begin
  raise exception 'Stub called, must be replace by .pkb';
end;
$$ language plpgsql;


create or replace function update_perms_for_user
(
  user_id_in in numeric
)
returns void
as $$
begin
  raise exception 'Stub called, must be replace by .pkb';
end;
$$ language plpgsql;

create or replace function update_perms_for_server_group
(
  server_group_id_in in numeric
)
returns void 
as $$
begin
  raise exception 'Stub called, must be replace by .pkb';
end;
$$ language plpgsql;

-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_cache')+1) ) where name = 'search_path';

