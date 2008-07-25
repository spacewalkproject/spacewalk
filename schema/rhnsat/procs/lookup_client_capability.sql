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
LOOKUP_CLIENT_CAPABILITY(name_in IN VARCHAR2)
RETURN NUMBER
IS
	PRAGMA AUTONOMOUS_TRANSACTION;
	cap_name_id		NUMBER;
BEGIN
	SELECT id
          INTO cap_name_id
          FROM rhnClientCapabilityName
         WHERE name = name_in;

	RETURN cap_name_id;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
            INSERT INTO rhnClientCapabilityName (id, name) 
                VALUES (rhn_client_capname_id_seq.nextval, name_in)
                RETURNING id INTO cap_name_id;
            COMMIT;
	RETURN cap_name_id;
END;
/
SHOW ERRORS

-- $Log$
-- Revision 1.1  2003/07/21 22:30:04  misa
-- bugzilla: none  Lookup function for capabilities
--
--
