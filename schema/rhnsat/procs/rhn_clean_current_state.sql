--
--$Id$
--
--

--monitoring stored procedure
--originally from the nolog instance
create or replace procedure 
rhn_clean_current_state
(
    for_customer_id in rhn_probe.customer_id%type
) is
begin
    null;
end rhn_clean_current_state;
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
--Revision 1.1  2004/04/21 20:09:51  kja
--Added nolog stored procedures.
--
