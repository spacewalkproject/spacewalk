--
--$Id$
--
--

--reference table
--schedule_types current prod row count = 3
create table 
rhn_schedule_types
(
    recid           number   (12)
        constraint rhn_schtp_recid_nn not null
        constraint rhn_schtp_recid_ck check (recid > 0)
        constraint rhn_schtp_recid_pk primary key
            using index tablespace [[64k_tbs]]
            storage( pctincrease 1 freelists 16 )
            initrans 32,
    description     varchar2 (40)
)
    storage ( freelists 16 )
    initrans 32;

comment on table rhn_schedule_types 
    is 'schtp  schedule types';

create sequence rhn_schedule_types_recid_seq;

--$Log$
--Revision 1.2  2004/04/16 21:49:57  kja
--Adjusted small table sizes.  Documented small tables that are primarily static
--as "reference tables."  Fixed up a few syntactical errs.
--
--Revision 1.1  2004/04/16 19:51:57  kja
--More monitoring schema.
--
