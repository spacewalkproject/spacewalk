-- created by Oraschemadoc Fri Jan 22 13:40:40 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "MIM_H1"."RHNAVAILABLECHANNELS" ("ORG_ID", "CHANNEL_ID", "CHANNEL_DEPTH", "CHANNEL_NAME", "CHANNEL_ARCH_ID", "PADDED_NAME", "CURRENT_MEMBERS", "AVAILABLE_MEMBERS", "LAST_MODIFIED", "CHANNEL_LABEL", "PARENT_OR_SELF_LABEL", "PARENT_OR_SELF_ID") AS 
  select
     ct.org_id,
     ct.id,
     CT.depth,
     CT.name,
     CT.channel_arch_id,
     CT.padded_name,
    (SELECT COUNT(1)
     FROM rhnServer S
     INNER JOIN rhnServerChannel SC
       ON SC.server_id = S.id
     WHERE SC.channel_id = CT.id AND
           S.org_id = CT.org_id),
     rhn_channel.available_chan_subscriptions(ct.id, ct.org_id),
     CT.last_modified,
     CT.label,
     CT.parent_or_self_label,
     CT.parent_or_self_id
from
     rhnOrgChannelTreeView CT
UNION
select
     ct.org_id,
     ct.id,
     CT.depth,
     CT.name,
     CT.channel_arch_id,
     CT.padded_name,
    (SELECT COUNT(1)
     FROM rhnServer S
     INNER JOIN rhnServerChannel SC
       ON SC.server_id = S.id
     WHERE SC.channel_id = CT.id AND
           S.org_id = CT.org_id),
     NULL,
     CT.last_modified,
     CT.label,
     CT.parent_or_self_label,
     CT.parent_or_self_id
from
     rhnSharedChannelTreeView CT

 
/
