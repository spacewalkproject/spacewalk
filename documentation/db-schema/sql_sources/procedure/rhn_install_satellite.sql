-- created by Oraschemadoc Fri Jan 22 13:41:03 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE PROCEDURE "SPACEWALK"."RHN_INSTALL_SATELLITE"
(
    command_instance_id in rhn_command_queue_instances.recid%type,
    satellite_id in rhn_sat_cluster.recid%type
)
is

begin
    insert into rhn_command_queue_execs (
           instance_id,
           netsaint_id,
           target_type)
    values (command_instance_id, satellite_id, 'cluster');
end rhn_install_satellite;
 
/
