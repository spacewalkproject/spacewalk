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

CREATE OR REPLACE VIEW rhnServerErrataTypeView
(
    	server_id,
	errata_id,
	errata_type,
	package_count
)
AS
SELECT
    	SNPC.server_id,
	SNPC.errata_id,
	E.advisory_type,
	COUNT(SNPC.package_id)
FROM    rhnErrata E,
    	rhnServerNeededPackageCache SNPC
WHERE   E.id = SNPC.errata_id
GROUP BY SNPC.server_id, SNPC.errata_id, E.advisory_type
;

