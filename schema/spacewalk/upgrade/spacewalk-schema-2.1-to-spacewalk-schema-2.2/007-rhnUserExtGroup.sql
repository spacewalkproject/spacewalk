ALTER TABLE rhnUserExtGroup ADD org_id NUMBER DEFAULT NULL
    CONSTRAINT rhn_userExtGroup_oid_fk
        REFERENCES web_customer (id)
        ON DELETE CASCADE;
