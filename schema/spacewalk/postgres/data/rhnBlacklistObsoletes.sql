--
-- Copyright (c) 2008 Red Hat, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
-- 
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation. 
--
--
--
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

--
-- Revision 1.5  2003/02/10 22:56:02  misa
-- bugzilla: 83597  We cannot generate the data automagically, or we'll catch unwanted packages
--
-- Revision 1.4  2003/02/10 21:45:30  misa
-- bugzilla: 83596  Remove duplicate entries
--
-- Revision 1.3  2003/02/07 17:46:46  pjones
-- rework rhnBlacklistObsoletes
--
