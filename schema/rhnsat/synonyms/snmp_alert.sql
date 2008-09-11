--
--$Id$
--

--create special snmp_alert synonyms for monitoring backend code to function as is

create or replace synonym snmp_alert for rhn_snmp_alert;
create or replace synonym snmp_alert_recid_seq for rhn_snmp_alert_recid_seq;

--
--$Log$
--Revision 1.1  2004/06/23 15:01:07  kja
--bugzilla 126465 -- fix synonyms for monitoring backend
--
--
