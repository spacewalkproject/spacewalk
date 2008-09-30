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


CREATE OR REPLACE VIEW rhnServerGroupMembership (
         ORG_ID, SERVER_ID, GROUP_ID, GROUP_NAME, GROUP_TYPE, CURRENT_MEMBERS, MAX_MEMBERS
)
AS
SELECT   SG.org_id, SGM.server_id, SG.id, SG.name, SGT.label, SG.current_members, SG.max_members
  FROM   rhnServerGroupType SGT, 
	 rhnServerGroupMembers SGM,
    	 rhnServerGroup SG
 WHERE   SG.id = SGM.server_group_id(+)
   AND   SG.group_type = SGT.id(+)
/


-- $Log$
-- Revision 1.6  2001/07/19 12:39:01  cturner
-- helpful message about group max members
--
-- Revision 1.5  2001/07/06 16:00:48  cturner
-- repaired some busted views
--
-- Revision 1.4  2001/07/06 12:42:23  cturner
-- cleanup on user/server edit to hide innapropriate groupes when no longer needed
--
-- Revision 1.3  2001/06/27 02:05:25  gafton
-- add Log too
--
