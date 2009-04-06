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

-- the next two views are basically the same.  the first, though, has an outer join to
-- the errata stuff, in case there are packages the server needs that haven't been
-- errata'd (ie, the fringe case)

CREATE OR REPLACE PROCEDURE
queue_errata(errata_id_in IN NUMBER)
IS
BEGIN
	INSERT INTO rhnSNPErrataQueue (errata_id) VALUES (errata_id_in);
EXCEPTION
	WHEN DUP_VAL_ON_INDEX THEN
	     UPDATE rhnSNPErrataQueue SET processed = 0 WHERE errata_id = errata_id_in;
END;
/
SHOW ERRORS

--
-- Revision 1.2  2002/05/13 22:53:38  pjones
-- cvs id/log
-- some (note enough) readability fixes
--
