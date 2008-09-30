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
LOOKUP_PACKAGE_CAPABILITY(name_in IN VARCHAR2, 
    version_in IN VARCHAR2 DEFAULT NULL)
RETURN NUMBER
IS
	PRAGMA AUTONOMOUS_TRANSACTION;
	name_id		NUMBER;
BEGIN
	IF version_in IS NULL THEN
		SELECT id
		  INTO name_id
		  FROM rhnPackageCapability
		 WHERE name = name_in
		   AND version IS NULL;
	ELSE
		SELECT id
		  INTO name_id
		  FROM rhnPackageCapability
		 WHERE name = name_in
		   AND version = version_in;
	END IF;
	RETURN name_id;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
            INSERT INTO rhnPackageCapability (id, name, version) 
                VALUES (rhn_pkg_capability_id_seq.nextval, name_in, version_in)
                RETURNING id INTO name_id;
            COMMIT;
	RETURN name_id;
END;
/
SHOW ERRORS

--
-- Revision 1.1  2003/03/03 16:46:51  misa
-- bugzilla: 83674  Reworked the schema for package removal
--
