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

CREATE OR REPLACE VIEW
rhnServerOutdatedPackages
(
    server_id,
    package_name_id,
    package_evr_id,    
    package_nvre,
    errata_id,
    errata_advisory
)
AS
SELECT DISTINCT SNPC.server_id,
       P.name_id, 
       P.evr_id, 
       PN.name || '-' || PE.evr.as_vre_simple(),
       E.id,
       E.advisory
  FROM rhnPackageName PN,
       rhnPackageEVR PE,
       rhnPackage P,
       rhnServerNeededPackageCache SNPC
         left outer join
        rhnErrata E
          on SNPC.errata_id = E.id
 WHERE SNPC.package_id = P.id
   AND P.name_id = PN.id
   AND P.evr_id = PE.id;

