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

--command_queue_instances current prod row count = 22797
create table 
rhn_command_queue_instances
(
    recid               number   (12)
        constraint rhn_cqins_recid_nn not null
        constraint rhn_cqins_recid_pk primary key
            using index tablespace [[4m_tbs]]
            storage( pctincrease 1 freelists 16 ),
    command_id          number   (12)
        constraint rhn_cqins_command_id_nn not null,
    notes               varchar2 (2000),
    date_submitted      date
        constraint rhn_cqins_date_submitted_nn not null,
    expiration_date     date
        constraint rhn_cqins_expiration_date_nn not null,
    notify_email        varchar2 (50),
    timeout             number   (5),
    last_update_user    varchar2 (40),
    last_update_date    date
)
    storage ( pctincrease 1 freelists 16 )
    enable row movement
    initrans 32;

comment on table rhn_command_queue_instances 
    is 'cqins  command queue instance definitions';

create index rhn_cqins_command_id_idx 
    on rhn_command_queue_instances ( command_id )
    tablespace [[4m_tbs]]
    storage ( pctincrease 1 freelists 16 )
    initrans 32
    logging;

alter table rhn_command_queue_instances
    add constraint rhn_cqins_cqcmd_command_id_fk
    foreign key ( command_id )
    references rhn_command_queue_commands( recid );

create sequence rhn_command_q_inst_recid_seq;

--$Log$
--Revision 1.6  2004/05/12 01:21:45  kja
--Added synonyms for the sequences.  Corrected some sequence names to start with
--rhn_.
--
--Revision 1.5  2004/05/04 23:02:54  kja
--Fix syntax errors.  Trim constraint/table/sequence names to legal lengths.
--
--Revision 1.4  2004/04/28 23:10:52  kja
--Moving foreign keys where applicable and no circular dependencies exist.
--
--Revision 1.3  2004/04/19 15:44:51  kja
--Adjustments from primary key audit.
--
--Revision 1.2  2004/04/16 22:10:00  kja
--Added missing sequences.
--
--Revision 1.1  2004/04/12 22:41:48  kja
--More monitoring schema.  Tweaked some sizes/syntax on previously added scripts.
--
--
--$Id$
--
--
