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
CREATE OR REPLACE VIEW
rhnUserAppletOverview
(
    	    user_id,
    	    security_count,
	    bug_count,
	    enhancement_count
)
AS
SELECT      USP.user_id,
    	    SUM((SELECT COUNT(*) FROM rhnServerErrataTypeView SEV 
	         WHERE SEV.server_id = USP.server_id
	         AND SEV.errata_type = 'Security Advisory')),
    	    SUM((SELECT COUNT(*) FROM rhnServerErrataTypeView SEV 
	         WHERE SEV.server_id = USP.server_id
	         AND SEV.errata_type = 'Bug Fix Advisory')),
    	    SUM((SELECT COUNT(*) FROM rhnServerErrataTypeView SEV 
	         WHERE SEV.server_id = USP.server_id
	         AND SEV.errata_type = 'Product Enhancement Advisory'))
FROM        rhnUserServerPerms USP
GROUP BY    USP.user_id
;

