--
--$Id$
--

--create special command_groups synonyms for monitoring backend code to function as is

create or replace synonym command_groups for rhn_command_groups;

--
--$Log$
--Revision 1.1  2004/06/23 15:01:07  kja
--bugzilla 126465 -- fix synonyms for monitoring backend
--
--
