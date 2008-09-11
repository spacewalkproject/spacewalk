--
--$Id$
--

--create special check_suite_probe synonyms for monitoring backend code to function as is

create or replace synonym check_suite_probe for rhn_check_suite_probe;

--
--$Log$
--Revision 1.1  2004/06/23 15:01:07  kja
--bugzilla 126465 -- fix synonyms for monitoring backend
--
--
