--
--$Id$
--
--

--reference table
--widget current prod row count = 3
create table 
rhn_widget
( 
    name                varchar2 (20)
        constraint rhn_wdget_name_nn not null
        constraint rhn_wdget_name_pk primary key
            using index tablespace [[64k_tbs]]
            storage( pctincrease 1 freelists 16 )
            initrans 32,
    description         varchar2 (80)
        constraint rhn_wdget_desc_nn not null,
    last_update_user    varchar2 (40),
    last_update_date    date         
) 
    storage ( freelists 16 )
    initrans 32;

comment on table rhn_widget 
    is 'wdget  text,password,menu,radio,checkbox';

--$Log$
--Revision 1.1  2004/04/16 21:17:21  kja
--More monitoring tables.
--
