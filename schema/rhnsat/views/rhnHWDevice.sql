-- $Id$
--
-- ######## HARDWARE #########
create or replace view 
rhnHWDevice
(id, server_Id, class, bus, detached, device, driver, 
description, vendor_id, device_id, subvendor_Id, subdevice_Id, pcitype)
as
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
	d.prop3,
	d.prop4,
	d.pcitype
from rhnDevice d
where d.class in ('AUDIO', 'MODEM', 'MOUSE', 'NETWORK', 
	        'SCSI', 'OTHER', 'USB', 'VIDEO', 'CAPTURE',
		'SCANNER', 'TAPE', 'RAID', 'SOCKET');


-- $Log$
-- Revision 1.2  2001/06/27 02:05:25  gafton
-- add Log too
--
