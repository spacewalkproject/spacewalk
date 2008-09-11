--
-- $Id: $ 
--

create table
rhnFeature
(
        id              number
                        constraint rhn_feature_id primary key
                                using index tablespace [[64k_tbs]],
        label           varchar2(32)
                        constraint rhn_feature_label_nn not null,
        name            varchar2(64)
                        constraint rhn_feature_name_nn not null,
        created         date default(sysdate)
                        constraint rhn_feature_created_nn not null,
        modified        date default(sysdate)
                        constraint rhn_feature_modified_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create sequence rhn_feature_seq;

create unique index rhn_feature_label_uq_idx 
	on rhnFeature(label)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

