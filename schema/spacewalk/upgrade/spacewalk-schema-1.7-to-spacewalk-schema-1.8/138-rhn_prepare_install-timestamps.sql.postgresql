-- oracle equivalent source sha1 d0d8d78f5b53c8887c9fdf3175ae44da2570a698
--
-- Copyright (c) 2008--2012 Red Hat, Inc.
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

--monitoring stored procedure

create or replace function
rhn_prepare_install
(
    username            in rhn_command_queue_instances.last_update_user%type,
    install_command     in rhn_command_queue_instances.command_id%type
)
returns rhn_command_queue_instances.recid%type
as $$
declare
    command_instance_id rhn_command_queue_instances.recid%type;
begin
    select nextval('rhn_command_q_inst_recid_seq')
    into command_instance_id;
    

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
        /* ignore this command if it has not been run after ten minutes */
        current_timestamp + '10 minute'::interval,
        null, /* no notification email */
        /* should take no more than five minutes to run the install */
        600,
        current_timestamp,
        username,
        current_timestamp
    );

    return command_instance_id;
end; $$
language plpgsql;
