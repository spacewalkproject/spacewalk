--
--$Id$
--

--create special customer synonyms for monitoring backend code to function as is

create or replace synonym customer for rhn_customer_monitoring;

--$Log$
--Revision 1.1  2004/07/16 15:35:00  kja
--Bug 126465 -- fix synonyms for monitoring views.
--
