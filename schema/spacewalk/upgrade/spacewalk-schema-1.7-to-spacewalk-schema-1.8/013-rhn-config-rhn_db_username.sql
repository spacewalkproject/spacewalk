delete from rhn_config_macro where name='RHN_DB_USERNAME';

delete from rhn_config_parameter where group_name='cf_db' and name='notification_username';
delete from rhn_config_parameter where group_name='cf_db' and name='portal_username';
delete from rhn_config_parameter where group_name='cf_db' and name='proxy_username';
delete from rhn_config_parameter where group_name='cf_db' and name='ui_username';
delete from rhn_config_parameter where group_name='cf_db' and name='username';
delete from rhn_config_parameter where group_name='cs_db' and name='username';
