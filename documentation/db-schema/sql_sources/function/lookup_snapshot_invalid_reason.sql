-- created by Oraschemadoc Thu Apr 21 10:04:20 2011
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "SPACEWALK"."LOOKUP_SNAPSHOT_INVALID_REASON" (label_in IN VARCHAR2)
RETURN NUMBER
IS
	PRAGMA AUTONOMOUS_TRANSACTION;
	snapshot_invalid_reason_id number;
BEGIN
	SELECT id
          INTO snapshot_invalid_reason_id
          FROM rhnSnapshotInvalidReason
         WHERE label = label_in;

	RETURN snapshot_invalid_reason_id;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
            rhn_exception.raise_exception('invalid_snapshot_invalid_reason');
END;
 
/
