

update rhn_config_parameter set value='/var/lib/notification/queue/ack_queue' where name='ack_queue_dir';
update rhn_config_parameter set value='/var/lib/notification/queue/alert_queue' where name='alert_queue_dir';

commit;
