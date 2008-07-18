--
--$Id$
--
--

--reference table
--semantic_data_type current prod row count = 7
create table 
rhn_semantic_data_type
(
    name                varchar2 (10)
        constraint rhn_sdtyp_name_nn not null
        constraint rhn_sdtyp_name_pk primary key
            using index tablespace [[64k_tbs]]
            storage( pctincrease 1 freelists 16 )
            initrans 32,
    description         varchar2 (80)
        constraint rhn_sdtyp_desc_nn not null,
    label_name          varchar2 (80),
    converter_name      varchar2 (128),
    help_file           varchar2 (128),
    last_update_user    varchar2 (40),
    last_update_date    date
)
    storage ( freelists 16 )
    enable row movement
    initrans 32;

comment on table rhn_semantic_data_type 
    is 'sdtyp  data type int, float, string, ipaddress, hostname';

--$Log$
--Revision 1.2  2004/04/16 21:49:57  kja
--Adjusted small table sizes.  Documented small tables that are primarily static
--as "reference tables."  Fixed up a few syntactical errs.
--
--Revision 1.1  2004/04/16 19:51:57  kja
--More monitoring schema.
--
