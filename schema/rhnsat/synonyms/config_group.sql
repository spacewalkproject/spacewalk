--
--$Id$
--

--create special config_group synonyms for monitoring backend code to function as is

create or replace synonym config_group for rhn_config_group;

--
--$Log$
--Revision 1.1  2004/06/23 15:01:07  kja
--bugzilla 126465 -- fix synonyms for monitoring backend
--
--
