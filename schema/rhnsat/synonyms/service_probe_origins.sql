--
--$Id$
--

--create special service_probe_origins synonyms for monitoring backend code to function as is

create or replace synonym service_probe_origins for rhn_service_probe_origins;

--
--$Log$
--Revision 1.1  2004/06/23 15:01:07  kja
--bugzilla 126465 -- fix synonyms for monitoring backend
--
--
