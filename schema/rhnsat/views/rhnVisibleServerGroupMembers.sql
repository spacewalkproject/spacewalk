-- $Id$
--
CREATE OR REPLACE VIEW
rhnVisibleServerGroupMembers
AS
  SELECT SGM.*
    FROM rhnServerGroup SG,
         rhnServerGroupMembers SGM
   WHERE SGM.server_group_id = SG.id
     AND SG.group_type IS NULL;
