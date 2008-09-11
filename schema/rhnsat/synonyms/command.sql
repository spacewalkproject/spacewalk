--
--$Id$
--

--create special command  synonyms for monitoring backend code to function as is

create or replace synonym command  for rhn_command;
create or replace synonym commands_recid_seq for rhn_commands_recid_seq;

--
--$Log$
--Revision 1.1  2004/06/23 15:01:07  kja
--bugzilla 126465 -- fix synonyms for monitoring backend
--
--
