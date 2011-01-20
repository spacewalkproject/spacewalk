-- created by Oraschemadoc Thu Jan 20 13:56:40 2011
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "SPACEWALK"."RHNVISIBLESERVERGROUPMEMBERS" ("SERVER_ID", "SERVER_GROUP_ID", "CREATED", "MODIFIED") AS 
  SELECT SGM."SERVER_ID",SGM."SERVER_GROUP_ID",SGM."CREATED",SGM."MODIFIED"
    FROM rhnServerGroup SG,
         rhnServerGroupMembers SGM
   WHERE SGM.server_group_id = SG.id
     AND SG.group_type IS NULL
 
/
