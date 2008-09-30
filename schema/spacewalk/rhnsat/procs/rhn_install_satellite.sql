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
rhn_install_satellite
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
show errors

--
--Revision 1.3  2004/06/03 20:19:54  pjones
--bugzilla: none -- use procedure names after "end".
--
--Revision 1.2  2004/05/10 17:25:08  kja
--Fixing syntax things with the stored procs.
--
--Revision 1.1  2004/04/21 20:47:41  kja
--Added the npcfdb stored procedures.  Renamed the nolog procs to rhn_.
--
