--
--$Id$
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

--$Log$
--Revision 1.3  2004/06/03 20:19:54  pjones
--bugzilla: none -- use procedure names after "end".
--
--Revision 1.2  2004/05/10 17:25:08  kja
--Fixing syntax things with the stored procs.
--
--Revision 1.1  2004/04/21 20:47:41  kja
--Added the npcfdb stored procedures.  Renamed the nolog procs to rhn_.
--
