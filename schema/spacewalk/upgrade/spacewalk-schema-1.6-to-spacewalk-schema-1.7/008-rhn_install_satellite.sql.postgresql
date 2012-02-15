-- oracle equivalent source sha1 b14267384bc104605623a41b755e68e0103b5aa8

drop function if exists rhn_install_satellite(command_instance_id smallint, satellite_id numeric);

create or replace function
rhn_install_satellite
(
    command_instance_id in rhn_command_queue_instances.recid%type,
    satellite_id in rhn_sat_cluster.recid%type
)
returns void
as $$

begin
    insert into rhn_command_queue_execs (
           instance_id,
           netsaint_id,
           target_type)
    values (command_instance_id, satellite_id, 'cluster');
end; $$ language plpgsql;

