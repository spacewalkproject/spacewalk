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
--data for rhn_command_param_threshold
--thresholds for linux and scout command parameters only


insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 122,'criticalchild','threshold','crit_max','childmb','system',
    sysdate,'Apache::Processes');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 122,'warnchild','threshold','warn_max','childmb','system',
    sysdate,'Apache::Processes');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 122,'criticalslot','threshold','crit_max','slotmb','system',
    sysdate,'Apache::Processes');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 122,'warnslot','threshold','warn_max','slotmb','system',
    sysdate,'Apache::Processes');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 121,'criticalaccess','threshold','crit_max','accesses','system',
    sysdate,'Apache::Traffic');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 121,'warnaccess','threshold','warn_max','accesses','system',
    sysdate,'Apache::Traffic');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 121,'criticalreqs','threshold','crit_max','reqs','system',
    sysdate,'Apache::Traffic');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 121,'warnreqs','threshold','warn_max','reqs','system',
    sysdate,'Apache::Traffic');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 121,'criticaltraffic','threshold','crit_max','traffic','system',
    sysdate,'Apache::Traffic');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 121,'warntraffic','threshold','warn_max','traffic','system',
    sysdate,'Apache::Traffic');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 10,'warning','threshold','warn_max','latency','system',
    sysdate,'NetworkService::FTP');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 10,'critical','threshold','crit_max','latency','system',
    sysdate,'NetworkService::FTP');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 42,'warning','threshold','warn_max','latency','system',
    sysdate,'NetworkService::IMAP');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 42,'critical','threshold','crit_max','latency','system',
    sysdate,'NetworkService::IMAP');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 8,'warning','threshold','warn_max','latency','system',
    sysdate,'NetworkService::SMTP');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 8,'critical','threshold','crit_max','latency','system',
    sysdate,'NetworkService::SMTP');

insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 9,'warning','threshold','warn_max','latency','system',
    sysdate,'NetworkService::POP');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 9,'critical','threshold','crit_max','latency','system',
    sysdate,'NetworkService::POP');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 13,'warn_loss','threshold','warn_max','pctlost','system',
    sysdate,'NetworkService::Ping');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 13,'critical_loss','threshold','crit_max','pctlost','system',
    sysdate,'NetworkService::Ping');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 13,'warn_time','threshold','warn_max','pingtime','system',
    sysdate,'NetworkService::Ping');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 13,'critical_time','threshold','crit_max','pingtime','system',
    sysdate,'NetworkService::Ping');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 48,'warning','threshold','warn_max','latency','system',
    sysdate,'NetworkService::RPC');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 48,'critical','threshold','crit_max','latency','system',
    sysdate,'NetworkService::RPC');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 56,'warning','threshold','warn_max','latency','system',
    sysdate,'NetworkService::HTTPS');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 56,'critical','threshold','crit_max','latency','system',
    sysdate,'NetworkService::HTTPS');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 11,'warning','threshold','warn_max','latency','system',
    sysdate,'NetworkService::HTTP');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 11,'critical','threshold','crit_max','latency','system',
    sysdate,'NetworkService::HTTP');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 6,'critical','threshold','crit_max','latency','system',
    sysdate,'General::TCP');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 6,'warning','threshold','warn_max','latency','system',
    sysdate,'General::TCP');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 7,'critical','threshold','crit_max','latency','system',
    sysdate,'General::TCP');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 7,'warning','threshold','warn_max','latency','system',
    sysdate,'General::TCP');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 26,'critical','threshold','crit_max','pctused','system',
    sysdate,'Unix::CPU');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 26,'warn','threshold','warn_max','pctused','system',
    sysdate,'Unix::CPU');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 118,'critical_read_above','threshold','crit_max','kbrps','system',
    sysdate,'Unix::DiskIOThroughput');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 118,'warn_read_above','threshold','warn_max','kbrps','system',
    sysdate,'Unix::DiskIOThroughput');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 118,'critical_read_below','threshold','crit_min','kbrps','system',
    sysdate,'Unix::DiskIOThroughput');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 118,'warn_read_below','threshold','warn_min','kbrps','system',
    sysdate,'Unix::DiskIOThroughput');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 118,'critical_write_above','threshold','crit_max','kbwps','system',
    sysdate,'Unix::DiskIOThroughput');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 118,'warn_write_above','threshold','warn_max','kbwps','system',
    sysdate,'Unix::DiskIOThroughput');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 118,'critical_write_below','threshold','crit_min','kbwps','system',
    sysdate,'Unix::DiskIOThroughput');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 118,'warn_write_below','threshold','warn_min','kbwps','system',
    sysdate,'Unix::DiskIOThroughput');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 29,'critical','threshold','crit_max','pctused','system',
    sysdate,'Unix::Disk');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 29,'warn','threshold','warn_max','pctused','system',
    sysdate,'Unix::Disk');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 117,'critical','threshold','crit_max','pctiused','system',
    sysdate,'Unix::Inodes');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 117,'warn','threshold','warn_max','pctiused','system',
    sysdate,'Unix::Inodes');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 25,'critical','threshold','crit_min','free','system',
    sysdate,'Unix::MemoryFree');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 25,'warn','threshold','warn_min','free','system',
    sysdate,'Unix::MemoryFree');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 31,'critical','threshold','crit_max','nprocs','system',
    sysdate,'Unix::ProcessCountTotal');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 31,'warn','threshold','warn_max','nprocs','system',
    sysdate,'Unix::ProcessCountTotal');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 19,'critical','threshold','crit_max','nprocs','system',
    sysdate,'Unix::ProcessCountTotal');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 19,'warn','threshold','warn_max','nprocs','system',
    sysdate,'Unix::ProcessCountTotal');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 230,'nblocked_critical','threshold','crit_max','nblocked','system',
    sysdate,'Unix::ProcessStateCounts');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 230,'nblocked_warn','threshold','warn_max','nblocked','system',
    sysdate,'Unix::ProcessStateCounts');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 230,'ndefunct_critical','threshold','crit_max','ndefunct','system',
    sysdate,'Unix::ProcessStateCounts');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 230,'ndefunct_warn','threshold','warn_max','ndefunct','system',
    sysdate,'Unix::ProcessStateCounts');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 230,'nstopped_critical','threshold','crit_max','nstopped','system',
    sysdate,'Unix::ProcessStateCounts');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 230,'nstopped_warn','threshold','warn_max','nstopped','system',
    sysdate,'Unix::ProcessStateCounts');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 230,'nswapped_critical','threshold','crit_max','nswapped','system',
    sysdate,'Unix::ProcessStateCounts');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 230,'nswapped_warn','threshold','warn_max','nswapped','system',
    sysdate,'Unix::ProcessStateCounts');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 228,'nchildren_critical','threshold','crit_max','nchildren','system',
    sysdate,'Unix::Process');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 228,'nchildren_warn','threshold','warn_max','nchildren','system',
    sysdate,'Unix::Process');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 228,'nthreads_critical','threshold','crit_max','nthreads','system',
    sysdate,'Unix::Process');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 228,'nthreads_warn','threshold','warn_max','nthreads','system',
    sysdate,'Unix::Process');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 228,'vsz_critical','threshold','crit_max','vsz','system',
    sysdate,'Unix::Process');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 228,'vsz_warn','threshold','warn_max','vsz','system',
    sysdate,'Unix::Process');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 28,'critical','threshold','crit_min','pctfree','system',
    sysdate,'Unix::Swap');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 28,'warn','threshold','warn_min','pctfree','system',
    sysdate,'Unix::Swap');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 249,'critical','threshold','crit_max','nconns','system',
    sysdate,'Unix::TCPConnectionsByState');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 249,'warn','threshold','warn_max','nconns','system',
    sysdate,'Unix::TCPConnectionsByState');

insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 27,'critical5','threshold','crit_max','load5','system',
    sysdate,'Unix::Load');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 27,'warn5','threshold','warn_max','load5','system',
    sysdate,'Unix::Load');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 123,'warn','threshold','warn_min','pctfree','system',
    sysdate,'Unix::VirtualMemory');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 123,'critical','threshold','crit_min','pctfree','system',
    sysdate,'Unix::VirtualMemory');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 30,'warn','threshold','warn_max','nusers','system',
    sysdate,'Unix::Users');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 30,'critical','threshold','crit_max','nusers','system',
    sysdate,'Unix::Users');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 18,'warn','threshold','warn_max','nusers','system',
    sysdate,'Unix::Users');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 18,'critical','threshold','crit_max','nusers','system',
    sysdate,'Unix::Users');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 16,'genericGTcritical','threshold','crit_max','value','system',
    sysdate,'General::SNMPCheck');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 16,'genericGTwarning','threshold','warn_max','value','system',
    sysdate,'General::SNMPCheck');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 16,'genericLTcritical','threshold','crit_min','value','system',
    sysdate,'General::SNMPCheck');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 16,'genericLTwarning','threshold','warn_min','value','system',
    sysdate,'General::SNMPCheck');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 276,'heapfreeLTwarning','threshold','warn_min','value','system',
    sysdate,'Weblogic::HeapFree');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 276,'heapfreeLTcritical','threshold','crit_min','value','system',
    sysdate,'Weblogic::HeapFree');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 276,'heapfreeGTwarning','threshold','warn_max','value','system',
    sysdate,'Weblogic::HeapFree');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 276,'heapfreeGTcritical','threshold','crit_max','value','system',
    sysdate,'Weblogic::HeapFree');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 278,'warn_min','threshold','warn_min','hit_ratio','system',
    sysdate,'Oracle::BufferCache');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 278,'crit_min','threshold','crit_min','hit_ratio','system',
    sysdate,'Oracle::BufferCache');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 279,'warn_min','threshold','warn_min','hit_ratio','system',
    sysdate,'Oracle::DataDictionaryCache');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 279,'crit_min','threshold','crit_min','hit_ratio','system',
    sysdate,'Oracle::DataDictionaryCache');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 280,'warn_max','threshold','warn_max','miss_ratio','system',
    sysdate,'Oracle::LibraryCache');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 280,'crit_max','threshold','crit_max','miss_ratio','system',
    sysdate,'Oracle::LibraryCache');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 92,'warnpct','threshold','warn_max','usedsesspct','system',
    sysdate,'Oracle::ActiveSessions');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 92,'critpct','threshold','crit_max','usedsesspct','system',
    sysdate,'Oracle::ActiveSessions');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 92,'warn','threshold','warn_max','actsession','system',
    sysdate,'Oracle::ActiveSessions');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 92,'critical','threshold','crit_max','actsession','system',
    sysdate,'Oracle::ActiveSessions');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 86,'warn','threshold','warn_max','locks','system',
    sysdate,'Oracle::Locks');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 86,'critical','threshold','crit_max','locks','system',
    sysdate,'Oracle::Locks');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 107,'critical_num_above','threshold','crit_max','regmatches','system',
    sysdate,'LogAgent::PatternMatch');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 107,'warn_num_above','threshold','warn_max','regmatches','system',
    sysdate,'LogAgent::PatternMatch');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 107,'critical_num_below','threshold','crit_min','regmatches','system',
    sysdate,'LogAgent::PatternMatch');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 107,'warn_num_below','threshold','warn_min','regmatches','system',
    sysdate,'LogAgent::PatternMatch');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 107,'critical_rate_above','threshold','crit_max','regrate','system',
    sysdate,'LogAgent::PatternMatch');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 107,'warn_rate_above','threshold','warn_max','regrate','system',
    sysdate,'LogAgent::PatternMatch');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 107,'critical_rate_below','threshold','crit_min','regrate','system',
    sysdate,'LogAgent::PatternMatch');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 107,'warn_rate_below','threshold','warn_min','regrate','system',
    sysdate,'LogAgent::PatternMatch');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 106,'critical_byte_rate_above','threshold','crit_max','byterate','system',
    sysdate,'LogAgent::Size');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 106,'warn_byte_rate_above','threshold','warn_max','byterate','system',
    sysdate,'LogAgent::Size');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 106,'critical_byte_rate_below','threshold','crit_min','byterate','system',
    sysdate,'LogAgent::Size');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 106,'warn_byte_rate_below','threshold','warn_min','byterate','system',
    sysdate,'LogAgent::Size');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 106,'critical_bytes_above','threshold','crit_max','bytes','system',
    sysdate,'LogAgent::Size');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 106,'warn_bytes_above','threshold','warn_max','bytes','system',
    sysdate,'LogAgent::Size');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 106,'critical_bytes_below','threshold','crit_min','bytes','system',
    sysdate,'LogAgent::Size');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 106,'warn_bytes_below','threshold','warn_min','bytes','system',
    sysdate,'LogAgent::Size');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 106,'critical_line_rate_above','threshold','crit_max','linerate','system',
    sysdate,'LogAgent::Size');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 106,'warn_line_rate_above','threshold','warn_max','linerate','system',
    sysdate,'LogAgent::Size');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 106,'critical_line_rate_below','threshold','crit_min','linerate','system',
    sysdate,'LogAgent::Size');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 106,'warn_line_rate_below','threshold','warn_min','linerate','system',
    sysdate,'LogAgent::Size');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 106,'critical_lines_above','threshold','crit_max','lines','system',
    sysdate,'LogAgent::Size');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 106,'warn_lines_above','threshold','warn_max','lines','system',
    sysdate,'LogAgent::Size');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 106,'critical_lines_below','threshold','crit_min','lines','system',
    sysdate,'LogAgent::Size');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 106,'warn_lines_below','threshold','warn_min','lines','system',
    sysdate,'LogAgent::Size');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 93,'criticalabove','threshold','crit_max','open','system',
    sysdate,'MySQL::Open');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 93,'warnabove','threshold','warn_max','open','system',
    sysdate,'MySQL::Open');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 93,'criticalbelow','threshold','crit_min','open','system',
    sysdate,'MySQL::Open');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 93,'warnbelow','threshold','warn_min','open','system',
    sysdate,'MySQL::Open');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 94,'criticalabove','threshold','crit_max','opened','system',
    sysdate,'MySQL::Opened');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 94,'warnabove','threshold','warn_max','opened','system',
    sysdate,'MySQL::Opened');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 94,'criticalbelow','threshold','crit_min','opened','system',
    sysdate,'MySQL::Opened');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 94,'warnbelow','threshold','warn_min','opened','system',
    sysdate,'MySQL::Opened');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 95,'criticalabove','threshold','crit_max','threads','system',
    sysdate,'MySQL::Threads');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 95,'warnabove','threshold','warn_max','threads','system',
    sysdate,'MySQL::Threads');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 95,'criticalbelow','threshold','crit_min','threads','system',
    sysdate,'MySQL::Threads');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 95,'warnbelow','threshold','warn_min','threads','system',
    sysdate,'MySQL::Threads');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 96,'criticalabove','threshold','crit_max','qps','system',
    sysdate,'MySQL::Queries');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 96,'warnabove','threshold','warn_max','qps','system',
    sysdate,'MySQL::Queries');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 96,'criticalbelow','threshold','crit_min','qps','system',
    sysdate,'MySQL::Queries');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 96,'warnbelow','threshold','warn_min','qps','system',
    sysdate,'MySQL::Queries');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 23,'warn_latency','threshold','warn_max','latency','system',
    sysdate,'Oracle::TNSping');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 23,'critical_latency','threshold','crit_max','latency','system',
    sysdate,'Oracle::TNSping');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 284,'req_warn_max','threshold','warn_max','requests','system',
    sysdate,'Oracle::RedoLog');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 284,'req_crit_max','threshold','crit_max','requests','system',
    sysdate,'Oracle::RedoLog');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 284,'retry_warn_max','threshold','warn_max','retries','system',
    sysdate,'Oracle::RedoLog');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 284,'retry_crit_max','threshold','crit_max','retries','system',
    sysdate,'Oracle::RedoLog');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 85,'critical','threshold','crit_max','blksession','system',
    sysdate,'Oracle::BlockingSessions');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 85,'warn','threshold','warn_max','blksession','system',
    sysdate,'Oracle::BlockingSessions');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 90,'critical','threshold','crit_max','idlsession','system',
    sysdate,'Oracle::IdleSessions');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 90,'warn','threshold','warn_max','idlsession','system',
    sysdate,'Oracle::IdleSessions');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 283,'warn_max','threshold','warn_max','ratio','system',
    sysdate,'Oracle::DiskSort');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 283,'crit_max','threshold','crit_max','ratio','system',
    sysdate,'Oracle::DiskSort');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 282,'connectionsGTwarning','threshold','warn_max','connections','system',
    sysdate,'Weblogic::JDBCConnectionPool');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 282,'connectionsGTcritical','threshold','crit_max','connections','system',
    sysdate,'Weblogic::JDBCConnectionPool');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 282,'connrateGTwarning','threshold','warn_max','conn_rate','system',
    sysdate,'Weblogic::JDBCConnectionPool');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 282,'connrateGTcritical','threshold','crit_max','conn_rate','system',
    sysdate,'Weblogic::JDBCConnectionPool');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 282,'waitersGTwarning','threshold','warn_max','waiters','system',
    sysdate,'Weblogic::JDBCConnectionPool');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 282,'waitersGTcritical','threshold','crit_max','waiters','system',
    sysdate,'Weblogic::JDBCConnectionPool');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 281,'idlethreadsGTwarning','threshold','warn_max','idle_threads','system',
    sysdate,'Weblogic::ExecuteQueue');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 281,'idlethreadsGTcritical','threshold','crit_max','idle_threads','system',
    sysdate,'Weblogic::ExecuteQueue');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 281,'queuelengthGTwarning','threshold','warn_max','queue_length','system',
    sysdate,'Weblogic::ExecuteQueue');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 281,'queuelengthGTcritical','threshold','crit_max','queue_length','system',
    sysdate,'Weblogic::ExecuteQueue');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 281,'requestrateGTwarning','threshold','warn_max','request_rate','system',
    sysdate,'Weblogic::ExecuteQueue');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 281,'requestrateGTcritical','threshold','crit_max','request_rate','system',
    sysdate,'Weblogic::ExecuteQueue');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 288,'exectimemvaveGTwarning','threshold','warn_max','exec_move_ave','system',
    sysdate,'Weblogic::Servlet');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 288,'exectimemvaveGTcritical','threshold','crit_max','exec_move_ave','system',
    sysdate,'Weblogic::Servlet');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 288,'highexectimeGTwarning','threshold','warn_max','high_exec_time','system',
    sysdate,'Weblogic::Servlet');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 288,'highexectimeGTcritical','threshold','crit_max','high_exec_time','system',
    sysdate,'Weblogic::Servlet');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 29,'warn_used','threshold','warn_max','space_used','system',
    sysdate,'Unix::Disk');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 29,'critical_used','threshold','crit_max','space_used','system',
    sysdate,'Unix::Disk');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 29,'warn_avail','threshold','warn_min','space_avail','system',
    sysdate,'Unix::Disk');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 29,'critical_avail','threshold','crit_min','space_avail','system',
    sysdate,'Unix::Disk');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 228,'cpu_time_rt_warn','threshold','warn_max','cpu_time_rt','system',
    sysdate,'Unix::Process');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 228,'cpu_time_rt_critical','threshold','crit_max','cpu_time_rt','system',
    sysdate,'Unix::Process');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 228,'physical_mem_used_warn','threshold','warn_max','physical_mem_used','system',
    sysdate,'Unix::Process');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 228,'physical_mem_used_critical','threshold','crit_max','physical_mem_used','system',
    sysdate,'Unix::Process');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 229,'cpu_time_rt_warn','threshold','warn_max','cpu_time_rt','system',
    sysdate,'Unix::Process');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 229,'cpu_time_rt_critical','threshold','crit_max','cpu_time_rt','system',
    sysdate,'Unix::Process');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 229,'physical_mem_used_warn','threshold','warn_max','physical_mem_used','system',
    sysdate,'Unix::Process');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 229,'physical_mem_used_critical','threshold','crit_max','physical_mem_used','system',
    sysdate,'Unix::Process');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 229,'nchildren_warn','threshold','warn_max','nchildren','system',
    sysdate,'Unix::Process');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 229,'nchildren_critical','threshold','crit_max','nchildren','system',
    sysdate,'Unix::Process');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 229,'nthreads_warn','threshold','warn_max','nthreads','system',
    sysdate,'Unix::Process');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 229,'nthreads_critical','threshold','crit_max','nthreads','system',
    sysdate,'Unix::Process');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 229,'vsz_warn','threshold','warn_max','vsz','system',
    sysdate,'Unix::Process');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 229,'vsz_critical','threshold','crit_max','vsz','system',
    sysdate,'Unix::Process');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 17,'warn','threshold','warn_max','pctused','system',
    sysdate,'Unix::Disk');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 17,'critical','threshold','crit_max','pctused','system',
    sysdate,'Unix::Disk');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 17,'warn_used','threshold','warn_max','space_used','system',
    sysdate,'Unix::Disk');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 17,'critical_used','threshold','crit_max','space_used','system',
    sysdate,'Unix::Disk');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 17,'warn_avail','threshold','warn_min','space_avail','system',
    sysdate,'Unix::Disk');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 17,'critical_avail','threshold','crit_min','space_avail','system',
    sysdate,'Unix::Disk');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 249,'critical_TIME_WAIT','threshold','crit_max','time_wait_conn','system',
    sysdate,'Unix::TCPConnectionsByState');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 249,'warn_TIME_WAIT','threshold','warn_max','time_wait_conn','system',
    sysdate,'Unix::TCPConnectionsByState');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 249,'critical_CLOSE_WAIT','threshold','crit_max','close_wait_conn','system',
    sysdate,'Unix::TCPConnectionsByState');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 249,'warn_CLOSE_WAIT','threshold','warn_max','close_wait_conn','system',
    sysdate,'Unix::TCPConnectionsByState');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 249,'critical_FIN_WAIT','threshold','crit_max','fin_wait_conn','system',
    sysdate,'Unix::TCPConnectionsByState');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 249,'warn_FIN_WAIT','threshold','warn_max','fin_wait_conn','system',
    sysdate,'Unix::TCPConnectionsByState');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 249,'critical_ESTABLISHED','threshold','crit_max','established_conn','system',
    sysdate,'Unix::TCPConnectionsByState');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 249,'warn_ESTABLISHED','threshold','warn_max','established_conn','system',
    sysdate,'Unix::TCPConnectionsByState');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 249,'critical_SYN_RCVD','threshold','crit_max','syn_rcvd_conn','system',
    sysdate,'Unix::TCPConnectionsByState');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 249,'warn_SYN_RCVD','threshold','warn_max','syn_rcvd_conn','system',
    sysdate,'Unix::TCPConnectionsByState');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 22,'warn','threshold','warn_min','pctfree','system',
    sysdate,'Unix::Swap');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 22,'critical','threshold','crit_min','pctfree','system',
    sysdate,'Unix::Swap');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 105,'InTrafficLTwarning','threshold','warn_min','in_byte_rt','system',
    sysdate,'Unix::InterfaceTraffic');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 105,'InTrafficLTcritical','threshold','crit_min','in_byte_rt','system',
    sysdate,'Unix::InterfaceTraffic');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 105,'InTrafficGTwarning','threshold','warn_max','in_byte_rt','system',
    sysdate,'Unix::InterfaceTraffic');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 105,'InTrafficGTcritical','threshold','crit_max','in_byte_rt','system',
    sysdate,'Unix::InterfaceTraffic');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 105,'OutTrafficLTwarning','threshold','warn_min','out_byte_rt','system',
    sysdate,'Unix::InterfaceTraffic');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 105,'OutTrafficLTcritical','threshold','crit_min','out_byte_rt','system',
    sysdate,'Unix::InterfaceTraffic');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 105,'OutTrafficGTwarning','threshold','warn_max','out_byte_rt','system',
    sysdate,'Unix::InterfaceTraffic');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 105,'OutTrafficGTcritical','threshold','crit_max','out_byte_rt','system',
    sysdate,'Unix::InterfaceTraffic');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 254,'intrafficGTcritical','threshold','crit_max','in_byte_rt','system',
    sysdate,'Unix::InterfaceTraffic');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 254,'outtrafficGTcritical','threshold','crit_max','out_byte_rt','system',
    sysdate,'Unix::InterfaceTraffic');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 20,'critical1','threshold','crit_max','load1','system',
    sysdate,'Unix::Load');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 20,'warn1','threshold','warn_max','load1','system',
    sysdate,'Unix::Load');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 20,'critical15','threshold','crit_max','load15','system',
    sysdate,'Unix::Load');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 20,'warn15','threshold','warn_max','load15','system',
    sysdate,'Unix::Load');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 20,'critical5','threshold','crit_max','load5','system',
    sysdate,'Unix::Load');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 20,'warn5','threshold','warn_max','load5','system',
    sysdate,'Unix::Load');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 27,'critical1','threshold','crit_max','load1','system',
    sysdate,'Unix::Load');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 27,'warn1','threshold','warn_max','load1','system',
    sysdate,'Unix::Load');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 27,'critical15','threshold','crit_max','load15','system',
    sysdate,'Unix::Load');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 27,'warn15','threshold','warn_max','load15','system',
    sysdate,'Unix::Load');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 14,'critical_time','threshold','crit_max','query_time','system',
    sysdate,'Unix::Dig');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 14,'warning_time','threshold','warn_max','query_time','system',
    sysdate,'Unix::Dig');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 61,'warning','threshold','warn_max','probes','system',
    sysdate,'Satellite::ProbeCount');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 61,'critical','threshold','crit_max','probes','system',
    sysdate,'Satellite::ProbeCount');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 60,'warning','threshold','warn_max','probextm','system',
    sysdate,'Satellite::ProbeExecTime');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 60,'critical','threshold','crit_max','probextm','system',
    sysdate,'Satellite::ProbeExecTime');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 24,'w_latency','threshold','warn_max','probelatnc','system',
    sysdate,'Satellite::ProbeLatency');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 24,'c_latency','threshold','crit_max','probelatnc','system',
    sysdate,'Satellite::ProbeLatency');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 304,'critical_time','threshold','crit_max','pingtime','system',
    sysdate,'NetworkService::Ping');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 304,'warn_time','threshold','warn_max','pingtime','system',
    sysdate,'NetworkService::Ping');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 304,'critical_loss','threshold','crit_max','pctlost','system',
    sysdate,'NetworkService::Ping');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 304,'warn_loss','threshold','warn_max','pctlost','system',
    sysdate,'NetworkService::Ping');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 231,'nblocked_critical','threshold','crit_max','nblocked','system',
    sysdate,'Unix::ProcessStateCounts');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 231,'nblocked_warn','threshold','warn_max','nblocked','system',
    sysdate,'Unix::ProcessStateCounts');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 231,'ndefunct_critical','threshold','crit_max','ndefunct','system',
    sysdate,'Unix::ProcessStateCounts');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 231,'ndefunct_warn','threshold','warn_max','ndefunct','system',
    sysdate,'Unix::ProcessStateCounts');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 231,'nstopped_critical','threshold','crit_max','nstopped','system',
    sysdate,'Unix::ProcessStateCounts');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 231,'nstopped_warn','threshold','warn_max','nstopped','system',
    sysdate,'Unix::ProcessStateCounts');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 231,'nswapped_critical','threshold','crit_max','nswapped','system',
    sysdate,'Unix::ProcessStateCounts');
insert into rhn_command_param_threshold(command_id,param_name,param_type,
threshold_type_name,threshold_metric_id,last_update_user,last_update_date,
command_class) 
    values ( 231,'nswapped_warn','threshold','warn_max','nswapped','system',
    sysdate,'Unix::ProcessStateCounts');
