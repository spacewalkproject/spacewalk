-- oracle equivalent source sha1 08bbc1262e0794cb1714eb2c55d674c4b0e613b0

ALTER TABLE rhnXccdfRuleresult ADD id NUMERIC;

CREATE SEQUENCE rhn_xccdf_rresult_id_seq;

UPDATE rhnXccdfRuleresult SET id = nextval('rhn_xccdf_rresult_id_seq');

ALTER TABLE rhnXccdfRuleresult ALTER COLUMN id SET NOT NULL;

ALTER TABLE rhnXccdfRuleresult
    ADD CONSTRAINT rhn_xccdf_rresult_id_pk PRIMARY KEY (id);
