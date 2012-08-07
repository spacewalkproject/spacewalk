-- oracle equivalent source sha1 955c0ef4c817326c6affc97993fcbccdefe3bee7
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
--
-- Diffs two timestamps (date2 - date1) and returns number of dates in the result.
-- If two timestamps are given it can return fraction digits in the same way
-- as Oracle does.
--

create or replace function date_diff_in_days(timestamptz, timestamptz)
returns numeric as
$$
select cast(extract(epoch from $2 - $1) / (60 * 60 * 24) as numeric)
$$ language sql immutable;
