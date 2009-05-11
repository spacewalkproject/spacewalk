alter table rhnKickstartScript  add (
      raw_script char(1) default('Y')
      constraint rhn_ksscript_raw_nn not null
      check (raw_script in ('Y','N')));
