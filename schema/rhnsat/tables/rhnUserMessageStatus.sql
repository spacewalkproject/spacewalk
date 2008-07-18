-- $Id$

-- status for an rhnUserMessage
create table
rhnUserMessageStatus
(
	id		number
			constraint rhn_um_status_id_nn not null
			constraint rhn_um_status_id_pk primary key
				using index tablespace [[64k_tbs]],
	label		varchar2(48)
			constraint rhn_um_status_label_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create sequence rhn_um_status_id_seq;

create unique index rhn_um_status_label_uq
	on rhnUserMessageStatus(label)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

-- last created gets used in Rule, make it the most useful index.
create index rhn_um_status_label_id_idx
	on rhnUserMessageStatus(label,id)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

-- $Log$
-- Revision 1.2  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.1  2002/07/25 19:56:34  pjones
-- message schema, take 2.
--
