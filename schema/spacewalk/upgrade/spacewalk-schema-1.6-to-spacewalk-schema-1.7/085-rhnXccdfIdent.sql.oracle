
CREATE TABLE rhnXccdfIdent
(
    id              NUMBER NOT NULL
                        CONSTRAINT rhn_xccdf_ident_id_pk PRIMARY KEY
                        USING INDEX TABLESPACE [[2m_tbs]],
    identsystem_id  NUMBER NOT NULL
                        CONSTRAINT rhn_xccdf_ident_system_fk
                            REFERENCES rhnXccdfIdentsystem (id),
    identifier      VARCHAR (20) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_xccdf_ident_isi_uq
    ON rhnXccdfIdent (identsystem_id, identifier)
    TABLESPACE [[2m_tbs]]
    NOLOGGING;

CREATE SEQUENCE rhn_xccdf_ident_id_seq;
