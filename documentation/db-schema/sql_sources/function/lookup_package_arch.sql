-- created by Oraschemadoc Fri Jan 22 13:41:04 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "SPACEWALK"."LOOKUP_PACKAGE_ARCH" (label_in IN VARCHAR2)
RETURN NUMBER
IS
	package_arch_id		NUMBER;
BEGIN
   if label_in is null then
      return null;
   end if;

	SELECT id
          INTO package_arch_id
          FROM rhnPackageArch
         WHERE label = label_in;

	RETURN package_arch_id;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
            rhn_exception.raise_exception('package_arch_not_found');
END;
 
/
