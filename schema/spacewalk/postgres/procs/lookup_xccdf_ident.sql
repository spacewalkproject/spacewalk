-- oracle equivalent source sha1 690bbd47c01d39c135da9a54dbaacb77f7f206bc
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
lookup_xccdf_ident(system_in IN VARCHAR, identifier_in IN VARCHAR)
RETURNS NUMERIC
AS
$$
DECLARE
    xccdf_ident_id NUMERIC;
    ident_sys_id NUMERIC;
BEGIN
    SELECT id
        INTO ident_sys_id
        FROM rhnXccdfIdentsystem
        WHERE system = system_in;
    IF NOT FOUND THEN
        INSERT INTO rhnXccdfIdentsystem (id, system)
            VALUES (nextval('rhn_xccdf_identsytem_id_seq'), system_in)
            RETURNING id INTO ident_sys_id;
    END IF;

    SELECT id
        INTO xccdf_ident_id
        FROM rhnXccdfIdent
        WHERE identsystem_id = ident_sys_id
            AND identifier = identifier_in;
    IF NOT FOUND THEN
        INSERT INTO rhnXccdfIdent (id, identsystem_id, identifier)
            VALUES (nextval('rhn_xccdf_ident_id_seq'), ident_sys_id, identifier_in)
            RETURNING id INTO xccdf_ident_id;
    END IF;
    RETURN xccdf_ident_id;
END;
$$ LANGUAGE PLPGSQL;
