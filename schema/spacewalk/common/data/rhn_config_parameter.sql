--
-- Copyright (c) 2008 Red Hat, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
-- 
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation. 
--
--
--
--
-- 
--

--data for rhn_config_parameter

insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'CommandQueue', 'dbAuthFile', '/etc/NOCpulse.SputLiteAuth', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'CommandQueue', 'exelog', '%{NPLIB}/commands/execute_commands.log', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'CommandQueue', 'exelogLevel', '3', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'CommandQueue', 'gritchdb', '%{NPLIB}/commands/.gripes.gdbm', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'CommandQueue', 'heartbeatFile', '%{NPLIB}/commands/heartbeat', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'CommandQueue', 'lastCompletedFile', '%{NPLIB}/commands/last_completed', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'CommandQueue', 'lastStartedFile', '%{NPLIB}/commands/last_started', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'CommandQueue', 'pollingInterval', '60', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'CommandQueue', 'queueName', 'commands', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'CommandQueue', 'queueServer', '%{SATCFGURL}/cgi-mod-perl/fetch_commands.cgi', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'CommandQueue', 'url', '%{IPROTO}://%{SATCFGHOST}/cgi-bin/upload_results.cgi', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'ConfigPusher', 'dbsynchProgram', '%{NPBIN}/synch.sh', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'Discoverer', 'nmapPath', '/usr/bin/nmap', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'Discoverer', 'url', '%{SATCFGURL}/cgi-bin/upload_autodisc.cgi', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'PlugFrame', 'configFile', '%{NPETC}/PlugFrame.ini', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'ProbeFramework', 'databaseDirectory', '%{NPLIB}/ProbeState', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'ProbeFramework', 'probeClassLibraryDirectory', '%{NPHOME}/libexec', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'SpreadBridge', 'clientCA', '%{NPETC}/nocpulse-sys-proxy-chain.crt', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'SpreadBridge', 'clientCert', '%{NPETC}/sat-smon-cert.pem', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'SpreadBridge', 'clientHost', '%{SMONTEST}', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'SpreadBridge', 'clientKey', '%{NPETC}/sat-smon-key.pem', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'SpreadBridge', 'clientPort', '%{SPREADBRIDGE_CLIENTPORT}', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'SpreadBridge', 'clientService', 'SPBR', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'SpreadBridge', 'logfile', '%{NPVAR}/spbridge.log', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'SpreadBridge', 'loglevel', '1', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'SpreadBridge', 'serverIP', '0.0.0.0', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'SpreadBridge', 'serverPort', '4547', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'SpreadBridge', 'serverQueue', '5', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'SuperSput', 'clientHost', '%{SMONHOST}', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'SuperSput', 'clientPort', '443', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'SuperSput', 'cryptkey', '%{SSPUT_CRYPTKEY}', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'SuperSput', 'logfile', '%{NPVAR}/supersput.log', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'SuperSput', 'loglevel', '1', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'SuperSput', 'serverCert', '%{NPETC}/spbridge/cert.pem', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'SuperSput', 'serverIF', 'eth0', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'SuperSput', 'serverKey', '%{NPETC}/spbridge/key.pem', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'SuperSput', 'serverPort', '1284', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'TSDBLocalQueue', 'bdb_dir', '/nocpulse/tsdb/bdb', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'TSDBLocalQueue', 'daemon_log_config', '''local_queue'' => 1', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'TSDBLocalQueue', 'daemon_log_file', '/var/log/nocpulse/TSDBLocalQueue/TSDBLocalQueue.log', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'TSDBLocalQueue', 'handler_log_config', '', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'TSDBLocalQueue', 'handler_log_file', '/var/log/nocpulse/TSDBLocalQueue/TSDBHandler.log', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'TSDBLocalQueue', 'handler_rotate_size_kb', '250', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'TSDBLocalQueue', 'local_queue_dir', '/var/log/nocpulse/TSDBLocalQueue', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'TSDBLocalQueue', 'read_old_file_lines', '250', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'TSDBLocalQueue', 'read_old_file_seconds', '3', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'cf_db', 'dbd', 'Oracle', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'cf_db', 'name', '%{CFDB_NAME}', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'cf_db', 'notification_password', '%{CFDB_NOTIF_PASSWD}', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'cf_db', 'notification_username', '%{RHN_DB_USERNAME}', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'cf_db', 'password', '%{CFDB_PASSWD}', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'cf_db', 'portal_password', '%{CFDB_PASSWD}', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'cf_db', 'portal_username', '%{RHN_DB_USERNAME}', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'cf_db', 'proxy_password', '%{CFDB_PASSWD}', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'cf_db', 'proxy_username', '%{RHN_DB_USERNAME}', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'cf_db', 'tableowner', '%{RHN_DB_TABLE_OWNER}', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'cf_db', 'ui_password', '%{CFDB_PASSWD}', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'cf_db', 'ui_username', '%{RHN_DB_USERNAME}', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'cf_db', 'username', '%{RHN_DB_USERNAME}', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'cs_db', 'dbd', 'Oracle', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'cs_db', 'name', '%{CSDB_NAME}', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'cs_db', 'password', '%{CSDB_PASSWD}', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'cs_db', 'tableowner', '%{RHN_DB_TABLE_OWNER}', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'cs_db', 'username', '%{RHN_DB_USERNAME}', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'current_state', 'acceptor_url', '%{SATCFGURL}/cgi-mod-perl/accept_status_log.cgi', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'current_state', 'last_success', '%{NPLIB}/last_state_push', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'current_state', 'notification_interval', '300', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'general', 'domain', '%{DOM}', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'general', 'env', '%{ENV}', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'general', 'produser', '%{USER}', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'gritch', 'countInterval', '1000', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'gritch', 'targetDest', '%{GRITCH_TARGETDEST}', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'gritch', 'targetEmail', '%{SMON_ADMIN_EMAIL}', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'gritch', 'targetMX', '%{SMONURL}/cgi-bin/https_mx.cgi', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'gritch', 'targetQueue', 'notif', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'gritch', 'timeInterval', '1800', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'hosts', 'cfdb', '%{CFDBHOST}', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'hosts', 'csdb', '%{CSDBHOST}', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'hosts', 'notif', '%{NOTIFHOST}', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'hosts', 'satconfig', '%{SATCFGHOST}', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'hosts', 'scdb', '%{SCDBHOST}', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'hosts', 'smon', '%{SMONHOST}', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'hosts', 'tsdb', '%{TSDBHOST}', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'innovate', 'base_path', '/cgi-bin/up.cgi', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'innovate', 'lastresort', '%{NOTIF_ADMIN_EMAIL}', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'innovate', 'logindir', '%{INNOVATE_LOGINDIR}', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'innovate', 'password', '%{INNOVATE_PASSWD}', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'innovate', 'summarylength', '40', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'innovate', 'url', '%{SUPPORTURL}', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'innovate', 'user', '1_telalert', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'mail', 'maildomain', '%{MDOM}', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'mail', 'mx', '%{MAIL_MX}', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'netsaint', 'archiveDir', '/var/lib/nocpulse/archives', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'netsaint', 'cHashProgram', '/usr/share/ssl/misc/c_hash', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'netsaint', 'caPemCertFile', '/etc/nocpulse/nocpulse-cert.pem', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'netsaint', 'commandFile', '/var/lib/nocpulse/rw/netsaint.cmd', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'netsaint', 'commandParameterDatabase', '/var/lib/nocpulse/CommandParameter.db', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'netsaint', 'configBackupDir', '/etc/nocpulse/backup', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'netsaint', 'configDir', '/etc/nocpulse', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'netsaint', 'hacf', '/etc/ha.d/ha.cf', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'netsaint', 'haresources', '/etc/ha.d/haresources', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'netsaint', 'hostsConfigFile', 'hosts.cfg', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'netsaint', 'llConfigDir', '/var/lib/nocpulse/llconfig', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'netsaint', 'llnetsaintFile', '/etc/nocpulse/llnetsaint', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'netsaint', 'netsaintConfigFile', 'netsaint.cfg', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'netsaint', 'netsaintIdFile', '/etc/nocpulse/netsaintId', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'netsaint', 'pluginDatabase', '/var/lib/nocpulse/Probe.db', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'netsaint', 'probeRecordDatabase', '/var/lib/nocpulse/ProbeRecord.db', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'netsaint', 'program', '/usr/bin/netsaint', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'netsaint', 'satKeyFile', '/var/lib/nocpulse/.ssh/nocpulse-identity.pub', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'netsaint', 'satPemCertFile', '/etc/nocpulse/satellite-cert.pem', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'netsaint', 'satPemKeyFile', '/etc/nocpulse/satellite-key.pem', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'notif', 'url', '%{NOTIFURL}', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'notification', 'ack_handler_log', '/var/log/nocpulse/ack_handler.log', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'notification', 'ack_queue_dir', '/var/lib/notification/queue/ack_queue', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'notification', 'ack_queue_item', 'Alert', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'notification', 'admin_port', '%{NOTIF_ADMINPORT}', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'notification', 'alert_queue_dir', '/var/lib/notification/queue/alert_queue', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'notification', 'alert_queue_item', 'Acknowledgement', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'notification', 'archive_params', '--cd=/var/log/nocpulse --dir=/var/log/nocpulse/archive /var/log/nocpulse/ack_handler.log enqueue.log generate_config.log notifserver.log.save notifserver-error.log --recreate=ticketlog', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'notification', 'config_dir', '/etc/notification', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'notification', 'config_reload_flag_file', '/etc/nocpulse/NOCpulse/tmp/reload_notif_config.please', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'notification', 'enqueue_log', '/var/log/nocpulse/enqueue.log', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'notification', 'frombase', 'rogerthat', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'notification', 'fromname', 'Monitoring Satellite Notification', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'notification', 'home', '/var/lib/nocpulse', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'notification', 'log_dir', '/var/log/nocpulse', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'notification', 'max_sends_in_progress', '400', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'notification', 'notif_emergency_email', '%{NOTIFDOWNEMAIL}', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'notification', 'redirects_reload_flag_file', '/etc/nocpulse/NOCpulse/tmp/reload_redirect_config.please', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'notification', 'request_queue_dir', '/var/lib/nocpulse/queue/request_queue', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'notification', 'request_queue_item', 'Request', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'notification', 'rotate_log_flag_file', '/etc/nocpulse/NOCpulse/tmp/rotate_logs.please', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'notification', 'snmp_notif_url', '%{PORTALURL}/ocenter/', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'notification', 'ticket_log_dir', '/var/log/nocpulse/ticketlog', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'notification', 'tmp_dir', '/var/tmp', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'oracle', 'ora_home', '/opt/oracle', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'oracle', 'ora_port', '1521', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'queues', 'aliases', 'notification,states,trends,command,snmp_direct', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'queues', 'bugsEmail', '%{SMON_ADMIN_EMAIL}', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'queues', 'commands_dequeueLimit', '0', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'queues', 'commands_maxsize', '5', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'queues', 'eventHandler', '%{SMONURL}/cgi-bin/eventHandler.cgi', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'queues', 'gritchdb', '%{NPLIB}/.gripes.gdbm', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'queues', 'logfile', '%{NPVAR}/dequeue.log', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'queues', 'notif_dequeueLimit', '50', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'queues', 'notif_maxsize', '30', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'queues', 'polling_interval', '5', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'queues', 'queuedir', '%{NPLIB}/queue', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'queues', 'queues', 'notif,sc_db,ts_db,commands,snmp', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'queues', 'queueuser', 'nocpulse', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'queues', 'sc_db_dequeueLimit', '1000', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'queues', 'sc_db_maxsize', '3000', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'queues', 'snmp_dequeueLimit', '0', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'queues', 'snmp_download_url', '%{SATCFGURL}/cgi-mod-perl/fetch_snmp_alerts.cgi', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'queues', 'snmp_maxsize', '30', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'queues', 'snmplast', '%{NPLIB}/queue/snmp/LAST_SENT', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'queues', 'snmplog', '%{NPVAR}/dequeue.snmp.log', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'queues', 'ts_db_batch_size', '300', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'queues', 'ts_db_dequeueLimit', '600', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'queues', 'ts_db_maxsize', '3000', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'satellite', 'bootstrapUrl', '%{SATCFGURL}/cgi-bin/fetch_netsaintid.cgi', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'satellite', 'configGenTimeout', '90', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'satellite', 'configGrabUrl', '%{SATCFGURL}/cgi-bin/configdata.cgi', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'satellite', 'depotUrl', '%{SMONURL}/depot/', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'satellite', 'eventsFile', '%{NPLIB}/events.frozen', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'satellite', 'gritchdb', '%{NPLIB}/.gripes-probe-code.gdbm', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'satellite', 'schedulerConfigFile', '%{NPLIB}/scheduler.xml', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'satellite', 'schedulerLogFile', '%{NPVAR}/kernel.log', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'satellite', 'schedulerReloadFlagFile', '%{NPLIB}/reload.please', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'sc_db', 'url', '%{SCDBURL}', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'ssl_bridge', 'cdir', '%{NPETC}/spbridge', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'ssl_bridge', 'cert', '%{NPETC}/spbridge/smon-sb.crt', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'ssl_bridge', 'cfile', '%{NPETC}/spbridge/nocpulse-sys-satellite-chain.crt', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'ssl_bridge', 'ciphers', 'DES-CBC3-SHA', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'ssl_bridge', 'key', '%{NPETC}/spbridge/smon-sb.key', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'ssl_bridge', 'listenIP', '0.0.0.0', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'ssl_bridge', 'listenPort', '4546', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'ssl_bridge', 'listenQueue', '5', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'ssl_bridge', 'logfile', '%{NPVAR}/ssl_bridge.log', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'ssl_bridge', 'remoteIP_SPBR', '%{SATCFGHOST}', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'ssl_bridge', 'remotePort_SPBR', '4547', 'INTERNAL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'timesync', 'maxdelta', '%{TIMESYNC_MAXDELTA}', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'timesync', 'mindelta', '%{TIMESYNC_MINDELTA}', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'timesync', 'retries', '3', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'timesync', 'samplesize', '5', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'timesync', 'timeserver', '%{SMONURL}/cgi-bin/timeserver.cgi', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'trapReceiver', 'cmd_recid', '250', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'trapReceiver', 'config', '%{NPLIB}/trapReceiver/config', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'trapReceiver', 'cust_mibdir', '%{NPLIB}/trapReceiver/mibs', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'trapReceiver', 'logfile', '%{NPVAR}/trapReceiver.log', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'trapReceiver', 'loglevel', '2', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'trapReceiver', 'std_mibdir', '/usr/local/snmp/share/snmp/mibs', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'trapReceiver', 'trapdir', '%{NPLIB}/trapReceiver/traps', 'ALL', 'system',sysdate);
insert into rhn_config_parameter(group_name,name,value,security_type,last_update_user,last_update_date) values ( 'ts_db', 'url', '%{TSDBURL}', 'INTERNAL', 'system',sysdate);

--
--Revision 1.9  2004/10/29 15:19:34  kja
--Bugzilla 137559: Changing the from name on the monitoring notification email message.
--
--Revision 1.8  2004/07/21 00:21:34  dfaraldo
--Moved TSDBLocalQueue log files to /var/log/nocpulse/TSDBLocalQueue
--(a directory writable by apache). -dfaraldo
--
--Revision 1.7  2004/07/16 21:51:32  dfaraldo
--Added ProbeFramework section and data. -dfaraldo
--
--Revision 1.6  2004/07/15 00:54:11  dfaraldo
--New RHN_CONFIG_MACRO and RHN_CONFIG_PARAMETER static data for the
--combined satellite.
--
