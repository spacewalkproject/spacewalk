-- created by Oraschemadoc Fri Jun 13 14:06:09 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "RHNSAT"."RHNSTORAGEDEVICE" ("ID", "SERVER_ID", "CLASS", "BUS", "DETACHED", "DEVICE", "DRIVER", "DESCRIPTION", "PHYSICAL", "LOGICAL", "PCITYPE") AS 
  select
	d.id,
	d.server_Id,
	d.class,
	d.bus,
	d.detached,
	d.device,
	d.driver,
	d.description,
	d.prop1,
	d.prop2,
	d.pcitype
from rhnDevice d
where d.class in ('HD', 'FLOPPY')
 
/
