
ALTER TABLE rhnXccdfRuleresult ADD id NUMBER;

CREATE SEQUENCE rhn_xccdf_rresult_id_seq;

UPDATE rhnXccdfRuleresult SET id = rhn_xccdf_rresult_id_seq.nextval;

ALTER TABLE rhnXccdfRuleresult MODIFY id NUMBER NOT NULL;

ALTER TABLE rhnXccdfRuleresult
    ADD CONSTRAINT rhn_xccdf_rresult_id_pk PRIMARY KEY (id)
    USING INDEX TABLESPACE [[8m_tbs]];
