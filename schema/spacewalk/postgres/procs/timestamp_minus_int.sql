--
-- Copyright (c) 2009 Red Hat, Inc.
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


--
-- Temporary(?) hack to support expressions like CURRENT_TIMESTAMP - 1000
-- which we want to be interpreted as minus 1000 days, since Oracle
-- interprets SYSDATE - 1000 that way.
--

create or replace function timestamptz_minus_int(timestamptz, integer)
returns timestamptz as
$$ select $1 - $2 * interval '1 day' $$
language sql;

create operator - (
  leftarg = timestamptz,
  rightarg = integer,
  procedure = timestamptz_minus_int
);
