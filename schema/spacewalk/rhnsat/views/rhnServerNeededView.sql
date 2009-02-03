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


-- A view that displays an uncached version of rhnServerNeededCache

CREATE OR REPLACE VIEW
rhnServerNeededView
(
    org_id,
    server_id,
    errata_id,
    package_id,
    package_name_id
)
AS
SELECT   distinct  S.org_id,
         S.id,
         PE.errata_id,
         P.id,
         P.name_id
FROM
         rhnPackage P,
         rhnServerPackageArchCompat SPAC,
         rhnPackageEVR P_EVR,
         rhnPackageEVR SP_EVR,
         rhnServerPackage SP,
         rhnChannelPackage CP,
         rhnServerChannel SC,
         rhnServer S,
         rhnErrataPackage PE,
         rhnChannelErrata EC
WHERE
         SC.server_id = S.id
  AND    SC.channel_id = CP.channel_id
  AND    CP.package_id = P.id
  AND    P.id = PE.package_id (+)
  AND    PE.errata_id = EC.errata_id (+)
  AND    EC.channel_id = SC.channel_id (+)
  AND    p.package_arch_id = spac.package_arch_id
  AND    spac.server_arch_id = s.server_arch_id
  AND    SP_EVR.id = SP.evr_id
  AND    P_EVR.id = P.evr_id
  AND    SP.server_id = S.id
  AND    SP.name_id = P.name_id
  AND    SP.evr_id != P.evr_id
  AND    SP_EVR.evr < P_EVR.evr
  AND    SP_EVR.evr = (SELECT MAX(PE.evr) FROM rhnServerPackage SP2, rhnPackageEvr PE WHERE PE.id = SP2.evr_id AND SP2.server_id = SP.server_id AND SP2.name_id = SP.name_id)
/
