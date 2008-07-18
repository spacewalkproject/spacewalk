--
--$Id$
--
--

--redirect_criteria current prod row count = 27332
create table 
rhn_redirect_criteria
(
    recid           number   (12)
        constraint rhn_rdrcr_recid_nn not null
        constraint rhn_rdrcr_recid_pk primary key
            using index tablespace [[4m_tbs]]
            storage( pctincrease 1 freelists 16 )
            initrans 32,
    redirect_id     number   (12)
        constraint rhn_rdrcr_redirect_id_nn not null,
    match_param     varchar2 (255)
        constraint rhn_rdrcr_match_param_nn not null,
    match_value     varchar2 (255),
    inverted        char     (1) default 0
        constraint rhn_rdrcr_inverted_nn not null
) 
    storage ( freelists 16 )
    enable row movement
    initrans 32;

comment on table rhn_redirect_criteria 
    is 'rdrcr  redirect criteria';

create index rhn_rdrcr_redirect_id_idx 
    on rhn_redirect_criteria ( redirect_id )
    tablespace [[4m_tbs]]
    storage ( freelists 16 )
    initrans 32;

alter table rhn_redirect_criteria
    add constraint rhn_rdrcr_rdrct_redirect_id_fk
    foreign key ( redirect_id )
    references rhn_redirects( recid )
    on delete cascade;

alter table rhn_redirect_criteria
    add constraint rhn_rdrcr_rdrmt_match_nm_fk
    foreign key ( match_param )
    references rhn_redirect_match_types( name );

create sequence rhn_redirect_crit_recid_seq;

--$Log$
--Revision 1.4  2004/05/06 17:35:10  kja
--More syntax/identifier length changes.
--
--Revision 1.3  2004/04/30 14:36:51  kja
--Moving foreign keys for non-circular dependencies.
--
--Revision 1.2  2004/04/19 17:21:23  kja
--Tweaks from auditing not null constraints, storage on tables, and non-unique
--indexes.
--
--Revision 1.1  2004/04/16 02:21:57  kja
--More monitoring schema.
--
--
--$Id$
--
--
