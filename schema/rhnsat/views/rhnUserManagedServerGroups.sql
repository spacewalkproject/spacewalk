-- Overview of users in an org
--
-- $Id$

create or replace view
rhnUserManagedServerGroups (
    user_id, server_group_id
)
as
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


-- $Log$
-- Revision 1.4  2001/11/06 23:08:48  cturner
-- sql updtes
--
-- Revision 1.3  2001/10/27 05:21:54  cturner
-- sql changes to move away from permissions being based on usergroups and instead directly on users
--
-- Revision 1.2  2001/06/27 02:05:25  gafton
-- add Log too
--
