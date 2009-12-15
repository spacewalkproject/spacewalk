-- created by Oraschemadoc Mon Aug 31 10:54:34 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "MIM1"."RHNUSERCHANNEL" ("USER_ID", "ORG_ID", "CHANNEL_ID", "ROLE") AS 
  select
   cfp.user_id,
   cfp.org_id,
   cfm.channel_id,
   'manage' as role
from rhnChannelFamilyMembers cfm,
      rhnUserChannelFamilyPerms cfp
where
   cfp.channel_family_id = cfm.channel_family_id and
   rhn_channel.user_role_check(cfm.channel_id, cfp.user_id, 'manage') = 1
union all
select
   cfp.user_id,
   cfp.org_id,
   cfm.channel_id,
   'subscribe' as role
from rhnChannelFamilyMembers cfm,
      rhnUserChannelFamilyPerms cfp
where
   cfp.channel_family_id = cfm.channel_family_id and
   rhn_channel.user_role_check(cfm.channel_id, cfp.user_id, 'subscribe') = 1
union all
select
   w.id as user_id,
   w.org_id,
   s.id as channel_id,
   'subscribe' as role
from rhnSharedChannelView s,
      web_contact w
where
   w.org_id = s.org_trust_id and
   rhn_channel.user_role_check(s.id, w.id, 'subscribe') = 1
 
/
