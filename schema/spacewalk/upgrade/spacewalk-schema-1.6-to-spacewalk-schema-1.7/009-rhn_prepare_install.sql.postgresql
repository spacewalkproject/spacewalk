-- oracle equivalent source sha1 b14267384bc104605623a41b755e68e0103b5aa8

create or replace function
rhn_prepare_install
(
    username            in rhn_command_queue_instances.last_update_user%type,
    install_command     in rhn_command_queue_instances.command_id%type
)
returns rhn_command_queue_instances.recid%type
as $$
declare
    /* ignore this command if it has not been run after five minutes */
    stale_after_minutes numeric := 10;

    /* should take no more than five minutes to run the install */
    max_execution_time_seconds numeric := 10 * 60;

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
        current_timestamp + stale_after_minutes * '1 minute'::interval,
        null, /* no notification email */
        max_execution_time_seconds,
        current_timestamp,
        username,
        current_timestamp
    );

    return command_instance_id;
end; $$
language plpgsql;

drop function if exists rhn_prepare_install(username character varying, INOUT command_instance_id smallint, install_command smallint);
drop function if exists rhn_prepare_install(username character varying, INOUT command_instance_id numeric, install_command numeric);
