--
-- $Id$
--
-- this keeps track of when any of the daemons which run against the db
-- were last executed

create table
rhnDaemonState
(
	label		varchar2(64)
			constraint rhn_daemonstate_label_nn not null
			constraint rhn_daemonstate_label_pk primary key
			using index tablespace [[64k_tbs]],
	last_poll	date
			constraint rhn_daemonstate_lp_nn not null
)
	storage ( freelists 16 )
	initrans 32;

-- $Log$
-- Revision 1.2  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.1  2003/01/13 21:47:31  pjones
-- and spell it sanely
--
