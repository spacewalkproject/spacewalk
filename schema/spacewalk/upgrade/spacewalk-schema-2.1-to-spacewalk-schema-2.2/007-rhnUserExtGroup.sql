ALTER TABLE rhnUserExtGroup ADD org_id NUMBER DEFAULT NULL
    CONSTRAINT rhn_userExtGroup_oid_fk
        REFERENCES web_customer (id)
        ON DELETE CASCADE;

CREATE UNIQUE INDEX rhn_userextgroup_label_oid_uq
    ON rhnUserExtGroup (label, org_id) TABLESPACE [[64k_tbs]];
DROP INDEX rhn_userextgroup_label_uq;
