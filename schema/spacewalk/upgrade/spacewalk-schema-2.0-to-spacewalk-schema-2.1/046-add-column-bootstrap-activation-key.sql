ALTER TABLE rhnactivationkey ADD bootstrap CHAR(1) DEFAULT ('N') NOT NULL;
ALTER TABLE rhnactivationkey ADD CONSTRAINT rhn_act_key_bootstrap_ck CHECK (bootstrap in ('Y', 'N'));


