--
--$Id$
--
--

--reference table
--command_class current prod row count = 183
create table 
rhn_command_class
(
    class_name  varchar2 (40)
        constraint rhn_comcl_class_name_nn not null
        constraint rhn_comcl_class_name_pk primary key
            using index tablespace [[2m_tbs]]
)
    storage ( freelists 16 )
    initrans 32;

COMMENT ON TABLE rhn_command_class IS 'COMCL Command classes';

--$Log$
--Revision 1.6  2004/05/04 14:00:23  kja
--Corrected syntactical error discovered during testing.
--
--Revision 1.5  2004/04/22 20:27:40  kja
--More reference table data.
--
--Revision 1.4  2004/04/16 21:49:57  kja
--Adjusted small table sizes.  Documented small tables that are primarily static
--as "reference tables."  Fixed up a few syntactical errs.
--
--Revision 1.3  2004/04/12 22:41:48  kja
--More monitoring schema.  Tweaked some sizes/syntax on previously added scripts.
--
--Revision 1.2  2004/04/12 18:39:20  kja
--Added current production row count for each table as a comment to aid in
--sizing requirements.
--
--Revision 1.1  2004/04/08 22:52:31  kja
--Converting monitoring schema to rhn style -- a work in progress.
