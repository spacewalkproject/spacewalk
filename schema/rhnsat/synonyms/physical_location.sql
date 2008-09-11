--
--$Id$
--

--create special physical_location synonyms for monitoring backend code to function as is

create or replace synonym physical_location for rhn_physical_location;
create or replace synonym physical_location_recid_seq for rhn_physical_loc_recid_seq;

--
--$Log$
--Revision 1.1  2004/06/23 15:01:07  kja
--bugzilla 126465 -- fix synonyms for monitoring backend
--
--
