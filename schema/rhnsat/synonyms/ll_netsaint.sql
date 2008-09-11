--
--$Id$
--

--create special ll_netsaint synonyms for monitoring backend code to function as is

create or replace synonym ll_netsaint for rhn_ll_netsaint;

--
--$Log$
--Revision 1.1  2004/06/23 15:01:07  kja
--bugzilla 126465 -- fix synonyms for monitoring backend
--
--
