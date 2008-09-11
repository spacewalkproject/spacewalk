set heading off;
set lines 80;
set pages 4000;

select pn.name || ' ' ||
	pe.version || ' ' ||
	pe.release || ' ' ||
	nvl(pe.epoch,'(none)') || ' ' ||
	pa.label
from
	rhnpackagename pn,
	rhnpackageevr pe,
	rhnpackagearch pa,
	rhnpackage p,
	rhnchannelpackage cp,
	rhnchannel c
where
	cp.package_id = p.id
	and cp.channel_id = c.id
	and c.label = '&label'
	and p.package_arch_id = pa.id
	and p.name_id = pn.id
	and p.evr_id = pe.id
order by
   pn.name
/
