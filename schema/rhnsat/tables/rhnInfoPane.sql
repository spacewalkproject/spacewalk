--
-- $Id$
--

create table rhnInfoPane (
    id      number 
            constraint rhn_info_pane_id_pk primary key,
    label   varchar2(64)
            constraint rhn_info_pane_labl_nn not null,
    acl     varchar2(4000)
)
    storage ( freelists 16 )
    initrans 32;

create sequence rhn_info_pane_id_seq;

create unique index rhn_info_pane_labl_uq
    on rhnInfoPane (label)
    tablespace [[4m_tbs]]
    storage ( pctincrease 1 freelists 16 )
    initrans 32;
