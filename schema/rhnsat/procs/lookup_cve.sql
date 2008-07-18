--
-- $Id$
--

CREATE OR REPLACE FUNCTION
LOOKUP_CVE(name_in IN VARCHAR2)
RETURN NUMBER
IS
	PRAGMA AUTONOMOUS_TRANSACTION;
	name_id		NUMBER;
BEGIN
	SELECT id
          INTO name_id
          FROM rhnCve
         WHERE name = name_in;

	RETURN name_id;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
            INSERT INTO rhnCve (id, name) 
                VALUES (rhn_cve_id_seq.nextval, name_in)
                RETURNING id INTO name_id;
            COMMIT;
	RETURN name_id;
END LOOKUP_CVE;
/
SHOW ERRORS

-- $Log$
-- Revision 1.2  2004/07/07 21:48:25  pjones
-- bugzilla: 123370 -- "end lookup_cve", to be consistent with the dbchange way
--
-- Revision 1.1  2004/07/07 17:27:36  bretm
-- bugzilla:  123370
--
-- lookup_cve utility function
--
--
