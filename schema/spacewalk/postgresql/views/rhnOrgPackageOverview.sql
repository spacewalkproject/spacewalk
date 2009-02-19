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
    p.org_id as org_id,
    cpac.as channel_arch_id,
    p.id as package_id,
    rhn_package.canonical_name(p_name.name, p_evr.evr, pa.name) as package_nvrea
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
;

