--
-- $Id$
-- EXCLUDE: all
--

grant select on rhnUserAvailableChannels to rhn_dml_r;

--
-- $Log$
-- Revision 1.1  2004/04/14 00:09:24  pjones
-- bugzilla: 120761 -- split rhnChannelPermissions into two tables, eliminating
-- a frequent full table scan
--
