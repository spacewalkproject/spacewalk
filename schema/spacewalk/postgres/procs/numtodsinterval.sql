-- oracle equivalent source none
--
-- Copyright (c) 2010 Red Hat, Inc.
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

create or replace function numtodsinterval(sec_in in numeric, type_in in varchar)
returns interval
as
$$
begin
  if type_in = any(array['second', 'hour', 'minute', 'day']) then
    return num_in || ' ' || type_in;
  else
    raise exception 'Function numtodsinterval only supports conversion from [second, hour, minte, day], not from [%].', type_in;
  end if;
end;
$$ language plpgsql
stable;
