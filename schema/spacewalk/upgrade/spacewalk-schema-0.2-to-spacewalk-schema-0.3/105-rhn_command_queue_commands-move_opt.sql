
update rhn_command_queue_commands set command_line=replace(command_line, '/opt/home/nocpulse/bin/', '/usr/bin/');
commit;
