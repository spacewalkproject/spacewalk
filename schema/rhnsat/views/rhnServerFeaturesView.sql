--
-- $Id$
--

create or replace view
rhnServerFeaturesView
(
   server_id,
   label
)
as
select
   distinct
   sgm.server_id,
   f.label
from
   rhnFeature f,
   rhnServerGroupTypeFeature sgtf,
   rhnServerGroupMembers sgm,
   rhnServerGroup sg
where
   sg.id = sgm.server_group_id
   and sgtf.feature_id = f.id
   and sg.group_type = sgtf.server_group_type_id
/

show errors;
