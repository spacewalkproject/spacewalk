-- created by Oraschemadoc Fri Jan 22 13:40:42 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "MIM_H1"."RHNDEMOORGS" ("ORG_ID") AS 
  (
    select org_id
    from demo_log
    where server_id = 0
)
 
/
