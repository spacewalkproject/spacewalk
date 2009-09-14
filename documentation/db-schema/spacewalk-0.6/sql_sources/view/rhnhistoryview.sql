-- created by Oraschemadoc Mon Aug 31 10:54:31 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "MIM1"."RHNHISTORYVIEW" ("EVENT_ID", "SERVER_ID", "SUMMARY", "DETAILS", "CREATED", "MODIFIED") AS 
  select
    id event_id, server_id, summary, details, created, modified
from
    rhnServerHistory
UNION
select "EVENT_ID","SERVER_ID","SUMMARY","DETAILS","CREATED","MODIFIED" from rhnHistoryView_refresh
UNION
select "EVENT_ID","SERVER_ID","SUMMARY","DETAILS","CREATED","MODIFIED" from rhnHistoryView_packages
UNION
select "EVENT_ID","SERVER_ID","SUMMARY","DETAILS","CREATED","MODIFIED" from rhnHistoryView_errata
with
    read only
 
/
