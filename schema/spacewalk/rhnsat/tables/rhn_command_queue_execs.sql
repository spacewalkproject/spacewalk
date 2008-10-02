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

--command_queue_execs current prod row count = 41190
create table 
rhn_command_queue_execs
(
    instance_id         number   (12)
        constraint rhn_cqexe_instance_id_nn not null,
    netsaint_id         number   (12)
        constraint rhn_cqexe_netsaint_id_nn not null,
    date_accepted       date,
    date_executed       date,	
    exit_status         number   (5),
    execution_time      number   (10,6),
    stdout              varchar2 (4000),
    stderr              varchar2 (4000),
    last_update_date    date,
    target_type         varchar2 (10)
        constraint rhn_cqexe_target_type_nn not null
)
    storage ( pctincrease 1 freelists 16 )
    enable row movement
    initrans 32;

comment on table rhn_command_queue_execs 
    is 'cqexe  command queue execution records';

create unique index rhn_cqexe_inst_id_nsaint_pk 
    on rhn_command_queue_execs ( instance_id, netsaint_id );

create index rhn_command_queue_netsaint_idx 
    on rhn_command_queue_execs ( netsaint_id )
    tablespace [[8m_tbs]]
    storage( pctincrease 1 freelists 16 )
    initrans 32;

create index rhn_cqexe_instance_id_idx 
    on rhn_command_queue_execs ( instance_id )
    tablespace [[8m_tbs]]
    storage( pctincrease 1 freelists 16 )
    initrans 32;

create index rhn_cqexe_date_executed_idx 
    on rhn_command_queue_execs ( date_executed )
    tablespace [[8m_tbs]]
    storage( pctincrease 1 freelists 16 )
    initrans 32;

alter table rhn_command_queue_execs 
    add constraint rhn_cqexe_inst_id_nsaint_pk 
    primary key ( instance_id, netsaint_id );

alter table rhn_command_queue_execs
    add constraint rhn_cqexe_cqins_inst_id_fk
    foreign key ( instance_id )
    references rhn_command_queue_instances( recid )
    on delete cascade;

alter table rhn_command_queue_execs
    add constraint rhn_cqexe_satcl_nsaint_id_fk
    foreign key ( netsaint_id, target_type )
    references rhn_command_target( recid, target_type )
    on delete cascade;

--
--Revision 1.5  2004/10/11 22:58:01  nhansen
--bug 135270 adding date_accepted column to the command_queue_execs table
--
--Revision 1.4  2004/05/04 23:02:54  kja
--Fix syntax errors.  Trim constraint/table/sequence names to legal lengths.
--
--Revision 1.3  2004/04/28 23:10:52  kja
--Moving foreign keys where applicable and no circular dependencies exist.
--
--Revision 1.2  2004/04/19 17:21:23  kja
--Tweaks from auditing not null constraints, storage on tables, and non-unique
--indexes.
--
--Revision 1.1  2004/04/12 22:41:48  kja
--More monitoring schema.  Tweaked some sizes/syntax on previously added scripts.
--
--
--
--
--
