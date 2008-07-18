--
-- $Id$
--

create table
rhnMessageType
(
	id		number
			constraint rhn_m_type_id_nn not null
			constraint rhn_m_type_id_pk primary key
				using index tablespace [[64k_tbs]],
	label		varchar2(48)
			constraint rhn_m_type_label_nn not null,
	name		varchar2(96)
			constraint rhn_m_type_name_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create sequence rhn_mt_id_seq;

create unique index rhn_m_type_label_uq
	on rhnMessageType(label)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;
create unique index rhn_m_type_name_uq
	on rhnMessageType(name)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

create index rhn_m_type_label_id_idx
	on rhnMessageType(label,id)
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
