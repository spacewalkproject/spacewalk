--
-- $Id$
--

CREATE OR REPLACE FUNCTION
LOOKUP_SOURCE_NAME(name_in IN VARCHAR2)
RETURN NUMBER
IS
	PRAGMA AUTONOMOUS_TRANSACTION;
	source_id	NUMBER;
BEGIN
        select	id into source_id
        from	rhnSourceRPM 
        where	name = name_in;

        RETURN source_id;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
            insert into rhnSourceRPM(id, name)
                    values (rhn_sourcerpm_id_seq.nextval, name_in)
                    returning id into source_id;
            COMMIT;
            RETURN source_id;
END;
/
SHOW ERRORS

-- $Log$
-- Revision 1.5  2002/05/13 22:53:38  pjones
-- cvs id/log
-- some (note enough) readability fixes
--
