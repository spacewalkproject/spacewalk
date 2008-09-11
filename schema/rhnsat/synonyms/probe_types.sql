--
--$Id$
--

--create special probe_types synonyms for monitoring backend code to function as is

create or replace synonym probe_types for rhn_probe_types;

--
--$Log$
--Revision 1.1  2004/06/23 15:01:07  kja
--bugzilla 126465 -- fix synonyms for monitoring backend
--
--
