-- created by Oraschemadoc Fri Jan 22 13:41:04 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "MIM_H1"."LOOKUP_TAG" (org_id_in IN NUMBER, name_in IN VARCHAR2)
RETURN NUMBER
IS
	PRAGMA AUTONOMOUS_TRANSACTION;
	tag_id     NUMBER;
BEGIN
        select id into tag_id
	  from rhnTag
	 where org_id = org_id_in
	   and name_id = lookup_tag_name(name_in);

        RETURN tag_id;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
            insert into rhnTag(id, org_id, name_id)
                    values (rhn_tag_id_seq.nextval, org_id_in, lookup_tag_name(name_in))
                    returning id into tag_id;
            COMMIT;
            RETURN tag_id;
END;
 
/
