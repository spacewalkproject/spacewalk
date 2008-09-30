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

create or replace package
rhn_quota
is
	function recompute_org_quota_used (
		org_id_in in number
	) return number;

	function get_org_for_config_content (
		config_content_id_in in number
	) return number;

	procedure set_org_quota_total (
		org_id_in in number,
		total_in in number
	);

	procedure update_org_quota (
		org_id_in in number
	);
end rhn_quota;
/
show errors

--
--
-- Revision 1.2  2004/01/07 20:52:36  pjones
-- bugzilla: 113029 -- helper function to do updates of used quota total
--
-- Revision 1.1  2003/12/19 22:07:30  pjones
-- bugzilla: 112392 -- quota support for config files
--
