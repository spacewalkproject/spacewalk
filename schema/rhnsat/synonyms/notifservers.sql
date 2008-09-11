--
--$Id$
--

--create special notifservers synonyms for monitoring backend code to function as is

create or replace synonym notifservers for rhn_notifservers;

--
--$Log$
--Revision 1.1  2004/06/23 15:01:07  kja
--bugzilla 126465 -- fix synonyms for monitoring backend
--
--
