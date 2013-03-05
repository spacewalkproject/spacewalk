
CREATE TABLE rhnXccdfProfile
(
    id            NUMBER NOT NULL
                      CONSTRAINT rhn_xccdf_profile_id_pk PRIMARY KEY
                      USING INDEX TABLESPACE [[64k_tbs]],
    identifier    VARCHAR2(120) NOT NULL,
    title         VARCHAR2(120) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_xccdf_profile_it_uq
    ON rhnXccdfProfile (identifier, title)
    TABLESPACE [[64k_tbs]]
    NOLOGGING;

CREATE SEQUENCE rhn_xccdf_profile_id_seq;
