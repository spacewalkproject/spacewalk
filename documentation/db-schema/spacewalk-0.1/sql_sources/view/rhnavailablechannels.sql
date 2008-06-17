-- created by Oraschemadoc Fri Jun 13 14:06:08 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "RHNSAT"."RHNAVAILABLECHANNELS" ("ORG_ID", "CHANNEL_ID", "CHANNEL_DEPTH", "CHANNEL_NAME", "CHANNEL_ARCH_ID", "PADDED_NAME", "CURRENT_MEMBERS", "AVAILABLE_MEMBERS", "LAST_MODIFIED", "CHANNEL_LABEL", "PARENT_OR_SELF_LABEL", "PARENT_OR_SELF_ID") AS 
  select
     ct.org_id,
     ct.id,
     CT.depth,
     CT.name,
     CT.channel_arch_id,
     CT.padded_name,
     (SELECT COUNT(1)
        FROM rhnServer S
       WHERE S.org_id = ct.org_id
         AND EXISTS (SELECT 1 FROM rhnServerChannel WHERE channel_id = ct.id AND server_id = S.id)),
     rhn_channel.available_chan_subscriptions(ct.id, ct.org_id),
     CT.last_modified,
     CT.label,
     CT.parent_or_self_label,
     CT.parent_or_self_id
from
     rhnOrgChannelTreeView CT
 
/
