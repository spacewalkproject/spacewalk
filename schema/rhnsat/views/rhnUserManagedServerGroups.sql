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
