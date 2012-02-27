-- oracle equivalent source sha1 85e65cbb76b55a91cae4f2103f5c95b4785062e0
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
lookup_xccdf_benchmark(identifier_in IN VARCHAR, version_in IN VARCHAR)
RETURNS NUMERIC
AS
$$
DECLARE
    benchmark_id NUMERIC;
BEGIN
    SELECT id
        INTO benchmark_id
        FROM rhnXccdfBenchmark
        WHERE identifier = identifier_in
            AND version = version_in;

    IF NOT FOUND THEN
        INSERT INTO rhnXccdfBenchmark (id, identifier, version)
            VALUES (nextval('rhn_xccdf_benchmark_id_seq'),
                identifier_in, version_in)
            RETURNING id INTO benchmark_id;
    END IF;

    RETURN benchmark_id;
END;
$$ LANGUAGE PLPGSQL;
