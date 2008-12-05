

update rhn_config_parameter set value='/var/lib/notification/queue/ack_queue' where name='ack_queue_dir';
update rhn_config_parameter set value='/var/lib/notification/queue/alert_queue' where name='alert_queue_dir';

update rhn_config_parameter set value='/etc/notification' where group_name='notification' and name='config_dir';


update rhn_config_parameter set value='%{NPLIB}/trapReceiver/config' where group_name='trapReceiver' and name='config';
update rhn_config_parameter set value='%{NPLIB}/trapReceiver/mibs' where group_name='trapReceiver' and name='cust_mibdir';
update rhn_config_parameter set value='%{NPLIB}/trapReceiver/traps' where group_name='trapReceiver' and name='trapdir';
update rhn_config_parameter set value='%{NPLIB}/ProbeState' where group_name='ProbeFramework' and name='databaseDirectory';
update rhn_config_parameter set value='%{NPLIB}/.gripes.gdbm' where group_name='queues' and name='gritchdb';
update rhn_config_parameter set value='%{NPLIB}/queue' where group_name='queues' and name='queuedir';
update rhn_config_parameter set value='%{NPLIB}/queue/snmp/LAST_SENT' where group_name='queues' and name='snmplast';
update rhn_config_parameter set value='%{NPLIB}/commands/.gripes.gdbm' where group_name='CommandQueue' and name='gritchdb';
update rhn_config_parameter set value='%{NPLIB}/commands/heartbeat' where group_name='CommandQueue' and name='heartbeatFile';
update rhn_config_parameter set value='%{NPLIB}/commands/last_completed' where group_name='CommandQueue' and name='lastCompletedFile';
update rhn_config_parameter set value='%{NPLIB}/commands/last_started' where group_name='CommandQueue' and name='lastStartedFile';
update rhn_config_parameter set value='%{NPLIB}/last_state_push' where group_name='current_state' and name='last_success';
update rhn_config_parameter set value='%{NPLIB}/events.frozen' where group_name='satellite' and name='eventsFile';
update rhn_config_parameter set value='%{NPLIB}/.gripes-probe-code.gdbm' where group_name='satellite' and name='gritchdb';
update rhn_config_parameter set value='%{NPLIB}/scheduler.xml' where group_name='satellite' and name='schedulerConfigFile';
update rhn_config_parameter set value='%{NPLIB}/reload.please' where group_name='satellite' and name='schedulerReloadFlagFile';
update rhn_config_parameter set value='%{NPLIB}/commands/execute_commands.log' where group_name='CommandQueue' and name='exelog';

commit;
