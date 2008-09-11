--
--$Id$
--

--create special contact_groups synonyms for monitoring backend code to function as is

create or replace synonym contact_groups for rhn_contact_groups;
create or replace synonym contact_groups_recid_seq for rhn_contact_groups_recid_seq;

--
--$Log$
--Revision 1.1  2004/06/23 15:01:07  kja
--bugzilla 126465 -- fix synonyms for monitoring backend
--
--
