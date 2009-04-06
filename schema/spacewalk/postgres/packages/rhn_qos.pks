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

create schema rhn_qos;

--update in pg_setting
update pg_settings set setting = 'rhn_qos,' || setting where name = 'search_path';

create or replace function slot_count
(
  org_id_in in numeric,
  label_in in varchar
)
returns numeric
as $$
begin
  raise exception 'Stub called, must be replace by .pkb';
  return 0;
end;
$$ language plpgsql;


create or replace function basic_slot_count(org_id_in in numeric)
returns numeric
as $$
begin
  raise exception 'Stub called, must be replace by .pkb';
  return 0;
end;
$$ language plpgsql;

create or replace function workgroup_slot_count(org_id_in in numeric) 
 returns numeric
as $$
begin
  raise exception 'Stub called, must be replace by .pkb';
  return 0;
end;
$$ language plpgsql;


create or replace function channel_slot_count(org_id_in in numeric, label_in in numeric) 
returns numeric
as $$
begin
  raise exception 'Stub called, must be replace by .pkb';
  return 0;
end;
$$ language plpgsql;

create or replace function as_slot_count(org_id_in in numeric)
returns numeric
as $$
begin
  raise exception 'Stub called, must be replace by .pkb';
  return 0;
end;
$$ language plpgsql;

-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_qos')+1) ) where name = 'search_path';

