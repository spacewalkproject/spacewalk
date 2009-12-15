-- created by Oraschemadoc Mon Aug 31 10:54:32 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "MIM1"."RHNORGERRATA" ("ORG_ID", "ERRATA_ID", "CHANNEL_ID") AS 
  select
    ac.org_id,
    ce.errata_id,
    ac.channel_id
from
    rhnChannelErrata ce,
    rhnAvailableChannels ac
where
    ce.channel_id = ac.channel_id

 
/
