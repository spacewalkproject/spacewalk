-- oracle equivalent source sha1 06ad4b545e7af5b6b04329939b658b4cc4fc725b

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
