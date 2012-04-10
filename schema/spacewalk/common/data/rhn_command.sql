--
-- Copyright (c) 2008--2010 Red Hat, Inc.
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

-- data for rhn_command
-- linux and scout commands only

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
2,'LongLegs','LongLegs',NULL,'0','Satellite::LongLegs','0','0','system',current_timestamp,NULL,NULL,NULL);

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
6,'check_tcp','TCP Check','tools','1','General::TCP','1','0','system',current_timestamp,NULL,NULL,'/help/userguides/user_guide_v2/Output/toolsCheck.html#TCPCheck');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
7,'check_udp','UDP Check','tools','1','General::TCP','1','0','system',current_timestamp,NULL,NULL,'/help/userguides/user_guide_v2/Output/toolsCheck.html#UDPCheck');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
8,'check_smtp','Mail Transfer (SMTP)','netservice','1','NetworkService::SMTP','1','0','system',current_timestamp,NULL,NULL,'/help/userguides/user_guide_v2/Output/NetworkServiceCheck.html#MailTransfer(SMTP)');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
9,'check_pop','POP Mail','netservice','1','NetworkService::POP','1','0','system',current_timestamp,NULL,NULL,'/help/userguides/user_guide_v2/Output/NetworkServiceCheck.html#POPMail');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
10,'check_ftp','FTP','netservice','1','NetworkService::FTP','1','0','system',current_timestamp,NULL,NULL,'/help/userguides/user_guide_v2/Output/NetworkServiceCheck.html#FTP');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
11,'check_http','Web server (HTTP)','netservice','1','NetworkService::HTTP','1','0','system',current_timestamp,NULL,NULL,'/help/userguides/user_guide_v2/Output/NetworkServiceCheck.html#WebServer(HTTP)');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
13,'check_ping','Ping','netservice','1','NetworkService::Ping','1','0','system',current_timestamp,NULL,NULL,'/help/userguides/user_guide_v2/Output/NetworkServiceCheck.html#Ping');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
14,'check_dns_resolution','DNS Lookup','netservice','1','Unix::Dig','1','0','system',current_timestamp,NULL,NULL,'/help/userguides/user_guide_v2/Output/NetworkServiceCheck.html#DNSLookup');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
15,'check_ssh','SSH','netservice','1','NetworkService::SSH','1','0','system',current_timestamp,NULL,NULL,'/help/userguides/user_guide_v2/Output/NetworkServiceCheck.html#SSH');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
16,'check_snmp_value','SNMP Check','tools','1','General::SNMPCheck','1','0','system',current_timestamp,'snmp',NULL,'/help/userguides/user_guide_v2/Output/toolsCheck.html#SNMPCheck');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
17,'satellite_disk_space','Disk Space','satellite','0','Unix::Disk','1','0','system',current_timestamp,NULL,NULL,NULL);

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
18,'satellite_check_users','Users','satellite','0','Unix::Users','1','0','system',current_timestamp,NULL,NULL,NULL);

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
19,'satellite_check_procs','Processes','satellite','0','Unix::ProcessCountTotal','1','0','system',current_timestamp,NULL,NULL,NULL);

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
20,'satellite_check_load','Load','satellite','0','Unix::Load','1','0','system',current_timestamp,NULL,NULL,NULL);

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
22,'satellite_check_swap','Swap','satellite','0','Unix::Swap','1','0','system',current_timestamp,NULL,NULL,NULL);

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
23,'check_tnsping','TNS Ping','oracle','1','Oracle::TNSping','1','0','system',current_timestamp,NULL,NULL,'/help/userguides/user_guide_v2/Output/OracleCheck.html#TNSPing');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
24,'satellite_probe_latency','Latency','satellite','0','Satellite::ProbeLatency','1','0','system',current_timestamp,NULL,NULL,NULL);

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
25,'remote_check_memory','Memory Usage','linux','1','Unix::MemoryFree','1','0','system',current_timestamp,'npunix',NULL,'/help/userguides/user_guide_v2/Output/UnixCheck.html#MemoryUsage');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
26,'remote_check_cpu','CPU Usage','linux','1','Unix::CPU','1','0','system',current_timestamp,'npunix',NULL,'/help/userguides/user_guide_v2/Output/UnixCheck.html#CPUUsage');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
27,'remote_check_load','Load','linux','1','Unix::Load','1','0','system',current_timestamp,'npunix',NULL,'/help/userguides/user_guide_v2/Output/UnixCheck.html#UnixLoad');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
28,'remote_check_swap','Swap Usage','linux','1','Unix::Swap','1','0','system',current_timestamp,'npunix',NULL,'/help/userguides/user_guide_v2/Output/UnixCheck.html#SwapUsage');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
29,'remote_check_disk','Disk Usage','linux','1','Unix::Disk','1','0','system',current_timestamp,'npunix',NULL,'/help/userguides/user_guide_v2/Output/UnixCheck.html#DiskUsage');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
30,'remote_check_users','Users','linux','1','Unix::Users','1','0','system',current_timestamp,'npunix',NULL,'/help/userguides/user_guide_v2/Output/UnixCheck.html#Users');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
31,'remote_check_procs','Process Count Total','linux','1','Unix::ProcessCountTotal','1','0','system',current_timestamp,'npunix',NULL,'/help/userguides/user_guide_v2/Output/UnixCheck.html#Processes');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
32,'check_host_alive','Host Availability',NULL,'0','NetworkService::Ping','1','1','system',current_timestamp,NULL,NULL,NULL);

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
41,'check_nothing','Check Nothing','tools','1','General::CheckNothing','1','0','system',current_timestamp,NULL,NULL,'/help/userguides/user_guide_v2/Output/toolsCheck.html#CheckNothing');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
42,'check_imap','IMAP Mail','netservice','1','NetworkService::IMAP','1','0','system',current_timestamp,NULL,NULL,'/help/userguides/user_guide_v2/Output/NetworkServiceCheck.html#IMAPMail');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
48,'check_rpc','RPC Service','netservice','1','NetworkService::RPC','1','0','system',current_timestamp,NULL,NULL,'/help/userguides/user_guide_v2/Output/NetworkServiceCheck.html#RPCService');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
56,'check_https','Secure Web server (HTTPS)','netservice','1','NetworkService::HTTPS','1','0','system',current_timestamp,NULL,NULL,'/help/userguides/user_guide_v2/Output/NetworkServiceCheck.html#SecureWebServer(HTTPS)');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
58,'icmp_blocked','ICMP Blocked',NULL,'0','General::CheckNothing','1','1','system',current_timestamp,NULL,NULL,NULL);

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
60,'satellite_probe_exec_time','Execution Time','satellite','0','Satellite::ProbeExecTime','1','0','system',current_timestamp,NULL,NULL,NULL);

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
61,'satellite_probe_count','Probe Count','satellite','0','Satellite::ProbeCount','1','0','system',current_timestamp,NULL,NULL,NULL);

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
85,'check_ora_blocking_sessions','Blocking Sessions','oracle','1','Oracle::BlockingSessions','1','0','system',current_timestamp,'oracle',NULL,'/help/userguides/user_guide_v2/Output/OracleCheck.html#BlockingSessions');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
86,'check_ora_locks','Locks','oracle','1','Oracle::Locks','1','0','system',current_timestamp,'oracle',NULL,'/help/userguides/user_guide_v2/Output/OracleCheck.html#Locks');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
87,'check_ora_all_extents','Tablespace Usage','oracle','1','Oracle::TablespaceUsage','1','0','system',current_timestamp,'oracle',NULL,'/help/userguides/user_guide_v2/Output/OracleCheck.html#AllExtents');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
88,'check_ora_table_extents','Table Extents','oracle','1','Oracle::TableExtents','1','0','system',current_timestamp,'oracle',NULL,'/help/userguides/user_guide_v2/Output/OracleCheck.html#TableExtents');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
89,'check_ora_index_extents','Index Extents','oracle','1','Oracle::IndexExtents','1','0','system',current_timestamp,'oracle',NULL,'/help/userguides/user_guide_v2/Output/OracleCheck.html#IndexExtents');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
90,'check_ora_idle_sessions','Idle Sessions','oracle','1','Oracle::IdleSessions','1','0','system',current_timestamp,'oracle',NULL,'/help/userguides/user_guide_v2/Output/OracleCheck.html#IdleSessions');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
91,'check_ora_up','Availability','oracle','1','Oracle::Availability','1','0','system',current_timestamp,'oracle',NULL,'/help/userguides/user_guide_v2/Output/OracleCheck.html#Availability');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
92,'check_ora_sessions','Active Sessions','oracle','1','Oracle::ActiveSessions','1','0','system',current_timestamp,'oracle',NULL,'/help/userguides/user_guide_v2/Output/OracleCheck.html#ActiveSessions');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
93,'check_mysql_open_tables','Open Tables','mysql','1','MySQL::Open','1','0','system',current_timestamp,NULL,'Version 3.23/3.33','/help/userguides/user_guide_v2/Output/MySQLCheck.html#OpenTables');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
94,'check_mysql_opened_tables','Opened Tables','mysql','1','MySQL::Opened','1','0','system',current_timestamp,NULL,'Version 3.23/3.33','/help/userguides/user_guide_v2/Output/MySQLCheck.html#OpenedTables');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
95,'check_mysql_threads_running','Threads Running','mysql','1','MySQL::Threads','1','0','system',current_timestamp,NULL,'Version 3.23/3.33','/help/userguides/user_guide_v2/Output/MySQLCheck.html#ThreadsRunning');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
96,'check_mysql_queries_per_second','Query Rate','mysql','1','MySQL::Queries','1','0','system',current_timestamp,NULL,'Version 3.23/3.33','/help/userguides/user_guide_v2/Output/MySQLCheck.html#QueryRate');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
97,'check_mysql','Database Accessibility','mysql','1','MySQL::Accessibility','1','0','system',current_timestamp,NULL,'Version 3.23/3.33','/help/userguides/user_guide_v2/Output/MySQLCheck.html#DatabaseAccessibility');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
99,'remote_check_program','Remote Program','tools','1','General::RemoteProgram','1','0','system',current_timestamp,'npunix',NULL,'/help/userguides/user_guide_v2/Output/toolsCheck.html#RemoteProgram');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
105,'remote_check_interface_traffic','Interface Traffic','linux','1','Unix::InterfaceTraffic','1','0','system',current_timestamp,'npunix',NULL,'/help/userguides/user_guide_v2/Output/UnixCheck.html#UnixInterfaceTraffic');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
106,'check_log_size','Log Size Growth','logagent','1','LogAgent::Size','1','0','system',current_timestamp,'npunix',NULL,'/help/userguides/user_guide_v2/Output/LogAgentCheck.html#LogSize');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
107,'check_log_regex','Log Pattern Match','logagent','1','LogAgent::PatternMatch','1','0','system',current_timestamp,'npunix',NULL,'/help/userguides/user_guide_v2/Output/LogAgentCheck.html#LogRegex');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
109,'remote_check_ora_up','Client Connectivity','oracle','1','Oracle::ClientConnectivity','1','0','system',current_timestamp,'npunix_oracle',NULL,'/help/userguides/user_guide_v2/Output/OracleCheck.html#RemoteAvailability');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
113,'check_snmp_uptime','Uptime (SNMP)','tools','1','General::UptimeSNMP','1','0','system',current_timestamp,'snmp',NULL,'/help/userguides/user_guide_v2/Output/toolsCheck.html#Uptime(SNMP)');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
117,'remote_check_inodes','Inodes','linux','1','Unix::Inodes','1','0','system',current_timestamp,'npunix',NULL,'/help/userguides/user_guide_v2/Output/UnixCheck.html#Inodes');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
118,'remote_check_disk_io','Disk I/O Throughput','linux','1','Unix::DiskIOThroughput','1','0','system',current_timestamp,'npunix',NULL,'/help/userguides/user_guide_v2/Output/UnixCheck.html#DiskIOThroughput');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
120,'check_apache_uptime','Uptime','apache','1','Apache::Uptime','1','0','system',current_timestamp,NULL,'Apache versions 1.3.x and 2.0.x','/help/userguides/user_guide_v2/Output/ApacheCheck.html#Uptime');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
121,'check_apache_traffic','Requests','apache','1','Apache::Traffic','1','0','system',current_timestamp,'apache1_3','Apache versions 1.3.x and 2.0.x','/help/userguides/user_guide_v2/Output/ApacheCheck.html#Requests');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
122,'check_apache_procs','Processes','apache','1','Apache::Processes','1','0','system',current_timestamp,'apache1_3','Apache versions 1.3.x and 2.0.x','/help/userguides/user_guide_v2/Output/ApacheCheck.html#Processes');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
123,'check_virtual_memory','Virtual Memory','linux','1','Unix::VirtualMemory','1','0','system',current_timestamp,'npunix',NULL,'/help/userguides/user_guide_v2/Output/UnixCheck.html#VirtualMemory');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
226,'remote_process_running','Process Running','linux','1','Unix::ProcessRunning','1','0','system',current_timestamp,'npunix',NULL,'/help/userguides/user_guide_v2/Output/UnixCheck.html#ProcessRunning');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
227,'satellite_process_running','Process Running','satellite','0','Unix::ProcessRunning','1','0','system',current_timestamp,NULL,NULL,NULL);

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
228,'remote_process_health','Process Health','linux','1','Unix::Process','1','0','system',current_timestamp,'npunix',NULL,'/help/userguides/user_guide_v2/Output/UnixCheck.html#ProcessHealth');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
229,'satellite_process_health','Process Health','satellite','0','Unix::Process','1','0','system',current_timestamp,NULL,NULL,NULL);

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
230,'remote_process_counts','Process Counts by State','linux','1','Unix::ProcessStateCounts','1','0','system',current_timestamp,'npunix',NULL,'/help/userguides/user_guide_v2/Output/UnixCheck.html#ProcessCounts');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
231,'satellite_process_counts','Process Counts','satellite','0','Unix::ProcessStateCounts','1','0','system',current_timestamp,NULL,NULL,NULL);

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
249,'remote_check_tcp_connections_state','TCP Connections by State','linux','1','Unix::TCPConnectionsByState','1','0','system',current_timestamp,'npunix',NULL,'/help/userguides/user_guide_v2/Output/UnixCheck.html#TCPConnections State');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
254,'satellite_check_traffic','Interface Traffic','satellite','0','Unix::InterfaceTraffic','1','0','system',current_timestamp,NULL,NULL,NULL);

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
274,'remote_check_program_ts','Remote Program with Data','tools','1','General::RemoteProgramWithData','1','0','system',current_timestamp,'npunix',NULL,'/help/userguides/user_guide_v2/Output/toolsCheck.html#RemoteProgramData');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
275,'check_bea_61_state','Server State','bea_61','1','Weblogic::State','1','0','system',current_timestamp,'bea61_snmp','Version 6.1 or higher','/help/userguides/user_guide_v2/Output/BEAWebLogic61.html#ServerState61');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
276,'check_bea_61_heap_free','Heap Free','bea_61','1','Weblogic::HeapFree','1','0','system',current_timestamp,'bea61_snmp','Version 6.1 or higher','/help/userguides/user_guide_v2/Output/BEAWebLogic61.html#HeapFree');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
278,'check_ora_buffer_cache','Buffer Cache','oracle','1','Oracle::BufferCache','1','0','system',current_timestamp,'oracle',NULL,'/help/userguides/user_guide_v2/Output/OracleCheck.html#BufferCache');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
279,'check_ora_data_dictionary_cache','Data Dictionary Cache','oracle','1','Oracle::DataDictionaryCache','1','0','system',current_timestamp,'oracle',NULL,'/help/userguides/user_guide_v2/Output/OracleCheck.html#DataDictionaryCache');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
280,'check_ora_library_cache','Library Cache','oracle','1','Oracle::LibraryCache','1','0','system',current_timestamp,'oracle',NULL,'/help/userguides/user_guide_v2/Output/OracleCheck.html#LibraryCache');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
284,'check_ora_redo_log','Redo Log','oracle','1','Oracle::RedoLog','1','0','system',current_timestamp,'oracle',NULL,'/help/userguides/user_guide_v2/Output/OracleCheck.html#RedoLog');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
283,'check_ora_disk_sort','Disk Sort Ratio','oracle','1','Oracle::DiskSort','1','0','system',current_timestamp,'oracle',NULL,'/help/userguides/user_guide_v2/Output/OracleCheck.html#DiskSortRatio');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
282,'check_bea_61_jdbc_conn_pool','JDBC Connection Pool','bea_61','1','Weblogic::JDBCConnectionPool','1','0','system',current_timestamp,'bea61_snmp','Version 6.1 or higher','/help/userguides/user_guide_v2/Output/BEAWebLogic61.html#JDBCConnectionPool');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
281,'check_bea_61_execute_queue','Execute Queue','bea_61','1','Weblogic::ExecuteQueue','1','0','system',current_timestamp,'bea61_snmp','Version 6.1 or higher','/help/userguides/user_guide_v2/Output/BEAWebLogic61.html#ExecuteQueue');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
288,'check_bea_61_servlet','Servlet','bea_61','1','Weblogic::Servlet','1','0','system',current_timestamp,'bea61_snmp','Version 6.1 or higher','/help/userguides/user_guide_v2/Output/BEAWebLogic61.html#Servlet');

insert into rhn_command(recid,name,description,group_name,allowed_in_suite,
command_class,enabled,for_host_probe,last_update_user,last_update_date,system_requirements,version_support,help_url) 
    values (
304,'remote_check_ping','Remote Ping','netservice','1','NetworkService::Ping','1','0','system',current_timestamp,'npunix',NULL,'/help/userguides/user_guide_v2/Output/NetworkServiceCheck.html#RemotePing');

commit;


--
--Revision 1.9  2004/11/15 23:18:13  nhansen
--bug 138411: Drop the Check Alive probe.
--
--Revision 1.8  2004/08/02 22:14:10  dfaraldo
--Changed 'Unix' command group to 'Linux'. -dfaraldo
--
--Revision 1.7  2004/07/26 16:01:43  nhansen
--bug 128448: Drop the SNMP TrapReciever check from the command list for the triumph beta
--
--Revision 1.6  2004/07/23 22:25:56  dfaraldo
--Removed current state push probe (now part of the scheduler). -dfaraldo
--
--Revision 1.5  2004/06/17 20:25:18  kja
--bugzilla 124620 -- Include only approved probes.  Fixed data referential
--integrity errors.  Only approved operating systems.
--
--Revision 1.4  2004/06/09 17:22:06  nhansen
--bug 124620: changes for command and command_groups tables (sql and xml) for probes
--that will be supported in the rhn350 release.
--
--Revision 1.3  2004/05/29 21:51:49  pjones
--bugzilla: none -- _data is not for 340, so says kja.
--
--Revision 1.2  2004/05/04 20:03:38  kja
--Added commits.
--
--Revision 1.1  2004/04/23 18:27:47  kja
--More reference table data.
--
