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
-- View for all groups in an org, and if a user is in them

CREATE OR REPLACE VIEW rhnUserGroupMembership (
         ORG_ID, USER_ID, GROUP_ID, GROUP_NAME, GROUP_TYPE
)
AS
SELECT   UG.org_id, UGM.user_id, UG.id, UG.name, UGT.label
  FROM   rhnUserGroupType UGT, 
    	 rhnUserGroup UG
	    left outer join
	 rhnUserGroupMembers UGM on(UG.id = UGM.user_group_id)
 WHERE   UG.group_type = UGT.id
;

