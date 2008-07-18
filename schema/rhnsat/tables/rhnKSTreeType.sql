create table
rhnKSTreeType
(
        id              number
			constraint rhn_kstreetype_id_nn not null
                        constraint rhn_kstreetype_id_pk primary key
                                using index tablespace [[64k_tbs]],
        label           varchar2(32)
                        constraint rhn_kstreetype_label_nn not null,
        name            varchar2(64)
                        constraint rhn_kstreetype_name_nn not null,
        created         date default(sysdate)
                        constraint rhn_kstreetype_created_nn not null,
        modified        date default(sysdate)
                        constraint rhn_kstreetype_mod_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create sequence rhn_kstree_type_seq;

create unique index rhn_kstreetype_label_uq 
	on rhnKSTreeType(label)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;
