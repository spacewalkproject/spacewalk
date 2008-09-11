-- $Id$
--
-- a view to list all errata valid for an org.
-- in other words, errata from pub channels and their channels
create or replace view
rhnOrgErrata
(
    	org_id,
	errata_id,
	channel_id
)
as
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

-- $Log$
-- Revision 1.2  2001/06/27 02:05:25  gafton
-- add Log too
--
