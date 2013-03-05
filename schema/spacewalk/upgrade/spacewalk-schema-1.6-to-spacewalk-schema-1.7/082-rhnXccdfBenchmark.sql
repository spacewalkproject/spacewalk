
CREATE TABLE rhnXccdfBenchmark
(
    id            NUMBER NOT NULL
                      CONSTRAINT rhn_xccdf_benchmark_id_pk PRIMARY KEY
                      USING INDEX TABLESPACE [[64k_tbs]],
    identifier    VARCHAR2(120) NOT NULL,
    version       VARCHAR2(80) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_xccdf_benchmark_iv_uq
    ON rhnXccdfBenchmark (identifier, version)
    TABLESPACE [[64k_tbs]]
    NOLOGGING;

CREATE SEQUENCE rhn_xccdf_benchmark_id_seq;
