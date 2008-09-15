-- created by Oraschemadoc Fri Jun 13 14:06:12 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "RHNSAT"."LOOKUP_SERVER_ARCH" (label_in IN VARCHAR2)
RETURN NUMBER
DETERMINISTIC
IS
	server_arch_id		NUMBER;
BEGIN
	SELECT id
          INTO server_arch_id
          FROM rhnServerArch
         WHERE label = label_in;
	RETURN server_arch_id;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
            rhn_exception.raise_exception('server_arch_not_found');
END;
 
/
