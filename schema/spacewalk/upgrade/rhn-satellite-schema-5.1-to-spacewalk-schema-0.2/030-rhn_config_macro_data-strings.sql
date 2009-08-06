
update rhn_config_macro
set description = 'Spacewalk administrator email'
where environment = 'LICENSE'
	and name = 'RHN_ADMIN_EMAIL';

update rhn_config_macro
set description = 'Spacewalk database name '
where environment = 'LICENSE'
	and name = 'RHN_DB_NAME';

update rhn_config_macro
set description = 'Spacewalk database password'
where environment = 'LICENSE'
	and name = 'RHN_DB_PASSWD';

update rhn_config_macro
set description = 'Spacewalk Database table owner'
where environment = 'LICENSE'
	and name = 'RHN_DB_TABLE_OWNER';

update rhn_config_macro
set description = 'Spacewalk database username'
where environment = 'LICENSE'
	and name = 'RHN_DB_USERNAME';

update rhn_config_macro
set description = 'Spacewalk hostname (FQDN)'
where environment = 'LICENSE'
	and name = 'RHN_SAT_HOSTNAME';

update rhn_config_macro
set description = 'Spacewalk webserver port (80 for http, 443 for https)'
where environment = 'LICENSE'
	and name = 'RHN_SAT_WEB_PORT';

