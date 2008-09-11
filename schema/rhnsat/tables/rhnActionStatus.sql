--
-- $Id$
--

create table
rhnActionStatus
(
	id		number
			constraint rhn_action_status_id_nn not null
			constraint rhn_action_status_pk primary key
				using index tablespace [[64k_tbs]],
	name		varchar(16),
	created		date default (sysdate)
			constraint rhn_action_status_created_nn not null,
	modified	date default (sysdate)
			constraint rhn_action_status_modified_nn not null
)
	storage ( freelists 16 )
	initrans 32;

-- $Log$
-- Revision 1.14  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.13  2002/05/09 20:41:20  pjones
-- seperate out triggers
--
-- Revision 1.12  2002/04/26 15:05:09  pjones
-- trim logs that have satconish words in them
--
