--
-- $Id$
--

CREATE OR REPLACE FUNCTION
LOOKUP_PACKAGE_DELTA(n_in IN VARCHAR2)
RETURN NUMBER
IS
	PRAGMA AUTONOMOUS_TRANSACTION;
	name_id         NUMBER;
BEGIN
	SELECT id INTO name_id
	  FROM rhnPackageDelta
	 WHERE label = n_in;
	  
	RETURN name_id;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
	    INSERT INTO rhnPackageDelta (id, label)
	    VALUES (rhn_packagedelta_id_seq.nextval, n_in)
	    RETURNING id INTO name_id;
	COMMIT;
	RETURN name_id;
END;
/
SHOW ERRORS

-- $Log$
-- Revision 1.1  2003/06/30 22:14:16  misa
-- bugzilla: none  Added a lookup function for package delta
--
--
