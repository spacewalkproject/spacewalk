--
--$Id$
--

--create special pager_types synonyms for monitoring backend code to function as is

create or replace synonym pager_types for rhn_pager_types;
create or replace synonym pager_types_recid_seq for rhn_pager_types_recid_seq;

--
--$Log$
--Revision 1.1  2004/06/23 15:01:07  kja
--bugzilla 126465 -- fix synonyms for monitoring backend
--
--
