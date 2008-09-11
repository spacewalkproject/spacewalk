--
--$Id$
--
-- 
--

--data for rhn_command_groups

insert into rhn_command_groups(group_name,description) 
    values ( 'bea_61','BEA Weblogic');
insert into rhn_command_groups(group_name,description) 
    values ( 'oracle','Oracle');
insert into rhn_command_groups(group_name,description) 
    values ( 'mysql','MySQL');
insert into rhn_command_groups(group_name,description) 
    values ( 'netservice','Network Services');
insert into rhn_command_groups(group_name,description) 
    values ( 'satellite','Satellite');
insert into rhn_command_groups(group_name,description) 
    values ( 'logagent','Log Agent');
insert into rhn_command_groups(group_name,description) 
    values ( 'all','All');
insert into rhn_command_groups(group_name,description) 
    values ( 'apache','Apache');
insert into rhn_command_groups(group_name,description) 
    values ( 'linux','Linux');
insert into rhn_command_groups(group_name,description) 
    values ( 'tools','General');
commit;

--$Log$
--Revision 1.6  2004/08/02 22:14:10  dfaraldo
--Changed 'Unix' command group to 'Linux'. -dfaraldo
--
--Revision 1.5  2004/06/17 20:48:59  kja
--bugzilla 124970 -- _data is in for 350.
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
--Revision 1.1  2004/04/22 20:27:40  kja
--More reference table data.
--
