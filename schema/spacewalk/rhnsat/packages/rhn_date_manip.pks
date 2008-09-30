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
package rhn_date_manip
is
	periods_ago number;
	function get_reporting_period_start return date;
	function get_reporting_period_end return date;
end rhn_date_manip;
/
show errors

--
-- Revision 1.1  2003/03/07 23:13:58  pjones
-- date manipulation procedures
-- so far, these pick date ranges to do reports from
--
