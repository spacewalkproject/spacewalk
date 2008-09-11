--
-- $Id$
--

insert into rhnConfigFileState(id, label, name) values
	(rhn_cfstate_id_seq.nextval, 'dead', 'Will not be deployed');

insert into rhnConfigFileState(id, label, name) values
	(rhn_cfstate_id_seq.nextval, 'alive', 'Will be deployed');

commit;

--
-- $Log$
-- Revision 1.1  2003/11/09 21:51:47  pjones
-- bugzilla: 109083 -- add data for rhnConfigFileState
--
