-- created by Oraschemadoc Fri Mar  2 05:57:58 2012
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "SPACEWALK"."RHNCHANNELFAMILYOVERVIEW" ("ORG_ID", "ID", "NAME", "URL", "LABEL", "CURRENT_MEMBERS", "MAX_MEMBERS", "FVE_CURRENT_MEMBERS", "FVE_MAX_MEMBERS", "HAS_SUBSCRIPTION") AS 
  select	pcf.org_id				as org_id,
	f.id					as id,
	f.name					as name,
	f.product_url				as url,
	f.label					as label,
	coalesce(pcf.current_members,0)		as current_members,
	pcf.max_members				as max_members,
	coalesce(pcf.fve_current_members,0)		as fve_current_members,
	pcf.fve_max_members				as fve_max_members,
	1					as has_subscription
from	rhnChannelFamily			f,
	rhnPrivateChannelFamily			pcf
where	pcf.channel_family_id = f.id
 
/
