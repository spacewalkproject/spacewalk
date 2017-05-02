alter table rhnContentSourceFilter drop constraint rhn_csf_source_fk;

alter table rhnContentSourceFilter add constraint rhn_csf_source_fk
  foreign key (source_id)
  references rhnContentSource (id)
  on delete cascade;
