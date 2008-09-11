--
--$Id$
--

--create special  synonyms for monitoring backend code to function as is

create or replace synonym command_target for rhn_command_target;
create or replace synonym command_target_recid_seq for rhn_command_target_recid_seq;

--
--$Log$
--Revision 1.1  2004/06/23 15:01:07  kja
--bugzilla 126465 -- fix synonyms for monitoring backend
--
--
