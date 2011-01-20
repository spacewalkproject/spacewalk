-- created by Oraschemadoc Thu Jan 20 13:56:14 2011
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "SPACEWALK"."RHNCHECKSUMVIEW" ("ID", "CHECKSUM_TYPE", "CHECKSUM") AS 
  select c.id,
       ct.label checksum_type,
       c.checksum
  from rhnChecksum c,
       rhnChecksumType ct
 where c.checksum_type_id = ct.id
 
/
