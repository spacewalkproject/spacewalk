--
-- $Id$
--


create table
rhnVirtualInstanceState
(
	id			number
				constraint rhn_vis_id_nn not null
				constraint rhn_vis_id_pk primary key
					using index tablespace [[64k_tbs]],
	name			varchar2(128)
				constraint rhn_vis_name_nn not null,
	label			varchar2(128)
				constraint rhn_vis_label_nn not null,
	created			date default (sysdate)
				constraint rhn_vis_created_nn not null,
	modified		date default (sysdate)
				constraint rhn_vis_modified_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create sequence rhn_vis_id_seq;

create unique index rhn_vis_lbl_id_idx on
    rhnVirtualInstanceState(label, id)
    storage ( freelists 16 )
    initrans 32;


-- $Log$
