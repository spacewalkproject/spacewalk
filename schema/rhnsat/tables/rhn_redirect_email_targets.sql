--
--$Id$
--
--

--redirect_email_targets current prod row count = 142
create table 
rhn_redirect_email_targets
(
    redirect_id     number   (12)
        constraint rhn_rdret_redirect_id_nn not null,
    email_address   varchar2 (255)
        constraint rhn_rdret_email_addr_nn not null
)
    storage ( freelists 16 )
    enable row movement
    initrans 32;

comment on table rhn_redirect_email_targets 
    is 'rdret  redirect email targets';

create unique index rhn_rdret_pk 
    on rhn_redirect_email_targets ( redirect_id, email_address )
    tablespace [[2m_tbs]]
    storage ( freelists 16 )
    initrans 32;

create index rhn_rdret_redirect_id_idx 
    on rhn_redirect_email_targets ( redirect_id )
    tablespace [[2m_tbs]]
    storage ( freelists 16 )
    initrans 32;

alter table rhn_redirect_email_targets 
    add constraint rhn_rdret_pk primary key ( redirect_id, email_address );

alter table rhn_redirect_email_targets
    add constraint rhn_rdret_rdrct_redirect_id_fk
    foreign key ( redirect_id )
    references rhn_redirects( recid )
    on delete cascade;

--$Log$
--Revision 1.3  2004/05/06 17:35:10  kja
--More syntax/identifier length changes.
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
