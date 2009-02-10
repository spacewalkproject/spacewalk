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
    instance_id         numeric   (12) not null,
    netsaint_id         numeric   (12) not null,
    date_accepted       timestamp,
    date_executed       timestamp,	
    exit_status         numeric   (5),
    execution_time      numeric   (10,6),
    stdout              varchar (4000),
    stderr              varchar (4000),
    last_update_date    timestamp,
    target_type         varchar (10) not null,
    constraint rhn_cqexe_inst_id_nsaint_pk primary key ( instance_id, netsaint_id ),
    constraint rhn_cqexe_cqins_inst_id_fk foreign key ( instance_id ) references rhn_command_queue_instances( recid )
    on delete cascade,
    constraint rhn_cqexe_satcl_nsaint_id_fk foreign key ( netsaint_id, target_type ) references rhn_command_target( recid, target_type ) on delete cascade   
)
--    enable row movement
  ;

comment on table rhn_command_queue_execs 
    is 'cqexe  command queue execution records';

create unique index rhn_cqexe_inst_id_nsaint_pk 
    on rhn_command_queue_execs ( instance_id, netsaint_id );

create index rhn_command_queue_netsaint_idx 
    on rhn_command_queue_execs ( netsaint_id )
--    tablespace [[8m_tbs]]
  ;

create index rhn_cqexe_instance_id_idx 
    on rhn_command_queue_execs ( instance_id )
--    tablespace [[8m_tbs]]
  ;

create index rhn_cqexe_date_executed_idx 
    on rhn_command_queue_execs ( date_executed )
--    tablespace [[8m_tbs]]
  ;

