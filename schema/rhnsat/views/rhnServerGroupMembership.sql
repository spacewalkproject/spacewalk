-- $Id$
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
