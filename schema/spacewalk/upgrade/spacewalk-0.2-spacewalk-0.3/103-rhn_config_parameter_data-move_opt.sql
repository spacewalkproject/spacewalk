
update rhn_config_parameter set value=replace(value, '/opt/nocpulse/TSDBLocalQueue', '/var/log/nocpulse/TSDBLocalQueue');
update rhn_config_parameter set value=replace(value, '/opt/home/nocpulse/var/', '/var/lib/nocpulse/');
update rhn_config_parameter set value=replace(value, '/opt/home/nocpulse/etc', '/etc/nocpulse');
update rhn_config_parameter set value=replace(value, '/opt/home/nocpulse/bin/', '/usr/bin/');
update rhn_config_parameter set value=replace(value, '/opt/home/nocpulse/.ssh', '/var/lib/nocpulse/.ssh');
update rhn_config_parameter set value=replace(value, '/opt/notification/queue', '/var/lib/nocpulse/queue');
update rhn_config_parameter set value=replace(value, '/opt/notification/var', '/var/log/nocpulse');
update rhn_config_parameter set value=replace(value, '/opt/notification/etc', '/etc/nocpulse');
update rhn_config_parameter set value=replace(value, '/opt/notification/tmp', '/var/tmp');
update rhn_config_parameter set value=replace(value, '/opt/notification', '/var/lib/nocpulse');

commit;
