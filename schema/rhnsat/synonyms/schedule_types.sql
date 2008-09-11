--
--$Id$
--

--create special schedule_types synonyms for monitoring backend code to function as is

create or replace synonym schedule_types for rhn_schedule_types;
create or replace synonym schedule_types_recid_seq for rhn_schedule_types_recid_seq;

--
--$Log$
--Revision 1.1  2004/06/23 15:01:07  kja
--bugzilla 126465 -- fix synonyms for monitoring backend
--
--
