--
-- $Id$
--

create or replace view
rhnChannelPackageOverview
(
    	channel_id,
	name_id,
	evr
)
as
select  cp.channel_id,
	p.name_id,
	max(p_evr.evr)
from
	rhnPackageEVR p_evr,
	rhnPackage p,
	rhnChannelPackage cp
where
    	cp.package_id = p.id
    and p.evr_id = p_evr.id
group by cp.channel_id, p.name_id
/

-- $Log$
-- Revision 1.2  2002/05/15 21:30:09  pjones
-- id/log
--
