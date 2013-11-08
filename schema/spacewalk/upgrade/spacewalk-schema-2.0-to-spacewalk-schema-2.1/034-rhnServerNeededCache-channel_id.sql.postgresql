-- oracle equivalent source sha1 be9ef654294e2f657114e022aadfea74737ba54e


ALTER TABLE rhnServerNeededCache ADD
        channel_id NUMERIC
                CONSTRAINT rhn_sncp_cid_fk
                REFERENCES rhnChannel (id)
                ON DELETE CASCADE;

CREATE INDEX rhn_snc_cid_idx
    ON rhnServerNeededCache (channel_id)
    ;
