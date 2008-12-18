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

--metrics current prod row count = 376
create table 
rhn_metrics 
(
    metric_id           varchar2 (40)
        constraint rhn_metric_metric_id_nn not null,
    storage_unit_id     varchar2 (10)
        constraint rhn_metric_storage_id_nn not null,
    description         varchar2 (200),
    last_update_user    varchar2 (40),
    last_update_date    date,
    label               varchar2 (40),
    command_class       varchar2 (255) default 'nothing'
        constraint rhn_metric_cmd_class_nn not null
)
    enable row movement
  ;

comment on table rhn_metrics 
    is 'metrc  metric definitions';

create unique index rhn_metrc_cmd_cl_met_id_pk 
    on rhn_metrics ( command_class, metric_id )
    tablespace [[2m_tbs]]
  ;

create index rhn_metrc_storage_unit_id_idx 
    on rhn_metrics ( storage_unit_id )
    tablespace [[2m_tbs]]
  ;

alter table rhn_metrics 
    add constraint rhn_metrc_cmd_cl_metric_id_pk 
    primary key ( command_class, metric_id );

alter table rhn_metrics
    add constraint rhn_metrc_comcl_cmd_class_fk
    foreign key ( command_class )
    references rhn_command_class( class_name );

alter table rhn_metrics
    add constraint rhn_metrc_uts_stor_ut_id_fk
    foreign key ( storage_unit_id )
    references rhn_units( unit_id );

--
--Revision 1.4  2004/05/04 23:02:54  kja
--Fix syntax errors.  Trim constraint/table/sequence names to legal lengths.
--
--Revision 1.3  2004/04/30 14:36:50  kja
--Moving foreign keys for non-circular dependencies.
--
--Revision 1.2  2004/04/13 20:45:55  kja
--Tweak constraint names to start with rhn_.
--
--Revision 1.1  2004/04/13 19:36:13  kja
--More monitoring schema.
--
--
--
--
--
