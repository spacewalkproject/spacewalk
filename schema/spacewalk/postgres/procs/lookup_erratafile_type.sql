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
--
--


create or replace function lookup_erratafile_type(lable_in in varchar)
returns numeric
as $$
declare
	ret_val numeric;
begin

	SELECT retcode into ret_val from dblink('dbname='||current_database(),
	'select lookup_erratafile_type_autonomous('||coalesce(label_in::varchar,'null')||')')
	as f (retcode numeric);
end;
$$language plpgsql;


