--
--$Id$
--

--create special url_probe_step synonyms for monitoring backend code to function as is

create or replace synonym url_probe_step for rhn_url_probe_step;
create or replace synonym url_probe_step_recid_seq for rhn_url_probe_step_recid_seq;

--
--$Log$
--Revision 1.1  2004/06/23 15:01:07  kja
--bugzilla 126465 -- fix synonyms for monitoring backend
--
--
