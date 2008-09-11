--
--$Id$
--

--create special semantic_data_type synonyms for monitoring backend code to function as is

create or replace synonym semantic_data_type for rhn_semantic_data_type;

--
--$Log$
--Revision 1.1  2004/06/23 15:01:07  kja
--bugzilla 126465 -- fix synonyms for monitoring backend
--
--
