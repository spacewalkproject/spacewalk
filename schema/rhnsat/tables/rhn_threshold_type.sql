--
--$Id$
--
--

--reference table
--threshold_type current prod row count = 4
create table 
rhn_threshold_type
(
    name                varchar2 (10)
        constraint rhn_trtyp_name_nn not null
        constraint rhn_trtyp_name_pk primary key
            using index tablespace [[64k_tbs]]
            storage( pctincrease 1 freelists 16 )
            initrans 32,
    description         varchar2 (80)
        constraint rhn_trtyp_desc_nn not null,
    ordinal             number   (3)
        constraint rhn_trtyp_ord_nn not null,
    last_update_user    varchar2 (40),
    last_update_date    date
)
    storage ( freelists 16 )
    initrans 32;

comment on table rhn_threshold_type 
    is 'trtyp threshold type:warn_min, warn_max, crit_min, crit_max';

--$Log$
--Revision 1.2  2004/04/16 21:49:57  kja
--Adjusted small table sizes.  Documented small tables that are primarily static
--as "reference tables."  Fixed up a few syntactical errs.
--
--Revision 1.1  2004/04/16 19:51:58  kja
--More monitoring schema.
--
