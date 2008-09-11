--
--$Id$
--

--create special os_commands_xref synonyms for monitoring backend code to function as is

create or replace synonym os_commands_xref for rhn_os_commands_xref;

--
--$Log$
--Revision 1.1  2004/06/23 15:01:07  kja
--bugzilla 126465 -- fix synonyms for monitoring backend
--
--
