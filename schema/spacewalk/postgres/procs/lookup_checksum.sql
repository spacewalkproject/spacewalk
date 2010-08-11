-- oracle equivalent source sha1 06adc1fe05d935d97f85b2a98610d6919b4b364e
--
-- Copyright (c) 2010 Red Hat, Inc.
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
LOOKUP_CHECKSUM(checksum_type_in IN VARCHAR, checksum_in IN VARCHAR)
RETURNS NUMERIC
AS
$$
DECLARE
        checksum_id     NUMERIC;
BEGIN
        if checksum_in is null then
                return null;
        end if;

        SELECT c.id
          INTO checksum_id
          FROM rhnChecksumView c
         WHERE c.checksum = checksum_in
           AND c.checksum_type = checksum_type_in;

        IF NOT FOUND THEN
            INSERT INTO rhnChecksum (id, checksum_type_id, checksum)
                 VALUES (nextval('rhnchecksum_seq'),
                        (select id from rhnChecksumType where label = checksum_type_in),
                        checksum_in)
                RETURNING id INTO checksum_id;
        END IF;

        RETURN checksum_id;
END;
$$
language plpgsql;
