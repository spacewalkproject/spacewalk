--
-- Copyright (c) 2008 Red Hat, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
-- 
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation. 
--
--
-- $Id$
--

CREATE OR REPLACE FUNCTION
LOOKUP_TRANSACTION_PACKAGE(o_in IN VARCHAR2, n_in IN VARCHAR2, 
    e_in IN VARCHAR2, v_in IN VARCHAR2, r_in IN VARCHAR2, a_in IN VARCHAR2)
RETURN NUMBER
IS
	PRAGMA AUTONOMOUS_TRANSACTION;
        o_id        NUMBER;
        n_id        NUMBER;
	e_id	    NUMBER;
        p_arch_id   NUMBER;
        tp_id       NUMBER;
BEGIN
	BEGIN
	    SELECT id
	      INTO o_id
	      FROM rhnTransactionOperation
	     WHERE label = o_in;
	EXCEPTION
	    WHEN NO_DATA_FOUND THEN
		rhn_exception.raise_exception('invalid_transaction_operation');
	END;

	SELECT LOOKUP_PACKAGE_NAME(n_in)
	  INTO n_id
	  FROM dual;

	SELECT LOOKUP_EVR(e_in, v_in, r_in)
	  INTO e_id
	  FROM dual;

	p_arch_id := NULL;
	IF a_in IS NOT NULL
	THEN
		SELECT LOOKUP_PACKAGE_ARCH(a_in)
		  INTO p_arch_id
		  FROM dual;
	END IF;

	SELECT id
	  INTO tp_id
	  FROM rhnTransactionPackage
	 WHERE operation = o_id
	   AND name_id = n_id
	   AND evr_id = e_id
	   AND (package_arch_id = p_arch_id OR (p_arch_id IS NULL AND package_arch_id IS NULL));
	RETURN tp_id;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
	    INSERT INTO rhnTransactionPackage 
		(id, operation, name_id, evr_id, package_arch_id)
	    VALUES (rhn_transpack_id_seq.nextval, o_id, n_id, e_id, p_arch_id)
	    RETURNING id INTO tp_id;
	    COMMIT;
	    RETURN tp_id;
END;
/
SHOW ERRORS

-- $Log$
-- Revision 1.2  2003/07/09 16:29:33  cturner
-- update some strings and change lookup_transaction_package to throw an exception instead of SILENTLY RETURNING NULL
--
-- Revision 1.1  2003/07/01 14:52:35  misa
-- bugzilla: 90376  Need function to add transactions in the DB
--
