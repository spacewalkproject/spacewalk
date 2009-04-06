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

create schema rhn_user;

-- setup search_path so that these functions are created in appropriate schema.
update pg_settings set setting = 'rhn_user,' || setting where name = 'search_path';

create or replace function check_role(user_id_in in numeric, role_in in varchar)
returns numeric
as $$
begin
  raise exception 'Stub called, must be replace by .pkb';
  return 0;
end;
$$ language plpgsql;

create or replace function check_role_implied(user_id_in in numeric, role_in in varchar)
returns numeric
as $$
begin
  raise exception 'Stub called, must be replace by .pkb';
  return 0;	
end;
$$ language plpgsql;

create or replace function get_org_id(user_id_in in numeric)
returns numeric
as $$
begin
  raise exception 'Stub called, must be replace by .pkb';
  return 0;
end;
$$ language plpgsql;

create or replace function find_mailable_address_autonomous(user_id_in in numeric)
returns varchar
as $$
begin
  raise exception 'Stub called, must be replace by .pkb';
  return null;
end;
$$ language plpgsql;

create or replace function find_mailable_address(user_id_in in numeric)
returns varchar
as $$
begin
  raise exception 'Stub called, must be replace by .pkb';
  return null;
end;
$$ language plpgsql;

create or replace function add_servergroup_perm
(
  user_id_in in numeric,
  server_group_id_in in numeric
)
returns void
as $$
begin
  raise exception 'Stub called, must be replace by .pkb';
end;
$$ language plpgsql;

create or replace function remove_servergroup_perm
(
  user_id_in in numeric,
  server_group_id_in in numeric
)
returns void
as $$
begin
  raise exception 'Stub called, must be replace by .pkb';
end;
$$ language plpgsql;

create or replace function add_to_usergroup
(
  user_id_in in numeric,
  user_group_id_in in numeric
)
returns void
as $$
begin
  raise exception 'Stub called, must be replace by .pkb';
end;
$$ language plpgsql;

create or replace function add_users_to_usergroups(user_id_in in numeric)
returns void
as $$
begin
  raise exception 'Stub called, must be replace by .pkb';
end;
$$ language plpgsql;

create or replace function remove_from_usergroup(user_id_in in numeric, user_group_id_in in numeric)
returns void
as $$
begin
  raise exception 'Stub called, must be replace by .pkb';
end;
$$ language plpgsql;

create or replace function remove_users_from_servergroups(user_id_in in numeric)
returns void
as $$
begin
  raise exception 'Stub called, must be replace by .pkb';
end;
$$ language plpgsql;

-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_user')+1) ) where name = 'search_path';
