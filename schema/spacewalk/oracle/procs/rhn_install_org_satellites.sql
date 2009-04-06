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
rhn_install_org_satellites
(
    for_customer_id in web_customer.id%type,
    sat_cluster_id in rhn_sat_cluster.recid%type,
    username in rhn_command_queue_instances.last_update_user%type
) 
is
   
-- the cursor is defined such that the following behavior occurs based on the sat_cluster_id param: 
--   null results in all of a customer's scout being configured.
--   an id for a scout belonging to the cust results in just that scout being configured 
--   an id for a scout not belonging to the cust results in no action.

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
show errors

--
--Revision 1.5  2004/06/03 20:19:54  pjones
--bugzilla: none -- use procedure names after "end".
--
--Revision 1.4  2004/05/28 22:05:14  pjones
--bugzilla: none -- "rhn_install_customer_satellites" is too long.
--
--Revision 1.3  2004/05/27 20:17:38  kja
--tweaks to syntax.
--
--Revision 1.2  2004/05/10 17:25:08  kja
--Fixing syntax things with the stored procs.
--
--Revision 1.1  2004/04/21 20:47:41  kja
--Added the npcfdb stored procedures.  Renamed the nolog procs to rhn_.
--
