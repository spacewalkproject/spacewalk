--
--$Id$
--
--

--reference table
--redirect_match_types current prod row count = 10
create table 
rhn_redirect_match_types
(
    name                             varchar2 (255)
        constraint rhn_rdrmt_name_nn not null
        constraint rhn_rdrmt_name_pk primary key
            using index tablespace [[64k_tbs]]
            storage( pctincrease 1 freelists 16 )
            initrans 32
)
    storage ( freelists 16 )
    initrans 32;

comment on table rhn_redirect_match_types 
    is 'rdrmt  redirect match types';

--$Log$
--Revision 1.3  2004/05/06 17:35:10  kja
--More syntax/identifier length changes.
--
--Revision 1.2  2004/04/16 21:49:57  kja
--Adjusted small table sizes.  Documented small tables that are primarily static
--as "reference tables."  Fixed up a few syntactical errs.
--
--Revision 1.1  2004/04/16 02:21:57  kja
--More monitoring schema.
--
