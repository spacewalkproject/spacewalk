--
--$Id$
--

--create special schedules synonyms for monitoring backend code to function as is

create or replace synonym schedules for rhn_schedules;
create or replace synonym schedules_recid_seq for rhn_schedules_recid_seq;

--
--$Log$
--Revision 1.1  2004/06/23 15:01:07  kja
--bugzilla 126465 -- fix synonyms for monitoring backend
--
--
