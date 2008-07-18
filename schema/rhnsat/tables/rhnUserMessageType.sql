--
-- $Id$
-- Defines types of user messages... warnings, alerts, etc...

create table
rhnUserMessageType
(
	id		number
			constraint rhn_um_type_id_nn not null
			constraint rhn_um_type_pk primary key
				using index tablespace [[64k_tbs]],
	label		varchar2(48)
			constraint rhn_um_type_label_nn not null,
	name		varchar2(96)
			constraint rhn_um_type_name_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create unique index rhn_um_type_label_uq
	on rhnUserMessageType(label)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;
create unique index rhn_um_type_name_uq
	on rhnUserMessageType(name)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

-- $Log$
-- Revision 1.3  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.2  2002/07/24 21:23:35  pjones
-- reformat
-- remove unneeded stuff.
--
-- Revision 1.1  2002/07/24 21:05:08  bretm
-- o  initial checkin
--
