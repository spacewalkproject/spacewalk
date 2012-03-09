delete from rhn_config_macro where name='CFDB_NOTIF_PASSWD';
delete from rhn_config_macro where name='CFDB_PASSWD';
delete from rhn_config_macro where name='RHN_DB_PASSWD';
delete from rhn_config_macro where name='CSDB_PASSWD';

delete from rhn_config_parameter where group_name='cf_db' and name='password';
delete from rhn_config_parameter where group_name='cf_db' and name='portal_password';
delete from rhn_config_parameter where group_name='cf_db' and name='proxy_password';
delete from rhn_config_parameter where group_name='cf_db' and name='ui_password';
delete from rhn_config_parameter where group_name='cf_db' and name='notification_password';
delete from rhn_config_parameter where group_name='cs_db' and name='password';
