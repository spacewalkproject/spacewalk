--
-- $Id$
--

insert into db_change_resource_types
	select distinct object_type from all_objects;

--
-- $Log$
-- Revision 1.1  2004/05/24 21:49:37  pjones
-- bugzilla: none -- db change schema scripts
--
