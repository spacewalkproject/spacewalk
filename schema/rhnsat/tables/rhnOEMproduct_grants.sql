--
-- $Id$
-- 
-- EXCLUDE: all
--
-- grants for rhnOEMproduct in production

grant select,insert,update,delete on rhnOEMproduct to rhn_dml_r;

-- $Log$
-- Revision 1.2  2002/06/14 15:15:23  pjones
-- exclude all
--
-- Revision 1.1  2002/05/10 21:54:45  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
--
