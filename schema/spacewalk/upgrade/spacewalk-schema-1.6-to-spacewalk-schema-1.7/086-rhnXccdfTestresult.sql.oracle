
CREATE TABLE rhnXccdfTestresult
(
    id             NUMBER NOT NULL
                       CONSTRAINT rhn_xccdf_tresult_id_pk PRIMARY KEY
                       USING INDEX TABLESPACE [[2m_tbs]],
    server_id      NUMBER NOT NULL
                       CONSTRAINT rhn_xccdf_tresult_srvr_fk
                           REFERENCES rhnServer (id)
                           ON DELETE CASCADE,
    action_scap_id NUMBER NOT NULL
                       CONSTRAINT rhn_xccdf_tresult_act_fk
                           REFERENCES rhnActionScap (id)
                           ON DELETE CASCADE,
    benchmark_id   NUMBER NOT NULL
                       CONSTRAINT rhn_xccdf_tresult_bench_fk
                           REFERENCES rhnXccdfBenchmark (id),
    profile_id     NUMBER NOT NULL
                       CONSTRAINT rhn_xccdf_tresult_profile_fk
                           REFERENCES rhnXccdfProfile (id),
    identifier     VARCHAR2(120) NOT NULL,
    start_time     DATE,
    end_time       DATE NOT NULL,
    errors         BLOB
)
TABLESPACE [[blob]]
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_xccdf_tresult_sa_uq
    ON rhnXccdfTestresult (server_id, action_scap_id)
    TABLESPACE [[2m_tbs]]
    NOLOGGING;

CREATE SEQUENCE rhn_xccdf_tresult_id_seq;
