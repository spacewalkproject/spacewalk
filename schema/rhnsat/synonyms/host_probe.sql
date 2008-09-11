--
--$Id$
--

--create special host_probe synonyms for monitoring backend code to function as is

create or replace synonym host_probe for rhn_host_probe;
create or replace synonym host_probes_recid_seq for rhn_host_probes_recid_seq;

--
--$Log$
--Revision 1.1  2004/06/23 15:01:07  kja
--bugzilla 126465 -- fix synonyms for monitoring backend
--
--
