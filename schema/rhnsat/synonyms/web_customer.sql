--
-- $Id$
--
-- EXCLUDE: all
-- EXCLUDE: all
--
-- synonym fro web_customer in production

create synonym web_customer for web.web_customer;

-- $Log$
-- Revision 1.2  2003/11/05 16:43:20  pjones
-- bugzilla: 106071 -- these synonyms aren't useful any more.  For now, just
-- exclude them, but probably kill them later.
--
-- Revision 1.1  2002/05/10 15:36:46  pjones
-- synonyms are now handles like everything else.
--
