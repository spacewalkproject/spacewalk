--
-- $Id$
--

CREATE OR REPLACE FUNCTION
lookup_snapshot_invalid_reason(label_in IN VARCHAR2)
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
SHOW ERRORS

--
-- $Log$
-- Revision 1.1  2003/10/07 20:49:18  pjones
-- bugzilla: 106188
--
-- snapshot invalidation
--
