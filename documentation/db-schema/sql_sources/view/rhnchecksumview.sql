-- created by Oraschemadoc Wed Dec 21 14:59:46 2011
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "SPACEWALK"."RHNCHECKSUMVIEW" ("ID", "CHECKSUM_TYPE", "CHECKSUM") AS 
  select c.id,
       ct.label checksum_type,
       c.checksum
  from rhnChecksum c,
       rhnChecksumType ct
 where c.checksum_type_id = ct.id
 
/
