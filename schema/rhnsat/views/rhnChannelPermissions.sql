--
-- $Id$
--

create or replace view
rhnChannelPermissions
(
    org_id, channel_id
)
as
select distinct org_id, channel_id from (
select	privcf.org_id, cfm.channel_id
from	rhnChannelFamilyMembers cfm,
	rhnPrivateChannelFamily privcf
where	privcf.channel_family_id = cfm.channel_family_id
union all
select	u.org_id, cfm.channel_id
from	web_contact u,
	rhnChannelFamilyMembers cfm,
	rhnPublicChannelFamily pubcf
where	pubcf.channel_family_id = cfm.channel_family_id
);

--
-- $Log$
-- Revision 1.3  2004/04/14 00:09:24  pjones
-- bugzilla: 120761 -- split rhnChannelPermissions into two tables, eliminating
-- a frequent full table scan
--
