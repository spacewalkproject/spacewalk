-- created by Oraschemadoc Fri Jan 22 13:40:41 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "SPACEWALK"."RHNCHANNELNEWESTPACKAGEVIEW" ("CHANNEL_ID", "NAME_ID", "EVR_ID", "PACKAGE_ARCH_ID", "PACKAGE_ID") AS
  select  cp.channel_id		as channel_id,
		p.name_id			as name_id,
		p.evr_id			as evr_id,
		p.package_arch_id	as package_arch_id,
		p.id				as package_id
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
