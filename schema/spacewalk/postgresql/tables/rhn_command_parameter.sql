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
create table rhn_command_parameter
(
    command_id              numeric   (12)  not null
				constraint rhn_cparm_cmd_command_id_fk 
				references rhn_command( recid )   
				on delete cascade,
    param_name              varchar (40) not null,
    param_type              varchar (10) default 'config'  not null,
    data_type_name          varchar (10)  not null
				constraint rhn_cparm_sdtyp_name_fk 
				references rhn_semantic_data_type( name ),
    description             varchar (80) not null,
-- TODO: Should	"mandatory" be a boolean?
    mandatory               char     (1) default '0'  not null,
    default_value           varchar (1024),
    min_value               numeric,
    max_value               numeric,
    field_order             numeric not null,
    field_widget_name       varchar (20) not null
				constraint rhn_cparm_wdgt_fld_wdgt_n_fk 
    				references rhn_widget( name ),
    field_visible_length    numeric,
    field_maximum_length    numeric,
-- TODO: Should "field_visible" be a boolean?
    field_visible           char     (1) default '1' not null,
    default_value_visible   char     (1) default '1' not null,
    last_update_user        varchar (40),
    last_update_date        timestamp,
    constraint rhn_cparm_id_parm_name_pk primary key ( command_id, param_name ),
    constraint rhn_cparm_id_p_name_p_type_uq unique ( command_id, param_name, param_type ),
    constraint rhn_cparm_id_field_orde_uq unique ( command_id, field_order )
    
    
)
;

comment on table rhn_command_parameter 
    is 'CPARM  A parameter for a particular command';

comment on column rhn_command_parameter.field_visible 
    is 'if default is $HOSTADDRESS$, param is marked as default not visible ';


