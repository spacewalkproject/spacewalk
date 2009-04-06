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
    metric_id           varchar (40) not null,
    storage_unit_id     varchar (10) not null
			constraint rhn_metrc_uts_stor_ut_id_fk
        		references rhn_units( unit_id ),
    description         varchar (200),
    last_update_user    varchar (40),
    last_update_date    date,
    label               varchar (40),
    command_class       varchar (255) default 'nothing' not null
			constraint rhn_metrc_comcl_cmd_class_fk
    			references rhn_command_class( class_name ),
			constraint rhn_metrc_cmd_cl_metric_id_pk primary key ( command_class, metric_id )
)
  ;

comment on table rhn_metrics 
    is 'metrc  metric definitions';

create index rhn_metrc_storage_unit_id_idx 
    on rhn_metrics ( storage_unit_id )
--    tablespace [[2m_tbs]]
  ;


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
