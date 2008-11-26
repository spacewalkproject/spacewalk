
update rhn_config_macro set definition='/usr/bin' where name='NPBIN';
update rhn_config_macro set definition='/etc/nocpulse' where name='NPETC';
update rhn_config_macro set definition='/var/lib/%{USER}' where name='NPHOME';
update rhn_config_macro set definition='/var/log/%{USER}' where name='NPVAR';

commit;
