--
--$Id$
--

--create special redirect_criteria synonyms for monitoring backend code to function as is

create or replace synonym redirect_criteria for rhn_redirect_criteria;
create or replace synonym redirect_criteria_recid_seq for rhn_redirect_crit_recid_seq;

--
--$Log$
--Revision 1.1  2004/06/23 15:01:07  kja
--bugzilla 126465 -- fix synonyms for monitoring backend
--
--
