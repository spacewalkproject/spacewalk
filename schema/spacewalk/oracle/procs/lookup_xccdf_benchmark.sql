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
lookup_xccdf_benchmark(identifier_in IN VARCHAR2, version_in IN VARCHAR2)
RETURN NUMBER
IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    benchmark_id NUMBER;
BEGIN
    SELECT id
        INTO benchmark_id
        FROM rhnXccdfBenchmark
        WHERE identifier = identifier_in
            AND version = version_in;
    RETURN benchmark_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        INSERT INTO rhnXccdfBenchmark (id, identifier, version)
            VALUES (rhn_xccdf_benchmark_id_seq.nextval,
                identifier_in, version_in)
            RETURNING id INTO benchmark_id;
        COMMIT;
    RETURN benchmark_id;
END lookup_xccdf_benchmark;
/
SHOW ERRORS
