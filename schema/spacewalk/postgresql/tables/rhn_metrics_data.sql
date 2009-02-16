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
--data for rhn_metrics
--metrics for linux and scout commands only

insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'accesses','eps','Request Rate','system',sysdate,'Request rate','Apache::Traffic');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'traffic','Kbps','Traffic','system',sysdate,'Traffic','Apache::Traffic');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'load1','count','CPU Load 1-Minute Average','system',sysdate,'CPU load 1-min ave','Unix::Load');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'open','count','Open Objects','system',sysdate,'Open objects','MySQL::Open');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'pingtime','millisecs','Round-trip Average','system',sysdate,'Round-trip avg','NetworkService::Ping');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'nusers','count','Users','system',sysdate,'Users','Unix::Users');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'nprocs','count','Processes','system',sysdate,'Processes','Unix::ProcessCountTotal');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'probes','count','Probes','system',sysdate,'Probes','Satellite::ProbeCount');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'probelatnc','secs','Probe Latency Average','system',sysdate,'Probe latency ave','Satellite::ProbeLatency');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'free','Mb','RAM Free','system',sysdate,'RAM free','Unix::MemoryFree');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'load5','count','CPU Load 5-Minute Average','system',sysdate,'CPU load 5-min ave','Unix::Load');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'load15','count','CPU Load 15-Minute Average','system',sysdate,'CPU load 15-min ave','Unix::Load');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'opened','count','Opened Objects','system',sysdate,'Opened objects','MySQL::Opened');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'probextm','secs','Probe Execution Time Average','system',sysdate,'Probe exec time ave','Satellite::ProbeExecTime');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'regmatches','count','Regular Expression Matches','system',sysdate,'Pattern matches','LogAgent::PatternMatch');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'regrate','epm','Regular Expression Match Rate','system',sysdate,'Pattern match rate','LogAgent::PatternMatch');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'bytes','bytes','Size','system',sysdate,'Size','LogAgent::Size');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'byterate','bpm','Output Rate','system',sysdate,'Output rate','LogAgent::Size');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'lines','count','Lines','system',sysdate,'Lines','LogAgent::Size');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'linerate','lpm','Line Rate','system',sysdate,'Line rate','LogAgent::Size');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'reqs','count','Current Requests','system',sysdate,'Current requests','Apache::Traffic');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'nblocked','count','Blocked Processes','system',sysdate,'Blocked processes','Unix::ProcessStateCounts');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'nchildren','count','Child Process Groups','system',sysdate,'Child process groups','Unix::Process');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'ndefunct','count','Defunct Processes','system',sysdate,'Defunct processes','Unix::ProcessStateCounts');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'nstopped','count','Stopped Processes','system',sysdate,'Stopped processes','Unix::ProcessStateCounts');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'nswapped','count','Sleeping Processes','system',sysdate,'Sleeping processes','Unix::ProcessStateCounts');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'nthreads','count','Threads','system',sysdate,'Threads','Unix::Process');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'vsz','count','Virtual Memory Used','system',sysdate,'Virtual memory used','Unix::Process');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'kbrps','Kbps','Read Rate','system',sysdate,'Read rate','Unix::DiskIOThroughput');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'kbwps','Kbps','Write Rate','system',sysdate,'Write rate','Unix::DiskIOThroughput');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'pctused','percent','Filesystem Used','system',sysdate,'Filesystem pct used','Unix::Disk');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'pctfree','percent','Virtual Memory Free','system',sysdate,'Virtual mem pct free','Unix::VirtualMemory');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'pctfree','percent','Swap Space Free','system',sysdate,'Swap pct free','Unix::Swap');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'pctused','percent','CPU Used','system',sysdate,'CPU pct used','Unix::CPU');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'pctlost','percent','Packet Loss','system',sysdate,'Packet loss pct','NetworkService::Ping');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'pctiused','percent','Inodes Used','system',sysdate,'Inodes pct used','Unix::Inodes');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'childmb','Mb','Max Data Transferred Per Child','system',sysdate,'Max transferred per child','Apache::Processes');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'slotmb','Mb','Max Data Transferred Per Slot','system',sysdate,'Max transferred per slot','Apache::Processes');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'actsession','count','Active Sessions','system',sysdate,'Active sessions','Oracle::ActiveSessions');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'blksession','count','Blocking Sessions','system',sysdate,'Blocking sessions','Oracle::BlockingSessions');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'idlsession','count','Idle Sessions','system',sysdate,'Idle sessions','Oracle::IdleSessions');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'latency','secs','Remote Service Latency','system',sysdate,'Latency','NetworkService::FTP');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'latency','secs','Remote Service Latency','system',sysdate,'Latency','NetworkService::HTTP');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'latency','secs','Remote Service Latency','system',sysdate,'Latency','NetworkService::HTTPS');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'latency','secs','Remote Service Latency','system',sysdate,'Latency','NetworkService::IMAP');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'qps','eps','Query Rate','system',sysdate,'Query rate','MySQL::Queries');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'threads','count','Threads Running','system',sysdate,'Threads running','MySQL::Threads');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'value','count','Value','system',sysdate,'Value','General::SNMPCheck');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'latency','secs','Remote Service Latency','system',sysdate,'Latency','NetworkService::POP');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'latency','secs','Remote Service Latency','system',sysdate,'Latency','NetworkService::RPC');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'latency','secs','Remote Service Latency','system',sysdate,'Latency','NetworkService::SMTP');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'latency','secs','Remote Service Latency','system',sysdate,'Latency','NetworkService::SSH');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'latency','secs','Remote Service Latency','system',sysdate,'Latency','General::TCP');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'nconns','count','Total Connections','system',sysdate,'Total conns','Unix::TCPConnectionsByState');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'latency','secs','Remote Service Latency','system',sysdate,'Latency','Oracle::TNSping');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'value','count','Value','system',sysdate,'value','General::RemoteProgramWithData');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'value','bytes','Value','system',sysdate,'Value','Weblogic::HeapFree');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'hit_ratio','percent','Buffer Cache Hit Ratio','system',sysdate,'Buffer cache hit ratio','Oracle::BufferCache');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'db_block_gets','epm','DB Block Get Rate','system',sysdate,'DB block get rate','Oracle::BufferCache');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'consistent_gets','epm','Consistent Get Rate','system',sysdate,'Consistent get rate','Oracle::BufferCache');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'physical_reads','epm','Physical Read Rate','system',sysdate,'Physical read rate','Oracle::BufferCache');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'hit_ratio','percent','Data Dictionary Hit Ratio','system',sysdate,'Data dict hit ratio','Oracle::DataDictionaryCache');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'gets','epm','Get Rate','system',sysdate,'Get rate','Oracle::DataDictionaryCache');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'get_misses','epm','Cache Miss Rate','system',sysdate,'Cache miss rate','Oracle::DataDictionaryCache');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'miss_ratio','percent','Library Cache Miss Ratio','system',sysdate,'Library cache miss ratio','Oracle::LibraryCache');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'executions','epm','Execution Rate','system',sysdate,'Execution rate','Oracle::LibraryCache');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'misses','epm','Cache Miss Rate','system',sysdate,'Cache miss rate','Oracle::LibraryCache');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'usedsesspct','percent','Used Sessions','system',sysdate,'Used Sessions','Oracle::ActiveSessions');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'locks','count','Active Locks','system',sysdate,'Active locks','Oracle::Locks');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'requests','epm','Redo Log Space Request Rate','system',sysdate,'Redo log space request rate','Oracle::RedoLog');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'retries','epm','Redo Buffer Allocation Retry Rate','system',sysdate,'Redo buffer allocation retry rate','Oracle::RedoLog');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'ratio','percent','Disk Sort Ratio','system',sysdate,'Disk sort ratio','Oracle::DiskSort');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'dsk_sorts','epm','Disk Sort Rate','system',sysdate,'Disk sort rate','Oracle::DiskSort');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'mem_sorts','epm','Memory Sort Rate','system',sysdate,'Memory sort rate','Oracle::DiskSort');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'connections','count','Connections','system',sysdate,'Connections','Weblogic::JDBCConnectionPool');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'waiters','count','Waiters','system',sysdate,'Waiters','Weblogic::JDBCConnectionPool');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'conn_rate','eps','Connection Rate','system',sysdate,'Conn rate','Weblogic::JDBCConnectionPool');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'idle_threads','count','Idle Execute Threads','system',sysdate,'Idle threads','Weblogic::ExecuteQueue');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'queue_length','count','Queue Length','system',sysdate,'Queue length','Weblogic::ExecuteQueue');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'request_rate','eps','Request Rate','system',sysdate,'Request rate','Weblogic::ExecuteQueue');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'exec_move_ave','count','Execution Time Moving Average','system',sysdate,'Exec time moving ave','Weblogic::Servlet');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'avg_exec_time','count','Execution Time Ave','system',sysdate,'Execution time ave','Weblogic::Servlet');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'reload_rate','epm','Reload Rate','system',sysdate,'Reload rate','Weblogic::Servlet');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'invocation_rate','epm','Invocation Rate','system',sysdate,'Invocation rate','Weblogic::Servlet');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'high_exec_time','count','High Execution Time','system',sysdate,'High exec time','Weblogic::Servlet');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'low_exec_time','count','Low Execution Time','system',sysdate,'Low exec time','Weblogic::Servlet');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'space_used','Mb','Space Used','system',sysdate,'Space used','Unix::Disk');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'space_avail','Mb','Space Available','system',sysdate,'Space available','Unix::Disk');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'out_byte_rt','bps','Output Rate','system',sysdate,'Output rate','Unix::InterfaceTraffic');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'in_byte_rt','bps','Input Rate','system',sysdate,'Input rate','Unix::InterfaceTraffic');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'load1','percent','CPU Load 1-Minute Average','system',sysdate,'CPU load 1-min avg','Windows::LoadAverage');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'load5','percent','CPU Load 5-Minute Average','system',sysdate,'CPU load 5-min avg','Windows::LoadAverage');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'load15','percent','CPU Load 15-Minute Average','system',sysdate,'CPU load 15-min avg','Windows::LoadAverage');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'physical_mem_used','count','Physical Memory Used','system',sysdate,'Physical memory used','Unix::Process');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'cpu_time_rt','msps','CPU Usage','system',sysdate,'CPU usage','Unix::Process');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'time_wait_conn','count','TIME_WAIT Connections','system',sysdate,'TIME_WAIT conns','Unix::TCPConnectionsByState');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'close_wait_conn','count','CLOSE_WAIT Connections','system',sysdate,'CLOSE_WAIT conns','Unix::TCPConnectionsByState');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'fin_wait_conn','count','FIN_WAIT Connections','system',sysdate,'FIN_WAIT conns','Unix::TCPConnectionsByState');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'established_conn','count','ESTABLISHED Connections','system',sysdate,'ESTABLISHED conns','Unix::TCPConnectionsByState');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'syn_rcvd_conn','count','SYN_RCVD Connections','system',sysdate,'SYN_RCVD conns','Unix::TCPConnectionsByState');
insert into rhn_metrics(metric_id,storage_unit_id,description,last_update_user,last_update_date,label,command_class)     values ( 'query_time','millisecs','Query Time','system',sysdate,'Query time','Unix::Dig');

commit;


--
--Revision 1.5  2004/11/16 14:25:23  nhansen
--bug 138411: need to drop metrics for the check alive as well
--
--Revision 1.4  2004/06/17 20:25:18  kja
--bugzilla 124620 -- Include only approved probes.  Fixed data referential
--integrity errors.  Only approved operating systems.
--
--Revision 1.3  2004/05/29 21:51:49  pjones
--bugzilla: none 
-- _data is not for 340, so says kja.
--
--Revision 1.2  2004/05/04 20:03:38  kja
--Added commits.
--
--Revision 1.1  2004/04/23 18:27:47  kja
--More reference table data.
--
