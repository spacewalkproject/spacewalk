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

create schema rhn_package;

--update pg_setting
update pg_settings set setting = 'rhn_package,' || setting where name = 'search_path';

create or replace FUNCTION canonical_name
(
  name_in IN VARCHAR,
  evr_in IN EVR_T,
  arch_in IN VARCHAR(400)
)
RETURNS VARCHAR
AS $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replace by .pkb';
  RETURN NULL;
END;
$$
language 'plpgsql';


create or replace FUNCTION channel_occupancy_string(package_id_in IN NUMERIC, separator_in VARCHAR) 
RETURNS VARCHAR
AS $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replace by .pkb';
  RETURN NULL;
END;
$$ language 'plpgsql';

-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_package')+1) ) where name = 'search_path';
