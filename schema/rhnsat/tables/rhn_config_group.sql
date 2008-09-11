--
--$Id$
--
--

--reference table
--config_group current prod row count = 27
create table 
rhn_config_group
(
    name        varchar2 (255)
        constraint rhn_confg_name_nn not null
        constraint rhn_confg_name_pk primary key
            using index tablespace [[64k_tbs]]
            storage( pctincrease 1 freelists 16 )
            initrans 32,
    description varchar2 (255)
)
    storage ( freelists 16 )
    initrans 32;

comment on table rhn_config_group 
    is 'confg  configuration group definition:general,mail,cf_db';

--$Log$
--Revision 1.3  2004/04/16 21:49:57  kja
--Adjusted small table sizes.  Documented small tables that are primarily static
--as "reference tables."  Fixed up a few syntactical errs.
--
--Revision 1.2  2004/04/13 16:40:33  kja
--Tweaked a bit of syntax on modified files.  Added more script files for
--monitoring schema.
--
--Revision 1.1  2004/04/12 22:41:48  kja
--More monitoring schema.  Tweaked some sizes/syntax on previously added scripts.
--
