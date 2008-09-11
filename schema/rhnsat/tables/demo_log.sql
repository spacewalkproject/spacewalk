--
-- $Id$
-- 

create table demo_log (
    org_id      number,
    server_id   number
);

create index dl_oid_sid_idx
    on demo_log (org_id, server_id)
    tablespace [[8m_tbs]]
    storage ( freelists 16 )
    initrans 32
    nologging;


-- table to hold which servers got unentitled for orgs
-- that were using the demo entitlement.
--
-- server_id will be 0 if nothing could be unentitled.
