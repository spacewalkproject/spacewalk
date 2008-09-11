-- $Id$
--
create or replace view 
rhnCDDevice
(id, server_Id, class, bus, detached, device, driver, 
description, dev_host, dev_id, dev_channel, dev_lun, pcitype)
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
	d.prop3,
	d.prop4,
	d.pcitype
from rhndevice d
where d.class = 'CDROM';


-- $Log$
-- Revision 1.2  2001/06/27 02:05:24  gafton
-- add Log too
--
