--
--$Id
--
-- 
--

--data for rhn_physical_location (uses sequence!!!)

insert into rhn_physical_location(recid, location_name, last_update_user, last_update_date)
    values (rhn_physical_loc_recid_seq.nextval, 'Generic All-Encompassing Location','system', sysdate); 

commit;

--$Log$
--Revision 1.1  2004/06/22 02:35:10  kja
--bugzilla 126462 -- create dummy physical_location data
--
