-- created by Oraschemadoc Mon Aug 31 10:54:34 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "MIM1"."RHNUSERAVAILABLECHANNELS" ("USER_ID", "ORG_ID", "CHANNEL_ID", "CHANNEL_DEPTH", "CHANNEL_NAME", "CHANNEL_ARCH_ID", "PADDED_NAME", "CURRENT_MEMBERS", "AVAILABLE_MEMBERS", "LAST_MODIFIED", "CHANNEL_LABEL", "PARENT_OR_SELF_LABEL", "PARENT_OR_SELF_ID", "END_OF_LIFE") AS 
  select
     ct.user_id,
     ct.org_id,
     ct.id,
     CT.depth,
     CT.name,
     CT.channel_arch_id,
     CT.padded_name,
     (
     SELECT COUNT(1)
       FROM rhnUserServerPerms USP
      WHERE USP.user_id = ct.user_id
        AND EXISTS (SELECT 1 FROM rhnServerChannel WHERE channel_id = ct.id AND server_id = USP.server_id)
     ),
     rhn_channel.available_chan_subscriptions(ct.id, ct.org_id),
     CT.last_modified,
     CT.label,
     CT.parent_or_self_label,
     CT.parent_or_self_id,
     CT.end_of_life
from
     rhnUserChannelTreeView ct
where rhn_channel.org_channel_setting(ct.id, ct.org_id ,'not_globally_subscribable') = 0 OR exists (
     						SELECT 1 from rhnChannelPermission per where per.channel_id = ct.id
     						)
                            OR (rhn_user.check_role(ct.user_id, 'org_admin') = 1
                                OR rhn_user.check_role(ct.user_id, 'channel_admin') = 1)

 
/
