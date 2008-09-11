-- $Id$
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


-- $Log$
-- Revision 1.3  2001/06/27 02:05:25  gafton
-- add Log too
--
