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

create or replace synonym rhn_date_manip for rhn.rhn_date_manip;

--
-- Revision 1.2  2004/01/28 22:22:10  pjones
-- bugzilla: none -- one of the dumbest typos ever, now fixed.  We never
-- refer to this package from rhnuser, so I don't think it makes any
-- significant difference...
--
-- Revision 1.1  2003/03/07 23:13:58  pjones
-- date manipulation procedures
-- so far, these pick date ranges to do reports from
--
