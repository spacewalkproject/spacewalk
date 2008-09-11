--
--$Id$
--

--create special config_security_type synonyms for monitoring backend code to function as is

create or replace synonym config_security_type for rhn_config_security_type;

--
--$Log$
--Revision 1.1  2004/06/23 15:01:07  kja
--bugzilla 126465 -- fix synonyms for monitoring backend
--
--
