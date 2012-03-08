delete from rhn_config_macro where name='CFDB_NAME';
delete from rhn_config_macro where name='CSDB_NAME';
delete from rhn_config_macro where name='RHN_DB_NAME';
delete from rhn_config_macro where name='SCDB_NAME';

delete from rhn_config_parameter where group_name='cf_db' and name='name';
delete from rhn_config_parameter where group_name='cs_db' and name='name';
