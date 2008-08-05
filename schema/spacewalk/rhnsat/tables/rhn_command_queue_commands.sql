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

--command_queue_commands current prod row count = 561
create table 
rhn_command_queue_commands
(
    recid               number   (12)
        constraint rhn_cqcmd_recid_nn not null
        constraint rhn_cqcmd_recid_pk primary key
            using index tablespace [[2m_tbs]]
            storage( pctincrease 1 freelists 16 ),
    description         varchar2 (40)
        constraint rhn_cqcmd_description_nn not null,
    notes               varchar2 (2000),
    command_line        varchar2 (2000)
        constraint rhn_cqcmd_command_line_nn not null,
    permanent           char     (1)
        constraint rhn_cqcmd_permanent_nn not null,
    restartable         char     (1)
        constraint rhn_cqcmd_restartable_nn not null,
    effective_user      varchar2 (40)
        constraint rhn_cqcmd_effective_usr_nn not null,
    effective_group     varchar2 (40)
        constraint rhn_cqcmd_effective_grp_nn not null,
    last_update_user    varchar2 (40),
    last_update_date    date
)
    storage ( pctincrease 1 freelists 16 )
    enable row movement
    initrans 32;

comment on table rhn_command_queue_commands 
    is 'cqcmd  command queue command definitions';

create sequence rhn_command_q_comm_recid_seq
    start with 100;

--$Log$
--Revision 1.6  2004/05/12 01:21:45  kja
--Added synonyms for the sequences.  Corrected some sequence names to start with
--rhn_.
--
--Revision 1.5  2004/05/04 23:02:54  kja
--Fix syntax errors.  Trim constraint/table/sequence names to legal lengths.
--
--Revision 1.4  2004/04/23 18:27:47  kja
--More reference table data.
--
--Revision 1.3  2004/04/16 22:10:00  kja
--Added missing sequences.
--
--Revision 1.2  2004/04/16 21:49:57  kja
--Adjusted small table sizes.  Documented small tables that are primarily static
--as "reference tables."  Fixed up a few syntactical errs.
--
--Revision 1.1  2004/04/12 22:41:48  kja
--More monitoring schema.  Tweaked some sizes/syntax on previously added scripts.
--
