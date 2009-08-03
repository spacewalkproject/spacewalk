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

create schema rhn_org;

-- setup search_path so that these functions are created in appropriate schema.
update pg_settings set setting = 'rhn_org,' || setting where name = 'search_path';

CREATE OR REPLACE FUNCTION find_server_group_by_type(org_id_in NUMERIC, group_label_in VARCHAR) 
RETURNS NUMERIC
AS $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replaced by .pkb';
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION delete_org (org_id_in in numeric)
RETURNS VOID
AS $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replaced by .pkb';
END;
$$ language plpgsql;


CREATE OR REPLACE FUNCTION delete_user(user_id_in in numeric, deleting_org in numeric default 0)
RETURNS VOID 
AS $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replaced by .pkb';
END;
$$ language plpgsql;

-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_org')+1) ) where name = 'search_path';
