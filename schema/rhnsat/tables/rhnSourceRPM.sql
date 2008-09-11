--
-- $Id$
--

create table
rhnSourceRPM
(
	id		number
			constraint rhn_sourceRPM_id_nn not null
			constraint rhn_sourceRPM_id_pk primary key
			using index tablespace [[64k_tbs]],
	name		varchar2(128)
			constraint rhn_sourcerpm_name_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create unique index rhn_srpm_name_uq
	on rhnSourceRPM(name)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

create sequence rhn_sourcerpm_id_seq;

-- $Log$
-- Revision 1.9  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.8  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
