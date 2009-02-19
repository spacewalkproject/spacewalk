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
create or replace view rhnUserTypeBase (
       user_id, type_id, type_label, type_name
)
AS
select distinct
    ugm.user_id, ugt.id, ugt.label, ugt.name
from   
    rhnUserGroupMembers ugm, rhnUserGroupType ugt, rhnUserGroup ug
where   
    ugm.user_group_id = ug.id
and ugt.id = ug.group_type;


--
-- Revision 1.3  2001/06/27 02:05:25  gafton
-- add Log too
--
