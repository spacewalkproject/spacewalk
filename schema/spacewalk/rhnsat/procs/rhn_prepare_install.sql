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

--monitoring stored procedure
create or replace procedure 
rhn_prepare_install
(
    username            in rhn_command_queue_instances.last_update_user%type,
    command_instance_id in out rhn_command_queue_instances.recid%type,
    install_command     in rhn_command_queue_instances.command_id%type
) 
is
    /* ignore this command if it has not been run after five minutes */
    stale_after_minutes number := 10;

    /* should take no more than five minutes to run the install */
    max_execution_time_seconds number := 10 * 60;

begin
    select rhn_command_q_inst_recid_seq.nextval
    into command_instance_id
    from dual;

    insert into rhn_command_queue_instances (
        recid,
        command_id,
        notes,
        expiration_date,
        notify_email,
        timeout,
        date_submitted,
        last_update_user,
        last_update_date
    )
    values (
        command_instance_id,
        install_command,
        null, /* no notes */
        sysdate + (stale_after_minutes / (60*24)),
        null, /* no notification email */
        max_execution_time_seconds,
        sysdate,
        username,
        sysdate
    );
end rhn_prepare_install;
/
show errors

--
--Revision 1.4  2004/06/03 20:19:54  pjones
--bugzilla: none -- use procedure names after "end".
--
--Revision 1.3  2004/05/27 21:41:38  pjones
--bugzilla: none -- use - rhn_command_q_inst_recid_seq instead of
--command_q_instance_recid_seq
--
--Revision 1.2  2004/05/10 17:25:08  kja
--Fixing syntax things with the stored procs.
--
--Revision 1.1  2004/04/21 20:47:41  kja
--Added the npcfdb stored procedures.  Renamed the nolog procs to rhn_.
--
