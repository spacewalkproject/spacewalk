-- created by Oraschemadoc Fri Jun 13 14:06:08 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "RHNSAT"."RHNDEMOORGS" ("ORG_ID") AS 
  (
    select org_id
    from demo_log
    where server_id = 0
)
 
/
