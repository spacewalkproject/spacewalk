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

CREATE OR REPLACE FUNCTION
LOOKUP_EVR(e_in IN VARCHAR, v_in IN VARCHAR, r_in IN VARCHAR)
RETURNS NUMERIC
AS
$$
DECLARE
       evr_id          NUMERIC;
BEGIN
        SELECT id INTO evr_id
          FROM rhnPackageEvr
         WHERE ((epoch IS NULL and e_in IS NULL) OR (epoch = e_in))
           AND version = v_in AND release = r_in;
            
        IF NOT FOUND THEN
		INSERT INTO rhnPackageEvr (id, epoch, version, release, evr)
            VALUES (nextval('rhn_pkg_evr_seq'), e_in, v_in, r_in,EVR_T(e_in, v_in, r_in));

            evr_id := currval('rhn_pkg_evr_seq');
        END IF;

        RETURN evr_id;
END;
$$ LANGUAGE PLPGSQL;
