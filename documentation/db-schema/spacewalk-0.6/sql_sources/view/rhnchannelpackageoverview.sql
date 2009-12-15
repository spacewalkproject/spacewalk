-- created by Oraschemadoc Mon Aug 31 10:54:31 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "MIM1"."RHNCHANNELPACKAGEOVERVIEW" ("CHANNEL_ID", "NAME_ID", "EVR") AS 
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
