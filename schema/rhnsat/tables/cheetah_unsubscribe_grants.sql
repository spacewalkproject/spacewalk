--
-- $Id$
-- EXCLUDE: all

grant select,insert,update,delete on cheetah_unsubscribe to rhn_dml_r, web, webuser;

-- $Log$
-- Revision 1.2  2003/11/05 16:40:22  pjones
-- bugzilla: 106071 -- these are of historical interest only, I _think_.
--
-- Revision 1.1  2003/04/15 19:08:51  pjones
-- bugzilla: 88948
--
-- ugly tables to keep track of email addresses for deleted users
-- so that they can be removed from some other database later.
--
