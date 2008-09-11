--
-- $Id$
--

INSERT INTO db_change_resource_changes( change_type )
	VALUES ('CREATED');
INSERT INTO db_change_resource_changes( change_type )
	VALUES ('DROPPED');
INSERT INTO db_change_resource_changes( change_type )
	VALUES ('ALTERED');
commit;

--
-- $Log$
-- Revision 1.1  2004/05/24 21:49:37  pjones
-- bugzilla: none -- db change schema scripts
--
