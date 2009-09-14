-- created by Oraschemadoc Mon Aug 31 10:54:42 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "MIM1"."NAME_JOIN" (sep_in IN VARCHAR2, ugi_in IN user_group_name_t)
RETURN VARCHAR2
deterministic
IS
	ret	VARCHAR2(4000);
	i	BINARY_INTEGER;
BEGIN
	ret := '';
	i := ugi_in.FIRST;

	IF i IS NULL
	THEN
		RETURN ret;
	END IF;

	ret := ugi_in(i);
	i := ugi_in.NEXT(i);

	WHILE i IS NOT NULL
	LOOP
		ret := ret || sep_in || ugi_in(i);
		i := ugi_in.NEXT(i);
	END LOOP;

	RETURN ret;
END;
 
/
