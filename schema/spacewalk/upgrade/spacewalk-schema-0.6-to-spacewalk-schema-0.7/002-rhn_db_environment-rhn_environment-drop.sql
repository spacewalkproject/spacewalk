alter table rhn_config_macro drop constraint rhn_confm_envir_environment_fk;
alter table rhn_config_macro drop primary key;
drop index rhn_confm_environment_name_pk;

create unique index rhn_confm_name_pk
    on rhn_config_macro (name) 
    tablespace [[2m_tbs]];
alter table rhn_config_macro add constraint rhn_confm_name_pk primary key (name);

alter table rhn_config_macro drop column environment;

drop table rhn_environment;
drop table rhn_db_environment;
