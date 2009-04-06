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
rhn_install_org_satellites
(
    for_customer_id in web_customer.id%type,
    sat_cluster_id in rhn_sat_cluster.recid%type,
    username in rhn_command_queue_instances.last_update_user%type
) returns void 
as
$$ 
declare

-- the cursor is defined such that the following behavior occurs based on the sat_cluster_id param:
--   null results in all of a customer's scout being configured.
--   an id for a scout belonging to the cust results in just that scout being configured
--   an id for a scout not belonging to the cust results in no action.

    satellite_cursor cursor for
        select recid from rhn_sat_cluster
        where customer_id = for_customer_id
        and recid not in (
            select netsaint_id from rhn_ll_netsaint
        )
        except
        select recid from rhn_sat_cluster
        where customer_id = for_customer_id
        and recid not in (sat_cluster_id);

    command_instance_id rhn_command_queue_instances.recid%type;

begin
    rhn_prepare_install(username, command_instance_id, 1);

    for satellite in satellite_cursor loop
        rhn_install_satellite(command_instance_id, satellite.recid);
    end loop;
end 
$$
language plpgsql;

