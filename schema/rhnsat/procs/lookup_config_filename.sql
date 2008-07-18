--
-- $Id$
--

CREATE OR REPLACE FUNCTION
LOOKUP_CONFIG_FILENAME(name_in IN VARCHAR2)
RETURN NUMBER
IS
	PRAGMA AUTONOMOUS_TRANSACTION;
	name_id		NUMBER;
BEGIN
	SELECT id
          INTO name_id
          FROM rhnConfigFileName
         WHERE path = name_in;

	RETURN name_id;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
            INSERT INTO rhnConfigFileName (id, path) 
                VALUES (rhn_cfname_id_seq.nextval, name_in)
                RETURNING id INTO name_id;
            COMMIT;
	RETURN name_id;
END;
/
SHOW ERRORS

-- $Log$
-- Revision 1.1  2003/07/31 16:55:34  cturner
-- lookup helper function and blob for configfiles
--
