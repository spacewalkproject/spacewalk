
update rhn_config_parameter
set value = '/opt' || value
where value like '/home/nocpulse/%';

