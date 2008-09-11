--
-- $Id$
--

create or replace view
rhnServerEntitlementView
(
   server_id,
   server_group_type_id,
   label,
   permanent,
   is_base
)
as
select
   distinct
   sgm.server_id,
   sgt.id,
   sgt.label,
   sgt.permanent,
   sgt.is_base
from
   rhnServerGroupType sgt,
   rhnServerGroup sg,
   rhnServerGroupMembers sgm
where
   sg.id = sgm.server_group_id
   and sg.group_type = sgt.id;
show errors;

