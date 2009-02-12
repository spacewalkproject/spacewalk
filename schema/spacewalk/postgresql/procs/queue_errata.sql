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

CREATE OR REPLACE PROCEDURE
queue_errata(errata_id_in IN numeric)
AS
$$
BEGIN
	INSERT INTO rhnSNPErrataQueue (errata_id) VALUES (errata_id_in);
EXCEPTION
	WHEN UNIQUE_VIOLATION THEN
	     UPDATE rhnSNPErrataQueue SET processed = 0 WHERE errata_id = errata_id_in;
END;
$$ language plpgsql;

