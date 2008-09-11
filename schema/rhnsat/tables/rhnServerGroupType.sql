--
-- $Id$
--

create table
rhnServerGroupType
(
        id              number
			constraint rhn_servergrouptype_id_nn not null
                        constraint rhn_servergrouptype_id_pk primary key
                                using index tablespace [[64k_tbs]],
        label           varchar2(32)
                        constraint rhn_servergrouptype_label_nn not null,
        name            varchar2(64)
                        constraint rhn_servergrouptype_name_nn not null,
        created         date default(sysdate)
                        constraint rhn_servergrouptype_created_nn not null,
        modified        date default(sysdate)
                        constraint rhn_servergrouptype_mod_nn not null,
        permanent       char default('Y')
                        constraint rhn_servergrouptype_perm_ck 
                           check (permanent in ('Y','N'))
                        constraint rhn_servergrouptype_perm_nn not null,
        is_base         char default('Y')
                        constraint rhn_servergrouptype_isbase_ck
                           check (is_base in ('Y','N'))
                        constraint rhn_servergrouptype_isbase_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create sequence rhn_servergroup_type_seq;

create unique index rhn_servergrouptype_label_uq 
	on rhnServerGroupType(label)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

-- $Log$
-- Revision 1.12  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.11  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
