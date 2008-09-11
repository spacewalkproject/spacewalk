--
-- $Id$
-- 
-- XXX: should be dev (prod only)
-- EXCLUDE: all
--
-- grants for rhnSwabMessage in production

grant select,insert,update,delete on rhnSwabMessage to rhn_dml_r;

-- $Log$
-- Revision 1.1  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
