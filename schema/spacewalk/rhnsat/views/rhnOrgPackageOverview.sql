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

create or replace view
rhnOrgPackageOverview
as
select
    p.org_id org_id,
    cpac.channel_arch_id,
    p.id package_id,
    rhn_package.canonical_name(p_name.name, p_evr.evr, pa.name) package_nvrea
from
    rhnPackageName p_name,
    rhnPackageEVR p_evr,
    rhnPackageArch pa,
    rhnChannelPackageArchCompat cpac,
    rhnPackage p
where
        p_name.id = p.name_id
    and p_evr.id = p.evr_id
    and cpac.package_arch_id = p.package_arch_id
    and p.package_arch_id = pa.id
order by package_nvrea, p.created
/
	 

--
-- Revision 1.5  2002/11/14 17:20:34  pjones
-- arch -> *_arch_id and archCompat changes
--
-- Revision 1.4  2001/07/05 05:35:44  cturner
-- working on channel editing views, plus an index on rhnpackage for org id
--
-- Revision 1.3  2001/07/01 17:40:23  cturner
-- renaming rhn*PackageObj to rhn*Package.  more work on conversions.
--
-- Revision 1.2  2001/07/01 01:54:57  gafton
-- fomat the view
--
-- Revision 1.1  2001/06/28 00:34:25  cturner
-- view plus ancillary changes for an overview of "what packages are
-- available for my org to put in a channel?"  view still needs work,
-- but this is a start.  pl/sql packages are really nice.
--
-- Revision 1.3  2001/06/27 02:05:25  gafton
-- add Log too
