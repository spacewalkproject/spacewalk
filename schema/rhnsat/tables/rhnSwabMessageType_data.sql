--
-- $Id$
--
-- EXCLUDE: all
--
-- data for rhnSwabMessageType

INSERT INTO rhnSwabMessageType VALUES (rhn_swab_message_t_seq.nextval, 'alert', 60.0);
COMMIT;

-- $Log$
-- Revision 1.2  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
-- Revision 1.1  2002/03/08 23:01:05  pjones
-- split imports out into seperate files
--
