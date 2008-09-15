-- created by Oraschemadoc Fri Jun 13 14:06:08 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "RHNSAT"."RHNCHANNELNEWESTPACKAGEVIEW" ("CHANNEL_ID", "NAME_ID", "EVR_ID", "PACKAGE_ARCH_ID", "PACKAGE_ID") AS 
  select  cp.channel_id		channel_id,
		p.name_id			name_id,
		p.evr_id			evr_id,
		p.package_arch_id	package_arch_id,
		p.id				package_id
from	rhnPackageEVR		pe,
		rhnPackage			p,
		rhnChannelPackage	cp
where	cp.package_id = p.id
		and p.evr_id = pe.id
		and pe.evr = (
			select	max(sq_pe.evr)
			from	rhnChannelPackage sq_cp,
					rhnPackage sq_p,
					rhnPackageEVR sq_pe
			where	1=1
				and sq_cp.channel_id = cp.channel_id
				and sq_cp.package_id = sq_p.id
				and sq_p.name_id = p.name_id
				and sq_pe.id = sq_p.evr_id
		)
 
/
