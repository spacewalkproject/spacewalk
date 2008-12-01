

update rhn_config_parameter set value='/var/lib/notification/queue/ack_queue' where name='ack_queue_dir';
update rhn_config_parameter set value='/var/lib/notification/queue/alert_queue' where name='alert_queue_dir';

update rhn_config_parameter set value='/etc/notification' where group_name='notification' and name='config_dir';

commit;
