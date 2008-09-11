--
-- $Id$
--


create table
rhnVirtualInstanceEventType
(
	id			number
				constraint rhn_viet_id_nn not null
				constraint rhn_viet_id_pk primary key
					using index tablespace [[64k_tbs]],
	name			varchar2(128)
				constraint rhn_viet_name_nn not null,
	label			varchar2(128)
				constraint rhn_viet_label_nn not null,
	created			date default (sysdate)
				constraint rhn_viet_created_nn not null,
	modified		date default (sysdate)
				constraint rhn_viet_modified_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create sequence rhn_viet_id_seq;


-- $Log$
