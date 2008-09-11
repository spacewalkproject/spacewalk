--
--$Id$
--

--create special redirects synonyms for monitoring backend code to function as is

create or replace synonym redirects for rhn_redirects;
create or replace synonym redirects_recid_seq for rhn_redirects_recid_seq;

--
--$Log$
--Revision 1.1  2004/06/23 15:01:07  kja
--bugzilla 126465 -- fix synonyms for monitoring backend
--
--
