
update rhn_config_macro set definition='/usr/bin' where name='NPBIN';
update rhn_config_macro set definition='/etc/nocpulse' where name='NPETC';
update rhn_config_macro set definition='/var/lib/%{USER}' where name='NPHOME';
update rhn_config_macro set definition='/var/log/%{USER}' where name='NPVAR';

insert into rhn_config_macro(environment,name,definition,description,editable,last_update_user,last_update_date)     values ( 'ALL', 'NPLIB', '/var/lib/%{USER}', 'Production user data directory', '0', 'system',sysdate);

commit;
