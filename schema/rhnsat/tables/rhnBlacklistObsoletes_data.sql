--
-- $Id$
--

insert into rhnBlacklistObsoletes
  (name_id, evr_id, package_arch_id, ignore_name_id)
values (
    LOOKUP_PACKAGE_NAME('gated'), LOOKUP_EVR(NULL, '3.6', '12'), 
    LOOKUP_PACKAGE_ARCH('i386'), LOOKUP_PACKAGE_NAME('zebra')
);

insert into rhnBlacklistObsoletes
  (name_id, evr_id, package_arch_id, ignore_name_id)
values (
    LOOKUP_PACKAGE_NAME('zebra'), LOOKUP_EVR(NULL, '0.91a', '6'), 
    LOOKUP_PACKAGE_ARCH('i386'), LOOKUP_PACKAGE_NAME('gated')
);

-- 7.2 does not contain gated, so zebra obsoletes gated is valid there

insert into rhnBlacklistObsoletes
  (name_id, evr_id, package_arch_id, ignore_name_id)
select
    LOOKUP_PACKAGE_NAME('gated'), LOOKUP_EVR(NULL, '3.6', '10'), 
    pa.id, LOOKUP_PACKAGE_NAME('zebra')
from rhnPackageArch pa
where pa.label in ('i386', 'alpha');

insert into rhnBlacklistObsoletes
  (name_id, evr_id, package_arch_id, ignore_name_id)
select
    LOOKUP_PACKAGE_NAME('zebra'), LOOKUP_EVR(NULL, '0.91a', '3'), 
    pa.id, LOOKUP_PACKAGE_NAME('gated')
from rhnPackageArch pa
where pa.label in ('i386', 'alpha');

commit;

-- $Log$
-- Revision 1.5  2003/02/10 22:56:02  misa
-- bugzilla: 83597  We cannot generate the data automagically, or we'll catch unwanted packages
--
-- Revision 1.4  2003/02/10 21:45:30  misa
-- bugzilla: 83596  Remove duplicate entries
--
-- Revision 1.3  2003/02/07 17:46:46  pjones
-- rework rhnBlacklistObsoletes
--
