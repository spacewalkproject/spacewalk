-- created by Oraschemadoc Fri Jan 22 13:41:03 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE PROCEDURE "MIM_H1"."RHN_PREPARE_INSTALL" 
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
