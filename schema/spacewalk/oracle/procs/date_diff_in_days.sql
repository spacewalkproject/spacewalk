--
-- Copyright (c) 2008--2010 Red Hat, Inc.
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
-- Diffs two dates (date2 - date1) and returns number of dates in the result.
-- Can return fraction digits if dates has different time.
-- Basically this is equivalent of (date2 - date1) but we need to use this
-- function instead of the minus operator because of PostgreSQL compatibility.
--

create or replace function date_diff_in_days(ts1 in date, ts2 in date)
return number is
begin
    return ts2 - ts1;
end date_diff_in_days;
