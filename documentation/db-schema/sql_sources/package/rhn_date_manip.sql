-- created by Oraschemadoc Fri Jan 22 13:41:06 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE PACKAGE "MIM_H1"."RHN_DATE_MANIP" 
is
	periods_ago number;
	function get_reporting_period_start return date;
	function get_reporting_period_end return date;
end rhn_date_manip;
CREATE OR REPLACE PACKAGE BODY "MIM_H1"."RHN_DATE_MANIP" 
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
