--
--$Id$
--

--create special schedule_days synonyms for monitoring backend code to function as is

create or replace synonym schedule_days for rhn_schedule_days;
create or replace synonym schedule_days_recid_seq for rhn_schedule_days_recid_seq;

--
--$Log$
--Revision 1.1  2004/06/23 15:01:07  kja
--bugzilla 126465 -- fix synonyms for monitoring backend
--
--
