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

--data for rhn_command_queue_commands
--pared down from original list to bare essentials

insert into rhn_command_queue_commands(recid,description,notes,command_line,
permanent,restartable,effective_user,effective_group,last_update_user,
last_update_date) 
    values (
1,'Satellite configuration installation','"Install Changes" on a satellite (i.e. push the monitoring config)','/usr/bin/scheduleEvents','1','0','nocpulse','nocpulse','system',sysdate);

insert into rhn_command_queue_commands(recid,description,notes,command_line,
permanent,restartable,effective_user,effective_group,last_update_user,
last_update_date) 
    values (
rhn_command_q_comm_recid_seq.nextval,'ANY SHELL COMMAND (as root)','Pick your command at execution time!  :)','%s','1','0','root','root','system',sysdate);

insert into rhn_command_queue_commands(recid,description,notes,command_line,
permanent,restartable,effective_user,effective_group,last_update_user,
last_update_date) 
    values (
rhn_command_q_comm_recid_seq.nextval,'ANY command as nocpulse','Enter any command - it will run as the nocpulse user','%s','1','0','nocpulse','nocpulse','system',sysdate);
commit;

--
--Revision 1.5  2004/06/17 20:48:59  kja
--bugzilla 124970 -- _data is in for 350.
--
--Revision 1.4  2004/05/29 21:51:49  pjones
--bugzilla: none -- _data is not for 340, so says kja.
--
--Revision 1.3  2004/05/28 19:44:56  pjones
--bugzilla: none -- make it use right schema names...
--
--Revision 1.2  2004/05/04 20:03:38  kja
--Added commits.
--
--Revision 1.1  2004/04/23 18:27:47  kja
--More reference table data.
--
