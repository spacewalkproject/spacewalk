
CREATE TABLE rhnXccdfIdentsystem
(
    id      NUMBER NOT NULL
                CONSTRAINT rhn_xccdf_identsytem_id_pk PRIMARY KEY
                USING INDEX TABLESPACE [[64k_tbs]],
    system  VARCHAR2(80) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_xccdf_identsystem_id_uq
    ON rhnXccdfIdentsystem (system)
    TABLESPACE [[64k_tbs]]
    NOLOGGING;

CREATE SEQUENCE rhn_xccdf_identsytem_id_seq;
