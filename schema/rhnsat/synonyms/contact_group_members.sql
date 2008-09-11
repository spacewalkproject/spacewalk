--
--$Id$
--

--create special contact_group_members synonyms for monitoring backend code to function as is

create or replace synonym contact_group_members for rhn_contact_group_members;

--
--$Log$
--Revision 1.1  2004/06/23 15:01:07  kja
--bugzilla 126465 -- fix synonyms for monitoring backend
--
--
