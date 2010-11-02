-- created by Oraschemadoc Tue Nov  2 08:33:12 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "SPACEWALK"."RHNCHECKSUMVIEW" ("ID", "CHECKSUM_TYPE", "CHECKSUM") AS 
  select c.id,
       ct.label checksum_type,
       c.checksum
  from rhnChecksum c,
       rhnChecksumType ct
 where c.checksum_type_id = ct.id
 
/
