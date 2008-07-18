--
--$Id$
--
--

--reference table
--os current prod row count = 16
create table 
rhn_os
(
    recid       number   (12)
        constraint rhn_os000_recid_nn not null
        constraint rhn_os000_recid_pk primary key
            using index tablespace [[64k_tbs]]
            storage( pctincrease 1 freelists 16 )
            initrans 32,
    os_name     varchar2 (128)
)
    storage ( freelists 16 )
    enable row movement
    initrans 32;

comment on table rhn_os 
    is 'os000  operating systems';

--$Log$
--Revision 1.2  2004/04/16 21:49:57  kja
--Adjusted small table sizes.  Documented small tables that are primarily static
--as "reference tables."  Fixed up a few syntactical errs.
--
--Revision 1.1  2004/04/13 19:36:13  kja
--More monitoring schema.
--
