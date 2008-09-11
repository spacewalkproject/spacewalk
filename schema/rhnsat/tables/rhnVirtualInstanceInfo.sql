--
-- $Id$
--


create table
rhnVirtualInstanceInfo
(
	name                    varchar(128),
	instance_id		number
				constraint rhn_vii_viid_nn not null
				constraint rhn_vii_viid_fk
					references rhnVirtualInstance(id)
					on delete cascade,
	instance_type		number
				constraint rhn_vii_it_nn not null
				constraint rhn_vii_it_fk
					references rhnVirtualInstanceType(id),
	memory_size_k		number,
	vcpus			number,
	state			number
				constraint rhn_vii_state_nn not null
				constraint rhn_vii_state_fk
					   references rhnVirtualInstanceState(id),
	created			date default (sysdate)
				constraint rhn_vii_created_nn not null,
	modified		date default (sysdate)
				constraint rhn_vii_modified_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create sequence rhn_vii_id_seq;

create unique index rhn_vii_viid_uq
	on rhnVirtualInstanceInfo(instance_id)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;
	

-- $Log$
