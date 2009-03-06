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
--
--
--

--command_queue_commands current prod row count = 561
create table 
rhn_command_queue_commands
(
    recid               numeric   (12)
        constraint rhn_cqcmd_recid_nn not null
        constraint rhn_cqcmd_recid_pk primary key
--            using index tablespace [[2m_tbs]]
            ,
    description         varchar (40) not null,
    notes               varchar (2000),
    command_line        varchar (2000) not null,
-- TODO: Should "permanent" be a boolean?
    permanent           char     (1) not null,
    restartable         char     (1) not null,
    effective_user      varchar (40) not null,
    effective_group     varchar (40) not null,
    last_update_user    varchar (40),
    last_update_date    timestamp
)
  ;

comment on table rhn_command_queue_commands 
    is 'cqcmd  command queue command definitions';

create sequence rhn_command_q_comm_recid_seq
    start with 100;
