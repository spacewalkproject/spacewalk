--
-- $Id$
--
-- Our idea of an RPM transaction element's operation

create table
rhnTransactionOperation
(
	id		number
			constraint rhn_transop_id_nn not null
			constraint rhn_transop_id_pk primary key
				using index tablespace [[8m_tbs]],
	label		varchar2(32)
			constraint rhn_transop_label_nn not null
			constraint rhn_transop_label_uq unique
				using index tablespace [[8m_tbs]],
	created		date default(sysdate)
			constraint rhn_transop_created_nn not null,
	modified	date default(sysdate)
			constraint rhn_transop_modified_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create index rhn_transop_label_id_idx
	on rhnTransactionOperation(label,id)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

-- $Log$
-- Revision 1.2  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.1  2002/09/25 19:09:02  pjones
-- transaction changes discussed today
--
