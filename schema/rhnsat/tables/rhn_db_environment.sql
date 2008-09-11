--
--$Id$
--
--

--reference table
--db_environment current prod row count = 5
create table 
rhn_db_environment
(
    db_name     varchar2 (20)
        constraint rhn_dbenv_db_name_nn not null
        constraint rhn_dbenv_db_name_pk primary key
            using index tablespace [[64k_tbs]]
            storage( pctincrease 1 freelists 16 )
            initrans 32,
    environment varchar2 (255)
)
    storage ( freelists 16 )
    initrans 32;

comment on table rhn_db_environment 
    is 'dbenv environments - database_names xref';

alter table rhn_db_environment
    add constraint rhn_dbenv_envir_environment_fk
    foreign key ( environment )
    references rhn_environment( name );

--$Log$
--Revision 1.4  2004/04/30 14:36:50  kja
--Moving foreign keys for non-circular dependencies.
--
--Revision 1.3  2004/04/16 21:49:57  kja
--Adjusted small table sizes.  Documented small tables that are primarily static
--as "reference tables."  Fixed up a few syntactical errs.
--
--Revision 1.2  2004/04/13 19:36:13  kja
--More monitoring schema.
--
--Revision 1.1  2004/04/13 16:40:33  kja
--Tweaked a bit of syntax on modified files.  Added more script files for
--monitoring schema.
--
--
--$Id$
--
--
