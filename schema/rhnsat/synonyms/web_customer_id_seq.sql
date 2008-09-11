--
-- $Id$
--
-- EXCLUDE: all
--
-- synonym for web.web_customer_id_seq in production

create synonym web_customer_id_seq for web.web_customer_id_seq;

-- $Log$
-- Revision 1.2  2003/11/05 16:43:20  pjones
-- bugzilla: 106071 -- these synonyms aren't useful any more.  For now, just
-- exclude them, but probably kill them later.
--
-- Revision 1.1  2002/05/10 15:36:46  pjones
-- synonyms are now handles like everything else.
--
