-- oracle equivalent source sha1 b14267384bc104605623a41b755e68e0103b5aa8

create or replace function
rhn_prepare_install
(
    username            in rhn_command_queue_instances.last_update_user%type,
    command_instance_id in out rhn_command_queue_instances.recid%type,
    install_command     in rhn_command_queue_instances.command_id%type
)
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
