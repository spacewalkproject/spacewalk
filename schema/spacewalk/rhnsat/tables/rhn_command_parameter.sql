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

--reference table
--command_parameter current prod row count = 1867
create table 
rhn_command_parameter
(
    command_id              number   (12)
        constraint rhn_cparm_command_id_nn  not null,
    param_name              varchar2 (40)
        constraint rhn_cparm_param_name_nn not null,
    param_type              varchar2 (10) default 'config'
        constraint rhn_cparm_param_type_nn  not null,
    data_type_name          varchar2 (10)
        constraint rhn_cparm_data_type_name_nn  not null,
    description             varchar2 (80)
        constraint rhn_cparm_description_nn not null,
    mandatory               char     (1) default '0'
        constraint rhn_cparm_mandatory_nn  not null,
    default_value           varchar2 (1024),
    min_value               number,
    max_value               number,
    field_order             number
        constraint rhn_cparm_field_order_nn not null,
    field_widget_name       varchar2 (20)
        constraint rhn_cparm_field_widget_name_nn not null,
    field_visible_length    number,
    field_maximum_length    number,
    field_visible           char     (1) default '1'
        constraint rhn_cparm_field_visible_nn not null,
    default_value_visible   char     (1) default '1'
        constraint rhn_cparm_def_value_vis_nn not null,
    last_update_user        varchar2 (40),
    last_update_date        date
)
    enable row movement
  ;

comment on table rhn_command_parameter 
    is 'CPARM  A parameter for a particular command';

comment on column rhn_command_parameter.field_visible 
    is 'if default is $HOSTADDRESS$, param is marked as default not visible ';

create unique index rhn_cparm_cmd_id_param_name_uq 
    ON rhn_command_parameter ( command_id, param_name )
    tablespace [[2m_tbs]]
  ;

create unique index rhn_cparm_id_p_name_p_type_uq 
    on rhn_command_parameter ( command_id, param_name, param_type )
    tablespace [[2m_tbs]]
  ;

create unique index rhn_cparm_cmd_id_field_orde_uq 
    on rhn_command_parameter (command_id, field_order)
    tablespace [[2m_tbs]]
  ;

alter table rhn_command_parameter 
    add constraint rhn_cparm_id_parm_name_pk
    primary key ( command_id, param_name );

alter table rhn_command_parameter 
    add constraint rhn_cparm_id_p_name_p_type_uq 
    unique ( command_id, param_name, param_type );

alter table rhn_command_parameter
    add constraint rhn_cparm_id_field_orde_uq
    unique ( command_id, field_order );

alter table rhn_command_parameter
    add constraint rhn_cparm_cmd_command_id_fk
    foreign key ( command_id )
    references rhn_command( recid )
    on delete cascade;

alter table rhn_command_parameter
    add constraint rhn_cparm_sdtyp_name_fk
    foreign key ( data_type_name )
    references rhn_semantic_data_type( name );

alter table rhn_command_parameter
    add constraint rhn_cparm_wdgt_fld_wdgt_n_fk
    foreign key ( field_widget_name )
    references rhn_widget( name );

--
--Revision 1.7  2004/05/06 17:35:10  kja
--More syntax/identifier length changes.
--
--Revision 1.6  2004/05/04 23:02:54  kja
--Fix syntax errors.  Trim constraint/table/sequence names to legal lengths.
--
--Revision 1.5  2004/04/28 23:10:52  kja
--Moving foreign keys where applicable and no circular dependencies exist.
--
--Revision 1.4  2004/04/22 20:27:40  kja
--More reference table data.
--
--Revision 1.3  2004/04/19 17:57:24  kja
--Added index from unique index audit.
--
--Revision 1.2  2004/04/19 15:44:51  kja
--Adjustments from primary key audit.
--
--Revision 1.1  2004/04/12 22:41:48  kja
--More monitoring schema.  Tweaked some sizes/syntax on previously added scripts.
--
--
--
--
--
