-- created by Oraschemadoc Fri Jun 13 14:06:08 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "RHNSAT"."RHNCHANNELFAMILYOVERVIEW" ("ORG_ID", "ID", "NAME", "URL", "LABEL", "CURRENT_MEMBERS", "MAX_MEMBERS", "HAS_SUBSCRIPTION") AS 
  select	pcf.org_id				org_id,
	f.id					id,
	f.name					name,
	f.product_url				url,
	f.label					label,
	NVL(pcf.current_members,0)		current_members,
	pcf.max_members				max_members,
	1					has_subscription
from	rhnChannelFamily			f,
	rhnPrivateChannelFamily			pcf
where	pcf.channel_family_id = f.id
 
/
