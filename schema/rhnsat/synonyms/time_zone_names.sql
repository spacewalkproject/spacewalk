--
--$Id$
--

--create special time_zone_names synonyms for monitoring backend code to function as is

create or replace synonym time_zone_names for rhn_time_zone_names;

--
--$Log$
--Revision 1.1  2004/06/23 15:01:07  kja
--bugzilla 126465 -- fix synonyms for monitoring backend
--
--
