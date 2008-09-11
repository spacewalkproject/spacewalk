--
--$Id$
--

--create special contact_methods synonyms for monitoring backend code to function as is

create or replace synonym contact_methods for rhn_contact_methods;
create or replace synonym contact_methods_recid_seq for rhn_contact_methods_recid_seq;

--
--$Log$
--Revision 1.1  2004/06/23 15:01:07  kja
--bugzilla 126465 -- fix synonyms for monitoring backend
--
--
