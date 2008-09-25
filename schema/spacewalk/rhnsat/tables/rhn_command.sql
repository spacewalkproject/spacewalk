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

--command current prod row count = 191
create table 
rhn_command 
(
    recid               number   (12)                   
        constraint rhn_cmmnd_recid_nn not null
        constraint rhn_cmmnd_recid_pk primary key
            using index tablespace [[2m_tbs]]
            storage(pctincrease 1),
    name                varchar2 (40)                   
        constraint rhn_cmmnd_name_nn not null,
    description         varchar2 (80)                   
        constraint rhn_cmmnd_desc_nn not null,
    group_name          varchar2 (40),       
    allowed_in_suite    char     (1) default '1' 
        constraint rhn_cmmnd_allowed_nn not null,
    command_class       varchar2 (255) default '/var/lib/nocpulse/libexec/plugin'
        constraint rhn_cmmnd_class_nn not null,
    enabled             char     (1) default '1' 
        constraint rhn_cmmnd_enabled_nn not null,
    for_host_probe      char     (1) default '0' 
        constraint rhn_cmmnd_host_probe_nn not null,
    last_update_user    varchar2 (40),
    last_update_date    date,
    system_requirements varchar2 (40),
    version_support     varchar2 (1024),
    help_url            varchar2 (1024)
)
    storage( pctincrease 1 freelists 16 )
    enable row movement
    initrans 32;

comment on table rhn_command 
    is 'CMMND A command that probes can run';

comment on column rhn_command.command_class 
    is 'Program to run ';

comment on column rhn_command.enabled 
    is 'Whether command should be usable';

comment on column rhn_command.for_host_probe 
    is 'Whether this is one of the host-alive checks';

create unique index rhn_cmmnd_name_uq
    on rhn_command ( name )
    tablespace [[2m_tbs]]
    storage( pctincrease 1 freelists 16 )
    initrans 32;

create unique index rhn_cmmnd_recid_comm_cl_uq
    on rhn_command ( recid, command_class )
    tablespace [[2m_tbs]]
    storage( pctincrease 1 freelists 16 )
    initrans 32;

alter table rhn_command
    add constraint rhn_cmmnd_name_uq
    unique ( recid, command_class );

alter table rhn_command
    add constraint rhn_cmmnd_cmdgr_group_name_fk
    foreign key ( group_name )
    references rhn_command_groups( group_name );

alter table rhn_command
    add constraint rhn_cmmnd_comcl_class_name_fk
    foreign key ( command_class )
    references rhn_command_class( class_name );

alter table rhn_command
    add constraint rhn_cmmnd_sys_reqs_fk
    foreign key ( system_requirements )
    references rhn_command_requirements( name )
    on delete cascade;

create sequence rhn_commands_recid_seq
    start with 305;

--$Log$
--Revision 1.11  2004/05/12 01:21:45  kja
--Added synonyms for the sequences.  Corrected some sequence names to start with
--rhn_.
--
--Revision 1.10  2004/05/04 23:02:54  kja
--Fix syntax errors.  Trim constraint/table/sequence names to legal lengths.
--
--Revision 1.9  2004/04/28 23:10:52  kja
--Moving foreign keys where applicable and no circular dependencies exist.
--
--Revision 1.8  2004/04/23 18:27:47  kja
--More reference table data.
--
--Revision 1.7  2004/04/19 17:57:24  kja
--Added index from unique index audit.
--
--Revision 1.6  2004/04/16 22:10:00  kja
--Added missing sequences.
--
--Revision 1.5  2004/04/16 21:49:57  kja
--Adjusted small table sizes.  Documented small tables that are primarily static
--as "reference tables."  Fixed up a few syntactical errs.
--
--Revision 1.4  2004/04/13 16:40:33  kja
--Tweaked a bit of syntax on modified files.  Added more script files for
--monitoring schema.
--
--Revision 1.3  2004/04/12 22:41:48  kja
--More monitoring schema.  Tweaked some sizes/syntax on previously added scripts.
--
--Revision 1.2  2004/04/12 18:39:20  kja
--Added current production row count for each table as a comment to aid in
--sizing requirements.
--
--
--$Id$
--
--
