--
-- $Id$
--

CREATE OR REPLACE FUNCTION
LOOKUP_PACKAGE_CAPABILITY(name_in IN VARCHAR2, 
    version_in IN VARCHAR2 DEFAULT NULL)
RETURN NUMBER
IS
	PRAGMA AUTONOMOUS_TRANSACTION;
	name_id		NUMBER;
BEGIN
	IF version_in IS NULL THEN
		SELECT id
		  INTO name_id
		  FROM rhnPackageCapability
		 WHERE name = name_in
		   AND version IS NULL;
	ELSE
		SELECT id
		  INTO name_id
		  FROM rhnPackageCapability
		 WHERE name = name_in
		   AND version = version_in;
	END IF;
	RETURN name_id;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
            INSERT INTO rhnPackageCapability (id, name, version) 
                VALUES (rhn_pkg_capability_id_seq.nextval, name_in, version_in)
                RETURNING id INTO name_id;
            COMMIT;
	RETURN name_id;
END;
/
SHOW ERRORS

-- $Log$
-- Revision 1.1  2003/03/03 16:46:51  misa
-- bugzilla: 83674  Reworked the schema for package removal
--
