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

--NOTE: Had to shorten table name
--command_parameter_threshold current prod row count = 772
create table 
rhn_command_param_threshold
(
    command_id              numeric   (12) not null,
    param_name              varchar (40) not null,
    param_type              varchar (10)  not null constraint rhn_coptr_param_type_ck check (param_type='threshold'),
    threshold_type_name     varchar (10) not null,
    threshold_metric_id     varchar (40) not null,
    last_update_user        varchar (40),
    last_update_date        timestamp,
    command_class           varchar (255) not null,
    constraint rhn_coptr_id_p_name_p_type_pk primary key ( command_id, param_name, param_type ),
    constraint rhn_coptr_cmd_id_cmd_cl_fk foreign key ( command_id, command_class ) references rhn_command( recid, command_class ) on delete cascade,
    constraint rhn_coptr_m_thr_m_cmd_cl_fk foreign key ( command_class, threshold_metric_id )
    references rhn_metrics( command_class, metric_id ) on delete cascade,
    constraint rhn_coptr_thrtp_thres_type_fk foreign key ( threshold_type_name ) references rhn_threshold_type( name )
    
)
--    enable row movement
  ;

comment on table rhn_command_param_threshold 
    is 'coptr  a parameter for a particular command';

create unique index rhn_coptr_id_p_name_p_type_pk 
    on rhn_command_param_threshold ( command_id, param_name, param_type )
--    tablespace [[2m_tbs]]
  ;
