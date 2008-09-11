--
-- $Id$
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

-- $Log$
-- Revision 1.2  2002/05/13 22:53:38  pjones
-- cvs id/log
-- some (note enough) readability fixes
--
