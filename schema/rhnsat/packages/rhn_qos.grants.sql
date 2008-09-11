--
-- $Id$
-- EXCLUDE: all
--
-- grants for rhn_qos

grant execute on rhn_qos to rhn_dml_r;

-- $Log$
-- Revision 1.2  2004/04/14 00:09:24  pjones
-- bugzilla: 120761 -- split rhnChannelPermissions into two tables, eliminating
-- a frequent full table scan
--
-- Revision 1.1  2002/10/02 18:45:46  pjones
-- grants for rhn_qos
--
