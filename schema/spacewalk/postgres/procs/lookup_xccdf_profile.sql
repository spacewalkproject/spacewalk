-- oracle equivalent source sha1 883bbbca80021e8954b5ecc532bed962416807ad
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
lookup_xccdf_profile(identifier_in IN VARCHAR, title_in IN VARCHAR)
RETURNS NUMERIC
AS
$$
DECLARE
    profile_id NUMERIC;
BEGIN
    SELECT id
        INTO profile_id
        FROM rhnXccdfProfile
        WHERE identifier = identifier_in
            AND title = title_in;

    IF NOT FOUND THEN
        INSERT INTO rhnXccdfProfile (id, identifier, title)
            VALUES (nextval('rhn_xccdf_profile_id_seq'),
                identifier_in, title_in)
            RETURNING id INTO profile_id;
    END IF;

    RETURN profile_id;
END;
$$ LANGUAGE PLPGSQL;
