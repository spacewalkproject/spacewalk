--
-- $Id$
--
-- This needs to be in a seperate file because the tables
-- have a circular reference.

alter table rhnConfigFile add constraint rhn_conffile_lcrid_fk
	foreign key ( latest_config_revision_id )
	references rhnConfigRevision(id)
	on delete set null;

--
-- $Log$
-- Revision 1.2  2003/11/14 21:16:07  pjones
-- bugzilla: 110094 -- make rhnConfigRevision deletable.  We need to figure out
-- the best way to repopulate this...
--
-- Revision 1.1  2003/11/10 20:26:05  pjones
-- bugzilla: none -- break rhnConfigFile's fk to rhnConfigRevision out into
-- another file, so we can build the circular dep
--
