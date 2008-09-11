--
--$Id$
--

--create special host_check_suites synonyms for monitoring backend code to function as is

create or replace synonym host_check_suites for rhn_host_check_suites;

--
--$Log$
--Revision 1.1  2004/06/23 15:01:07  kja
--bugzilla 126465 -- fix synonyms for monitoring backend
--
--
