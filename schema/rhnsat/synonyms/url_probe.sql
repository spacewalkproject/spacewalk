--
--$Id$
--

--create special url_probe synonyms for monitoring backend code to function as is

create or replace synonym url_probe for rhn_url_probe;

--
--$Log$
--Revision 1.1  2004/06/23 15:01:07  kja
--bugzilla 126465 -- fix synonyms for monitoring backend
--
--
