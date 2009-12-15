-- created by Oraschemadoc Mon Aug 31 10:54:41 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE PROCEDURE "MIM1"."QUEUE_ERRATA" (errata_id_in IN NUMBER)
IS
BEGIN
	INSERT INTO rhnSNPErrataQueue (errata_id) VALUES (errata_id_in);
EXCEPTION
	WHEN DUP_VAL_ON_INDEX THEN
	     UPDATE rhnSNPErrataQueue SET processed = 0 WHERE errata_id = errata_id_in;
END;
 
/
