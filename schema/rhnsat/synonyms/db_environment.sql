--
--$Id$
--

--create special db_environment synonyms for monitoring backend code to function as is

create or replace synonym db_environment for rhn_db_environment;

--
--$Log$
--Revision 1.1  2004/06/23 15:01:07  kja
--bugzilla 126465 -- fix synonyms for monitoring backend
--
--
