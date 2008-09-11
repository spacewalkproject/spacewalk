--
--$Id$
--

--create special notification_formats synonyms for monitoring backend code to function as is

create or replace synonym notification_formats for rhn_notification_formats;
create or replace synonym ntfmt_recid_seq for rhn_ntfmt_recid_seq;

--
--$Log$
--Revision 1.1  2004/06/23 15:01:07  kja
--bugzilla 126465 -- fix synonyms for monitoring backend
--
--
