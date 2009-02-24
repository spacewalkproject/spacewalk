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
--commit;

