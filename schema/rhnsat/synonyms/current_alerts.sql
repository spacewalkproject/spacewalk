--
--$Id$
--

--create special current_alerts synonyms for monitoring backend code to function as is

create or replace synonym current_alerts for rhn_current_alerts;
create or replace synonym current_alerts_recid_seq for rhn_current_alerts_recid_seq;

--
--$Log$
--Revision 1.1  2004/06/23 15:01:07  kja
--bugzilla 126465 -- fix synonyms for monitoring backend
--
--
