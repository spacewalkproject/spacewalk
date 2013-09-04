--
-- Copyright (c) 2008--2011 Red Hat, Inc.
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


-- A view that displays an uncached version of rhnServerNeededCache

CREATE OR REPLACE VIEW
rhnServerNeededView
(
    org_id,
    server_id,
    errata_id,
    package_id,
    package_name_id,
    channel_id
)
AS
SELECT s.org_id,
       sp.server_id,
       x.errata_id,
       up.id,
       up.name_id,
       x.channel_id
    FROM rhnServer s
        join (SELECT sp_sp.server_id, sp_sp.name_id, sp_sp.package_arch_id, max(sp_pe.evr) AS max_evr
                FROM rhnServerPackage sp_sp
                    join rhnPackageEvr sp_pe ON sp_pe.id = sp_sp.evr_id
                    GROUP BY sp_sp.server_id, sp_sp.name_id, sp_sp.package_arch_id) sp ON sp.server_id = s.id
        join rhnPackage up ON up.name_id = sp.name_id
        join rhnPackageEvr upe ON upe.id = up.evr_id AND sp.max_evr < upe.evr
        join rhnPackageUpgradeArchCompat puac ON puac.package_arch_id = sp.package_arch_id AND puac.package_upgrade_arch_id = up.package_arch_id
        join rhnServerChannel sc ON sc.server_id = sp.server_id
        join rhnChannelPackage cp ON cp.package_id = up.id AND cp.channel_id = sc.channel_id
        left join
        (SELECT ep.errata_id, cp.channel_id, ep.package_id
         FROM rhnChannelErrata cp
             join rhnErrataPackage ep ON ep.errata_id = cp.errata_id) x
            ON x.channel_id = sc.channel_id AND x.package_id = cp.package_id
;
