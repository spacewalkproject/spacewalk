-- $Id$
--
create or replace view 
rhnStorageDevice
(id, server_Id, class, bus, detached, device, driver, 
description, physical, logical, pcitype)
as select 
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
where d.class in ('HD', 'FLOPPY');


-- $Log$
-- Revision 1.2  2001/06/27 02:05:25  gafton
-- add Log too
--
