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

create or replace function
rhn_prepare_install
(
    username            in rhn_command_queue_instances.last_update_user%type,
    command_instance_id in out rhn_command_queue_instances.recid%type,
    install_command     in rhn_command_queue_instances.command_id%type
)
returns numeric
as $$
declare
    /* ignore this command if it has not been run after five minutes */
    stale_after_minutes numeric := 10;

    /* should take no more than five minutes to run the install */
    max_execution_time_seconds numeric := 10 * 60;

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
        current_timestamp + stale_after_minutes * '1 minute'::interval,
        null, /* no notification email */
        max_execution_time_seconds,
        current_timestamp,
        username,
        current_timestamp
    );
end; $$
language plpgsql;
