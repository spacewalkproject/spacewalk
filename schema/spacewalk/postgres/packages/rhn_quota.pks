-- oracle equivalent source sha1 82ad2287cb726f13fa01da60a48940d2eac9a369
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
--

create schema rhn_quota;

-- setup search_path so that these functions are created in appropriate schema.
update pg_settings set setting = 'rhn_quota,' || setting where name = 'search_path';

create or replace function recompute_org_quota_used(org_id_in in numeric)
returns numeric
as $$
begin
  raise exception 'Stub called, must be replaced by .pkb';
  return 0;
end;
$$ language plpgsql;

create or replace function update_org_quota(org_id_in in numeric)
returns void
as $$
begin
  raise exception 'Stub called, must be replaced by .pkb';
end;
$$ language plpgsql;

-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_quota')+1) ) where name = 'search_path';
