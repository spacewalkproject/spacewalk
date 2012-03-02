-- created by Oraschemadoc Fri Mar  2 05:58:02 2012
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "SPACEWALK"."RHNUSERMANAGEDSERVERGROUPS" ("USER_ID", "SERVER_GROUP_ID") AS 
  select user_id, server_group_id from rhnUserServerGroupPerms
union
select wc.id, sg.id
  from rhnServerGroup sg,
       rhnUserGroup ug,
       rhnUserGroupMembers ugm,
       web_contact wc
 where wc.org_id = sg.org_id
   and wc.id = ugm.user_id
   and ugm.user_group_id = ug.id
   and ug.group_type = (select id from rhnUserGroupType where label = 'org_admin')

 
/
