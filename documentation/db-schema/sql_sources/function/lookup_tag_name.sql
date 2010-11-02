-- created by Oraschemadoc Tue Nov  2 08:33:19 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "SPACEWALK"."LOOKUP_TAG_NAME" (name_in IN VARCHAR2)
RETURN NUMBER
IS
	PRAGMA AUTONOMOUS_TRANSACTION;
	name_id     NUMBER;
BEGIN
        select id into name_id
	  from rhnTagName
	 where name = name_in;

        RETURN name_id;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
            insert into rhnTagName(id, name)
                    values (rhn_tagname_id_seq.nextval, name_in)
                    returning id into name_id;
            COMMIT;
            RETURN name_id;
END;
 
/
