--
--$Id$
--
--

--reference table
--environment current prod row count = 6
create table 
rhn_environment
(
    name            varchar2 (255)
        constraint rhn_envir_name_nn not null
        constraint rhn_envir_name_pk primary key
            using index tablespace [[64k_tbs]]
            storage( pctincrease 1 freelists 16 )
            initrans 32,
    description     varchar2 (255)
)
    storage ( pctincrease 1 freelists 16 )
    initrans 32;

comment on table rhn_environment 
    is 'envir environments:dev,qa,stage,prod,license';

--$Log$
--Revision 1.2  2004/04/16 21:49:57  kja
--Adjusted small table sizes.  Documented small tables that are primarily static
--as "reference tables."  Fixed up a few syntactical errs.
--
--Revision 1.1  2004/04/13 16:40:33  kja
--Tweaked a bit of syntax on modified files.  Added more script files for
--monitoring schema.
--
