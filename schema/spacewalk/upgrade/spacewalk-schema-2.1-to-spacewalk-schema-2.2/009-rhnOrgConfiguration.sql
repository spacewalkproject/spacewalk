ALTER TABLE rhnOrgConfiguration ADD create_default_sg CHAR(1)
    default('N') not null
    constraint rhn_org_cong_deforg_chk
    check (create_default_sg in ('Y', 'N'));
