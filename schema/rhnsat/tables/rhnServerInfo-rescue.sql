--
-- $Id$
--
-- EXCLUDE: all

-- this rebuilds rhnServerInfo in case of disaster

INSERT INTO rhnServerInfo NOLOGGING
SELECT id, sysdate - 365, 0
  FROM rhnServer;

-- $Log$
-- Revision 1.4  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
-- Revision 1.3  2002/05/09 20:52:41  pjones
-- these don't need get imported currently.
-- eventually, ResponsysUsers* should.
--
-- Revision 1.2  2002/05/09 04:40:42  gafton
-- not needed on the satellite
--
