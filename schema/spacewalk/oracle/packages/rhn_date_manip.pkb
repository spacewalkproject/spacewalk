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
-- date manipulation functions, mostly for reporting so far

create or replace
package body rhn_date_manip
is
	function get_reporting_period_start
	return date is
		months_ago	number;
		weeks_ago	number;
		target_date	date;
		day_number	number;
	begin
		months_ago := rhn_date_manip.periods_ago/2;
		weeks_ago := mod(rhn_date_manip.periods_ago,2);

		target_date := trunc(add_months(sysdate,-months_ago)-(7*weeks_ago));
		day_number := to_char(target_date,'DD');
		-- squish the date to the 1st or the 16th
		if day_number > 16 then
			target_date := target_date - (day_number - 16);
		else
			target_date := target_date - (day_number - 1);
		end if;
		return target_date;
	end get_reporting_period_start;

	function get_reporting_period_end
	return date is
		months_ago	number;
		weeks_ago	number;
		target_date	date;
		day_number	number;
	begin
		months_ago := rhn_date_manip.periods_ago/2;
		weeks_ago := mod(rhn_date_manip.periods_ago,2);

		target_date := trunc(add_months(sysdate,-months_ago)-(7*weeks_ago));
		day_number := to_char(target_date,'DD');
		-- squish the date to the 1st or the 16th
		if day_number > 16 then
			target_date := last_day(target_date);
		else
			target_date := target_date + (-day_number + 15) + (1-1/86400);
		end if;
		return target_date;
	end get_reporting_period_end;
end rhn_date_manip;
/
show errors
			
--
-- Revision 1.1  2003/03/07 23:13:58  pjones
-- date manipulation procedures
-- so far, these pick date ranges to do reports from
--
