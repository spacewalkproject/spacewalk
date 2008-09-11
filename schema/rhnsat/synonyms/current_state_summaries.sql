--
--$Id$
--

--create special current_state_summaries synonyms for monitoring backend code to function as is

create or replace synonym current_state_summaries for rhn_current_state_summaries;

--
--$Log$
--Revision 1.1  2004/06/23 15:01:07  kja
--bugzilla 126465 -- fix synonyms for monitoring backend
--
--
