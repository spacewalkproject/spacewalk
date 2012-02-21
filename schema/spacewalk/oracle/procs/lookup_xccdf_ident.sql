--
-- Copyright (c) 2012 Red Hat, Inc.
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

CREATE OR REPLACE FUNCTION
lookup_xccdf_ident(system_in IN VARCHAR2, identifier_in IN VARCHAR2)
RETURN NUMBER
IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    xccdf_ident_id NUMBER;
    ident_sys_id NUMBER;
BEGIN
    BEGIN
        SELECT id
            INTO ident_sys_id
            FROM rhnXccdfIdentsystem
            WHERE system = system_in;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            INSERT INTO rhnXccdfIdentsystem (id, system)
                VALUES (rhn_xccdf_identsytem_id_seq.nextval, system_in)
                RETURNING id INTO ident_sys_id;
    END;

    SELECT id
        INTO xccdf_ident_id
        FROM rhnXccdfIdent
        WHERE identsystem_id = ident_sys_id
            AND identifier = identifier_in;
    RETURN xccdf_ident_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        INSERT INTO rhnXccdfIdent (id, identsystem_id, identifier)
            VALUES (rhn_xccdf_ident_id_seq.nextval, ident_sys_id, identifier_in)
            RETURNING id INTO xccdf_ident_id;
        COMMIT;
    RETURN xccdf_ident_id;
END lookup_xccdf_ident;
/
SHOW ERRORS
