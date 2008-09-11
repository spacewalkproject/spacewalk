--
-- $Id$
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
/

-- $Log$
-- Revision 1.2  2002/05/15 21:30:09  pjones
-- id/log
--
