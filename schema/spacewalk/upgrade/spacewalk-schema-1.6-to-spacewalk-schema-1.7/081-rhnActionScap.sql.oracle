
CREATE TABLE rhnActionScap
(
    id               NUMBER NOT NULL
                         CONSTRAINT rhn_act_scap_id_pk PRIMARY KEY
                         USING INDEX TABLESPACE [[4m_tbs]],
    action_id        NUMBER NOT NULL
                         CONSTRAINT rhn_act_scap_act_fk
                             REFERENCES rhnAction (id)
                             ON DELETE CASCADE,
    path             VARCHAR2(2048) NOT NULL,
    parameters       BLOB
)
TABLESPACE [[blob]]
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_act_scap_aid_idx
    ON rhnActionScap (action_id)
    TABLESPACE [[4m_tbs]]
    NOLOGGING;

CREATE INDEX rhn_act_scap_path_idx
    ON rhnActionScap (path)
    TABLESPACE [[4m_tbs]]
    NOLOGGING;

CREATE SEQUENCE rhn_act_scap_id_seq;
