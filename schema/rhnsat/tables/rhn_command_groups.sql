--
--$Id$
--
--

--reference table
--command_groups current prod row count = 24
create table 
rhn_command_groups
(
    group_name  varchar2 (10)
        constraint rhn_cmdgr_group_name_nn not null
        constraint rhn_cmdgr_group_name_pk primary key
                using index tablespace [[64k_tbs]],
    description varchar2 (80)
)
    storage ( freelists 16 )
    enable row movement
    initrans 32;

comment on table rhn_command_groups 
    is 'CMDGR  Command group definitions';

--$Log$
--Revision 1.4  2004/04/22 20:27:40  kja
--More reference table data.
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
