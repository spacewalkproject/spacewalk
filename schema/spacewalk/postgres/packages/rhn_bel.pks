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

create schema rhn_bel;

-- setup search_path so that these functions are created in appropriate schema.
update pg_settings set setting = 'rhn_bel,' || setting where name = 'search_path';

create or replace function is_org_paid
(
    org_id_in in numeric
)
returns numeric as $$
begin
    raise exception 'Stub called, must be replace by .pkb';
    return 0;
end;
$$ language plpgsql;

create or replace function lookup_email_state
(
    state_in in varchar
)
returns numeric as $$
begin
    raise exception 'Stub called, must be replace by .pkb';
	return 0;
end;
$$ language plpgsql;

-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_bel')+1) ) where name = 'search_path';
