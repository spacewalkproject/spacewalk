--
--$Id$
--

--create special strategies synonyms for monitoring backend code to function as is

create or replace synonym strategies for rhn_strategies;
create or replace synonym strategies_recid_seq for rhn_strategies_recid_seq;

--
--$Log$
--Revision 1.1  2004/06/23 15:01:07  kja
--bugzilla 126465 -- fix synonyms for monitoring backend
--
--
