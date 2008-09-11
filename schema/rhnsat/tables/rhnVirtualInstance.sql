--
-- $Id$
--


create table
rhnVirtualInstance
(
	id			number
				constraint rhn_vi_id_nn not null
				constraint rhn_vi_id_pk primary key
					using index tablespace [[64k_tbs]],
	host_system_id		number
				constraint rhn_vi_hsi_fk
					references rhnServer(id),
	virtual_system_id	number
				constraint rhn_vi_vsi_fk
					references rhnServer(id),
	uuid			varchar2(128),
        confirmed               number(1) default 1
                                constraint rhn_vi_c_nn not null,
	created			date default (sysdate)
				constraint rhn_vi_created_nn not null,
	modified		date default (sysdate)
				constraint rhn_vi_modified_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create sequence rhn_vi_id_seq;

create index rhn_vi_hsid_vsid_idx
	on rhnVirtualInstance(host_system_id, virtual_system_id)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

create index rhn_vi_vsid_hsid_idx
	on rhnVirtualInstance(virtual_system_id, host_system_id)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

-- $Log$
