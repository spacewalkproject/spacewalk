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
CREATE OR REPLACE VIEW rhnVisServerGroupOverview (
         ORG_ID, SECURITY_ERRATA, BUG_ERRATA, ENHANCEMENT_ERRATA, GROUP_ID, GROUP_NAME, GROUP_ADMINS, SERVER_COUNT, NOTE_COUNT, MODIFIED, MAX_MEMBERS
)
AS
  SELECT SG.org_id, 
         (SELECT COUNT(E.id)
	    FROM rhnErrata E
	   WHERE E.advisory_type = 'Security Advisory'
	     AND EXISTS (SELECT 1 FROM rhnServerNeededPackageCache SNEC, rhnServerGroupMembers SGM
	                         WHERE SGM.server_id = SNEC.server_id
				   AND SNEC.errata_id = E.id
				   AND SGM.server_group_id = SG.id)),
         (SELECT COUNT(E.id)
	    FROM rhnErrata E
	   WHERE E.advisory_type = 'Bug Fix Advisory'
	     AND EXISTS (SELECT 1 FROM rhnServerNeededPackageCache SNEC, rhnServerGroupMembers SGM
	                         WHERE SGM.server_id = SNEC.server_id
				   AND SNEC.errata_id = E.id
				   AND SGM.server_group_id = SG.id)),
         (SELECT COUNT(E.id)
	    FROM rhnErrata E
	   WHERE E.advisory_type = 'Product Enhancement Advisory'
	     AND EXISTS (SELECT 1 FROM rhnServerNeededPackageCache SNEC, rhnServerGroupMembers SGM
	                         WHERE SGM.server_id = SNEC.server_id
				   AND SNEC.errata_id = E.id
				   AND SGM.server_group_id = SG.id)),
	 SG.id, SG.name, 
	 (SELECT COUNT(*) FROM rhnUserManagedServerGroups UMSG WHERE UMSG.server_group_id = SG.id),
	 (SELECT COUNT(*) FROM rhnServerGroupMembers SGM WHERE SGM.server_group_id = SG.id), 
	 0, SYSDATE, MAX_MEMBERS
    FROM rhnVisibleServerGroup SG;
