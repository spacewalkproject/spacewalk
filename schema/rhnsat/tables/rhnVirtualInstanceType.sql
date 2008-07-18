--
-- $Id$
--

create table
rhnVirtualInstanceType
(
	id			number
				constraint rhn_vit_id_nn not null
				constraint rhn_vit_id_pk primary key
					using index tablespace [[64k_tbs]],
	name			varchar2(128)
				constraint rhn_vit_name_nn not null,
	label			varchar2(128)
				constraint rhn_vit_label_nn not null,
	created			date default (sysdate)
				constraint rhn_vit_created_nn not null,
	modified		date default (sysdate)
				constraint rhn_vit_modified_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create sequence rhn_vit_id_seq;

create unique index rhn_vit_lbl_id_uq on
    rhnVirtualInstanceType(label, id)
    storage ( freelists 16 )
    initrans 32;


-- $Log$
