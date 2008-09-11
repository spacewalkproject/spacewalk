--
-- $Id$
--

create table
rhnKickstartVirtualizationType
(
	id			number
				constraint rhn_kvt_id_nn not null
				constraint rhn_kvt_id_pk primary key
					using index tablespace [[8m_tbs]],
	name			varchar2(128)
				constraint rhn_kvt_name_nn not null,
	label			varchar2(128)
				constraint rhn_kvt_label_nn not null
				constraint rhn_kvt_label_unq unique,
	created			date default (sysdate)
				constraint rhn_kvt_created_nn not null,
	modified		date default (sysdate)
				constraint rhn_kvt_modified_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create sequence rhn_kvt_id_seq;



-- $Log$
