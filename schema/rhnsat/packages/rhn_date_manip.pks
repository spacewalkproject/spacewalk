--
-- $Id$
--
-- date manipulation functions, mostly for reporting so far

create or replace
package rhn_date_manip
is
	periods_ago number;
	function get_reporting_period_start return date;
	function get_reporting_period_end return date;
end rhn_date_manip;
/
show errors

-- $Log$
-- Revision 1.1  2003/03/07 23:13:58  pjones
-- date manipulation procedures
-- so far, these pick date ranges to do reports from
--
