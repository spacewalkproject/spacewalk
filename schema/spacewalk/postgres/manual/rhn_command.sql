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

--command current prod row count = 191
create table 
rhn_command 
(
    recid               numeric   (12)   not null
        constraint rhn_cmmnd_recid_pk primary key
--            using index tablespace [[2m_tbs]]
            ,
    name                varchar (40) not null
			 constraint rhn_cmmnd_name_uq unique, 
--    			using index tablespace [[2m_tbs]]
  
    description         varchar (80) not null,
    group_name          varchar (40),       
-- TODO: Should allowed_in_suite be a boolean?
    allowed_in_suite    char     (1) default '1'  not null,
    command_class       varchar (255) default '/var/lib/nocpulse/libexec/plugin' not null,
-- TODO: Should enable be a boolean?
    enabled             char     (1) default '1' not null,
    for_host_probe      char     (1) default '0' not null,
    last_update_user    varchar (40),
    last_update_date    timestamp,
    system_requirements varchar (40),
    version_support     varchar (1024),
    help_url            varchar (1024),
	constraint rhn_cmmnd_name_uq1 unique ( recid, command_class ),
	constraint rhn_cmmnd_cmdgr_group_name_fk foreign key ( group_name ) references rhn_command_groups( group_name ),
	constraint rhn_cmmnd_comcl_class_name_fk foreign key ( command_class )
    references rhn_command_class( class_name ),
constraint rhn_cmmnd_sys_reqs_fk foreign key ( system_requirements ) references rhn_command_requirements( name )    on delete cascade

)

  ;

comment on table rhn_command 
    is 'CMMND A command that probes can run';

comment on column rhn_command.command_class 
    is 'Program to run ';

comment on column rhn_command.enabled 
    is 'Whether command should be usable';

comment on column rhn_command.for_host_probe 
    is 'Whether this is one of the host-alive checks';

create sequence rhn_commands_recid_seq start with 305;

