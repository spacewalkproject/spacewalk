
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
