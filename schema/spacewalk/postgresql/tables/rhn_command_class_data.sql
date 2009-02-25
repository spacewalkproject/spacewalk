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

--data for rhn_command_class

insert into rhn_command_class(class_name) 
    values ( 'Apache::Processes');
insert into rhn_command_class(class_name) 
    values ( 'Apache::Traffic');
insert into rhn_command_class(class_name) 
    values ( 'Apache::Uptime');
insert into rhn_command_class(class_name) 
    values ( 'Unix::CPU');
insert into rhn_command_class(class_name) 
    values ( 'Unix::Dig');
insert into rhn_command_class(class_name) 
    values ( 'Unix::Disk');
insert into rhn_command_class(class_name) 
    values ( 'Unix::DiskIOThroughput');
insert into rhn_command_class(class_name) 
    values ( 'NetworkService::FTP');
insert into rhn_command_class(class_name) 
    values ( 'NetworkService::HTTP');
insert into rhn_command_class(class_name) 
    values ( 'NetworkService::HTTPS');
insert into rhn_command_class(class_name) 
    values ( 'NetworkService::IMAP');
insert into rhn_command_class(class_name) 
    values ( 'Unix::Process');
insert into rhn_command_class(class_name) 
    values ( 'Unix::Inodes');
insert into rhn_command_class(class_name) 
    values ( 'Unix::Load');
insert into rhn_command_class(class_name) 
    values ( 'LogAgent::PatternMatch');
insert into rhn_command_class(class_name) 
    values ( 'LogAgent::Size');
insert into rhn_command_class(class_name) 
    values ( 'Satellite::LongLegs');
insert into rhn_command_class(class_name) 
    values ( 'Unix::MemoryFree');
insert into rhn_command_class(class_name) 
    values ( 'MySQL::Accessibility');
insert into rhn_command_class(class_name) 
    values ( 'MySQL::Open');
insert into rhn_command_class(class_name) 
    values ( 'MySQL::Opened');
insert into rhn_command_class(class_name) 
    values ( 'MySQL::Queries');
insert into rhn_command_class(class_name) 
    values ( 'MySQL::Threads');
insert into rhn_command_class(class_name) 
    values ( 'General::SNMPCheck');
insert into rhn_command_class(class_name) 
    values ( 'General::UptimeSNMP');
insert into rhn_command_class(class_name) 
    values ( 'Unix::InterfaceTraffic');
insert into rhn_command_class(class_name) 
    values ( 'General::SNMPTrapParser');
insert into rhn_command_class(class_name) 
    values ( 'Satellite::ProbeCount');
insert into rhn_command_class(class_name) 
    values ( 'Satellite::ProbeExecTime');
insert into rhn_command_class(class_name) 
    values ( 'Satellite::ProbeLatency');
insert into rhn_command_class(class_name) 
    values ( 'General::CheckNothing');
insert into rhn_command_class(class_name) 
    values ( 'Oracle::TablespaceUsage');
insert into rhn_command_class(class_name) 
    values ( 'Oracle::BlockingSessions');
insert into rhn_command_class(class_name) 
    values ( 'Oracle::IndexExtents');
insert into rhn_command_class(class_name) 
    values ( 'Oracle::TableExtents');
insert into rhn_command_class(class_name) 
    values ( 'Oracle::IdleSessions');
insert into rhn_command_class(class_name) 
    values ( 'Oracle::Availability');
insert into rhn_command_class(class_name) 
    values ( 'Oracle::Locks');
insert into rhn_command_class(class_name) 
    values ( 'Oracle::ActiveSessions');
insert into rhn_command_class(class_name) 
    values ( 'NetworkService::POP');
insert into rhn_command_class(class_name) 
    values ( 'NetworkService::Ping');
insert into rhn_command_class(class_name) 
    values ( 'Unix::ProcessStateCounts');
insert into rhn_command_class(class_name) 
    values ( 'Unix::ProcessCountTotal');
insert into rhn_command_class(class_name) 
    values ( 'Satellite::CurrentStatePush');
insert into rhn_command_class(class_name) 
    values ( 'NetworkService::RPC');
insert into rhn_command_class(class_name) 
    values ( 'NetworkService::SMTP');
insert into rhn_command_class(class_name) 
    values ( 'NetworkService::SSH');
insert into rhn_command_class(class_name) 
    values ( 'Unix::Swap');
insert into rhn_command_class(class_name) 
    values ( 'General::TCP');
insert into rhn_command_class(class_name) 
    values ( 'Unix::TCPConnectionsByState');
insert into rhn_command_class(class_name) 
    values ( 'Oracle::TNSping');
insert into rhn_command_class(class_name) 
    values ( 'General::RemoteProgram');
insert into rhn_command_class(class_name) 
    values ( 'Unix::Users');
insert into rhn_command_class(class_name) 
    values ( 'Unix::VirtualMemory');
insert into rhn_command_class(class_name) 
    values ( 'General::RemoteProgramWithData');
insert into rhn_command_class(class_name) 
    values ( 'Weblogic::State');
insert into rhn_command_class(class_name) 
    values ( 'Weblogic::HeapFree');
insert into rhn_command_class(class_name) 
    values ( 'Windows::LoadAverage');
insert into rhn_command_class(class_name) 
    values ( 'Oracle::BufferCache');
insert into rhn_command_class(class_name) 
    values ( 'Oracle::DataDictionaryCache');
insert into rhn_command_class(class_name) 
    values ( 'Oracle::LibraryCache');
insert into rhn_command_class(class_name) 
    values ( 'Oracle::RedoLog');
insert into rhn_command_class(class_name) 
    values ( 'Oracle::DiskSort');
insert into rhn_command_class(class_name) 
    values ( 'Weblogic::JDBCConnectionPool');
insert into rhn_command_class(class_name) 
    values ( 'Weblogic::ExecuteQueue');
insert into rhn_command_class(class_name) 
    values ( 'Weblogic::Servlet');
insert into rhn_command_class(class_name) 
    values ( 'Oracle::ClientConnectivity');
insert into rhn_command_class(class_name) 
    values ( 'Unix::ProcessRunning');
