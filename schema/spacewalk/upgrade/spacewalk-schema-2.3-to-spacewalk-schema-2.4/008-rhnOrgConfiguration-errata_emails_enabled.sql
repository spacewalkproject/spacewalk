ALTER TABLE rhnOrgConfiguration ADD errata_emails_enabled CHAR(1)
    DEFAULT('Y') NOT NULL
    CONSTRAINT rhn_org_conf_errata_emails_chk
    CHECK (errata_emails_enabled in ('Y', 'N'));
