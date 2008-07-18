--
--$Id$
--
--

--redirect_group_targets current prod row count = 1
create table 
rhn_redirect_group_targets
(
    redirect_id         number   (12)
        constraint rhn_rdrgt_redirect_id_nn not null,
    contact_group_id    number   (12)
        constraint rhn_rdrgt_group_id_nn not null
)
    storage ( freelists 16 )
    enable row movement
    initrans 32;

comment on table rhn_redirect_group_targets 
    is 'rdrgt  redirect group targets';

create unique index rhn_rdrgt_pk 
    on rhn_redirect_group_targets ( redirect_id , contact_group_id )
    tablespace [[2m_tbs]]
    storage ( freelists 16 )
    initrans 32;

create index rhn_rdrgt_redirect_id_idx 
    on rhn_redirect_group_targets ( redirect_id )
    tablespace [[2m_tbs]]
    storage ( freelists 16 )
    initrans 32;

alter table rhn_redirect_group_targets 
    add constraint rhn_rdrgt_pk primary key ( redirect_id, contact_group_id );

--alter table rhn_redirect_group_targets
--    add constraint rhn_rdrgt_cntgp_group_id_fk
--    foreign key ( contact_group_id )
--    references rhn_contact_groups( recid )
--   on delete cascade;

alter table rhn_redirect_group_targets
    add constraint rhn_rdrgt_rdrct_redirect_id_fk
    foreign key ( redirect_id )
    references rhn_redirects( recid )
    on delete cascade;

--$Log$
--Revision 1.3  2004/05/07 23:30:22  kja
--Shortened constraint/other names as needed.  Fixed minor syntax errors.
--
--Revision 1.2  2004/04/30 14:36:51  kja
--Moving foreign keys for non-circular dependencies.
--
--Revision 1.1  2004/04/16 02:21:57  kja
--More monitoring schema.
--
--
--$Id$
--
--
