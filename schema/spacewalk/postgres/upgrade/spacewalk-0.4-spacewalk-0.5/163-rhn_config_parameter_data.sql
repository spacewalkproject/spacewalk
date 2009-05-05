
UPDATE rhn_config_parameter SET value='/var/log/nocpulse/enqueue.log'
        WHERE group_name='notification' AND name='enqueue_log';
UPDATE rhn_config_parameter SET value='/var/log/nocpulse/ack_handler.log'
		WHERE group_name='notification' AND name='ack_handler_log';
UPDATE rhn_config_parameter SET value='--cd=/var/log/nocpulse --dir=/var/log/nocpulse/archive /var/log/nocpulse/ack_handler.log enqueue.log generate_config.log notifserver.log.save notifserver-error.log --recreate=ticketlog'
		WHERE group_name='notification' AND name='archive_params';

commit;
