--
-- $Id$
--
-- this is a helper for rhnServerGroupOverviewLite and it's Vis brother.

create or replace view
rhnServerGroupOVLiteHelper as
select	sgm.server_group_id						server_group_id,
		e.advisory_type							advisory_type
from	rhnErrata								e,
		rhnServerNeededPackageCache				snpc,
		rhnServerGroupMembers					sgm
where   1=1
	and sgm.server_id = snpc.server_id
	and snpc.errata_id = e.id
/

-- $Log$
-- Revision 1.1  2002/11/11 23:37:43  pjones
-- add a Vis varient
--
