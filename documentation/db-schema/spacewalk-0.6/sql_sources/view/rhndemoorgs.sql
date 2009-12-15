-- created by Oraschemadoc Mon Aug 31 10:54:31 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "MIM1"."RHNDEMOORGS" ("ORG_ID") AS 
  (
    select org_id
    from demo_log
    where server_id = 0
)
 
/
