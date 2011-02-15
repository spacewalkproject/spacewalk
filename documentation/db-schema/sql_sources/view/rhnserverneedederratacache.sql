-- created by Oraschemadoc Thu Jan 20 13:56:27 2011
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "SPACEWALK"."RHNSERVERNEEDEDERRATACACHE" ("SERVER_ID", "ERRATA_ID") AS 
  select
   distinct  server_id, errata_id
   from rhnServerNeededCache
 
/
