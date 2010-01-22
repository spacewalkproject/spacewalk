-- created by Oraschemadoc Fri Jan 22 13:41:03 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE PROCEDURE "MIM_H1"."RHN_INSTALL_ORG_SATELLITES" 
(
    for_customer_id in web_customer.id%type,
    sat_cluster_id in rhn_sat_cluster.recid%type,
    username in rhn_command_queue_instances.last_update_user%type
)
is


    cursor satellite_cursor is
        select recid from rhn_sat_cluster
        where customer_id = for_customer_id
        and recid not in (
            select netsaint_id from rhn_ll_netsaint
        )
        minus
        select recid from rhn_sat_cluster
        where customer_id = for_customer_id
        and recid not in (sat_cluster_id);

    command_instance_id rhn_command_queue_instances.recid%type;

begin
    rhn_prepare_install(username, command_instance_id, 1);

    for satellite in satellite_cursor loop
        rhn_install_satellite(command_instance_id, satellite.recid);
    end loop;
end rhn_install_org_satellites;
 
/
