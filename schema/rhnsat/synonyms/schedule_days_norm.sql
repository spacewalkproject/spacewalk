--
--$Id$
--

--create special schedule_days_norm synonyms for monitoring backend code to function as is

create or replace synonym schedule_days_norm for rhn_schedule_days_norm;

--
--$Log$
--Revision 1.1  2004/06/23 15:01:07  kja
--bugzilla 126465 -- fix synonyms for monitoring backend
--
--
