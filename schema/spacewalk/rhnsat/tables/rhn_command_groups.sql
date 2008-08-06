--
-- Copyright (c) 2008 Red Hat, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
-- 
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation. 
--
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
