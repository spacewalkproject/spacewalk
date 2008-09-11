--
--$Id$
--

--create special sat_node synonyms for monitoring backend code to function as is

create or replace synonym sat_node for rhn_sat_node;

--
--$Log$
--Revision 1.1  2004/06/23 15:01:07  kja
--bugzilla 126465 -- fix synonyms for monitoring backend
--
--
