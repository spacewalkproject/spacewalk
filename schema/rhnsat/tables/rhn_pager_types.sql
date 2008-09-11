--
--$Id$
--
--

--pager_types current prod row count = 582
create table 
rhn_pager_types
(
    recid           number   (12)
        constraint rhn_pgrtp_recid_nn not null
        constraint rhn_pgrtp_recid_ck check (recid > 0)
        constraint rhn_pgrtp_recid_pk primary key
            using index tablespace [[2m_tbs]]
            storage( pctincrease 1 freelists 16 )
            initrans 32,
    pager_type_name varchar2 (50)
)
    storage ( freelists 16 )
    initrans 32;

comment on table rhn_pager_types 
    is 'pgrtp  pager types';

create sequence rhn_pager_types_recid_seq;

--$Log$
--Revision 1.2  2004/04/13 20:45:55  kja
--Tweak constraint names to start with rhn_.
--
--Revision 1.1  2004/04/13 19:36:13  kja
--More monitoring schema.
--
