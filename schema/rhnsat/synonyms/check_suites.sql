--
--$Id$
--

--create special check_suites synonyms for monitoring backend code to function as is

create or replace synonym check_suites for rhn_check_suites;
create or replace synonym check_suites_recid_seq for rhn_check_suites_recid_seq;

--
--$Log$
--Revision 1.1  2004/06/23 15:01:07  kja
--bugzilla 126465 -- fix synonyms for monitoring backend
--
--
