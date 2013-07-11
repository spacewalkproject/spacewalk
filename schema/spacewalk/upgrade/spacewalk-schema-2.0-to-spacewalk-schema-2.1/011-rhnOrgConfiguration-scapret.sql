alter table rhnOrgConfiguration
  add scap_retention_period_days
      number default (90)
      constraint rhn_org_conf_scap_reten_chk check (scap_retention_period_days >= 0);
