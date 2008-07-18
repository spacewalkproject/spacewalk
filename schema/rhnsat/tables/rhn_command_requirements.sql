--
--$Id$
--
--

--reference table
--command_requirements current prod row count = 12
create table 
rhn_command_requirements
(
    name        varchar2 (40)
        constraint rhn_creqs_name_nn not null
        constraint rhn_creqs_name_pk primary key
            using index tablespace [[64k_tbs]]
            storage( pctincrease 1 freelists 16 )
            initrans 32,
    description varchar2 (4000)
        constraint rhn_creqs_description_nn not null
)
    storage ( freelists 16 )
    enable row movement
    initrans 32;

comment on table rhn_command_requirements 
    is 'creqs storage for system requirements for commands';

--$Log$
--Revision 1.2  2004/04/16 21:49:57  kja
--Adjusted small table sizes.  Documented small tables that are primarily static
--as "reference tables."  Fixed up a few syntactical errs.
--
--Revision 1.1  2004/04/12 22:41:48  kja
--More monitoring schema.  Tweaked some sizes/syntax on previously added scripts.
--
