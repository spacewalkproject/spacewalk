-- created by Oraschemadoc Fri Jun 13 14:06:08 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "RHNSAT"."RHNHISTORYVIEW" ("EVENT_ID", "SERVER_ID", "SUMMARY", "DETAILS", "CREATED", "MODIFIED") AS 
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
