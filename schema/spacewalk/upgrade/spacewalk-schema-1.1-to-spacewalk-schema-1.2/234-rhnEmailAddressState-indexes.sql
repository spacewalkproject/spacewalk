ALTER TABLE rhnEmailAddressState DROP CONSTRAINT rhn_eastate_label_uq;

ALTER TABLE rhnEmailAddressState
    ADD CONSTRAINT rhn_eastate_label_uq UNIQUE (label)
    USING INDEX TABLESPACE [[64k_tbs]];

DROP INDEX rhn_eastate_label_id_idx;
