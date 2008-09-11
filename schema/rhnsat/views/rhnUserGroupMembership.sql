-- $Id$
--
-- View for all groups in an org, and if a user is in them

CREATE OR REPLACE VIEW rhnUserGroupMembership (
         ORG_ID, USER_ID, GROUP_ID, GROUP_NAME, GROUP_TYPE
)
AS
SELECT   UG.org_id, UGM.user_id, UG.id, UG.name, UGT.label
  FROM   rhnUserGroupType UGT, 
    	 rhnUserGroup UG, 
	 rhnUserGroupMembers UGM
 WHERE   UG.id = UGM.user_group_id(+)
   AND   UG.group_type = UGT.id
/

-- $Log$
-- Revision 1.6  2001/10/27 05:21:54  cturner
-- sql changes to move away from permissions being based on usergroups and instead directly on users
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
