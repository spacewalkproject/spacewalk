--
--$Id$
--

--create special redirect_email_targets synonyms for monitoring backend code to function as is

create or replace synonym redirect_email_targets for rhn_redirect_email_targets;

--
--$Log$
--Revision 1.1  2004/06/23 15:01:07  kja
--bugzilla 126465 -- fix synonyms for monitoring backend
--
--
