-- created by Oraschemadoc Fri Jan 22 13:41:03 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "SPACEWALK"."LOOKUP_CHECKSUM" (checksum_type_in IN VARCHAR2, checksum_in IN VARCHAR2)
RETURN NUMBER
IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        checksum_id     NUMBER;
BEGIN
        if checksum_in is null then
                return null;
        end if;

        SELECT c.id
          INTO checksum_id
          FROM rhnChecksumView c
         WHERE c.checksum = checksum_in
           AND c.checksum_type = checksum_type_in;

        RETURN checksum_id;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
            INSERT INTO rhnChecksum (id, checksum_type_id, checksum)
                 VALUES (rhnChecksum_seq.nextval,
                        (select id from rhnChecksumType where label = checksum_type_in),
                        checksum_in)
                RETURNING id INTO checksum_id;
            COMMIT;
        RETURN checksum_id;
END;
 
/
