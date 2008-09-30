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
--
--

CREATE OR REPLACE FUNCTION
LOOKUP_PACKAGE_DELTA(n_in IN VARCHAR2)
RETURN NUMBER
IS
	PRAGMA AUTONOMOUS_TRANSACTION;
	name_id         NUMBER;
BEGIN
	SELECT id INTO name_id
	  FROM rhnPackageDelta
	 WHERE label = n_in;
	  
	RETURN name_id;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
	    INSERT INTO rhnPackageDelta (id, label)
	    VALUES (rhn_packagedelta_id_seq.nextval, n_in)
	    RETURNING id INTO name_id;
	COMMIT;
	RETURN name_id;
END;
/
SHOW ERRORS

--
-- Revision 1.1  2003/06/30 22:14:16  misa
-- bugzilla: none  Added a lookup function for package delta
--
--
