-- created by Oraschemadoc Fri Jan 22 13:40:43 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "SPACEWALK"."RHNORGPACKAGEOVERVIEW" ("ORG_ID", "CHANNEL_ARCH_ID", "PACKAGE_ID", "PACKAGE_NVREA") AS
  select
    p.org_id as org_id,
    cpac.channel_arch_id,
    p.id as package_id,
    rhn_package.canonical_name(p_name.name, p_evr.evr, pa.name) as package_nvrea
from
    rhnPackageName p_name,
    rhnPackageEVR p_evr,
    rhnPackageArch pa,
    rhnChannelPackageArchCompat cpac,
    rhnPackage p
where
        p_name.id = p.name_id
    and p_evr.id = p.evr_id
    and cpac.package_arch_id = p.package_arch_id
    and p.package_arch_id = pa.id
order by package_nvrea, p.created

 
/
