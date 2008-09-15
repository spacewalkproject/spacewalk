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

--os_commands_xref current prod row count = 935

create table 
rhn_os_commands_xref
(
    os_id           number   (12)
        constraint rhn_oscxr_os_id_nn not null,
    commands_id     number   (12)
        constraint rhn_oscxr_commands_id_nn not null
)
    storage ( freelists 16 )
    enable row movement
    initrans 32;

comment on table rhn_os_commands_xref 
    is 'oscxr  operating systems - commands cross ref';

create unique index rhn_oscxr_os_id_commands_id_pk 
    on rhn_os_commands_xref ( os_id, commands_id )
    tablespace [[2m_tbs]]
    storage ( freelists 16 )
    initrans 32;

alter table rhn_os_commands_xref 
    add constraint rhn_oscxr_os_id_commands_id_pk 
    primary key ( os_id, commands_id );

alter table rhn_os_commands_xref
    add constraint rhn_oscxr_cmmnd_commands_id_fk
    foreign key ( commands_id )
    references rhn_command( recid );

alter table rhn_os_commands_xref
    add constraint rhn_oscxr_os000_os_id_fk
    foreign key ( os_id )
    references rhn_os( recid );

--$Log$
--Revision 1.4  2004/05/06 17:35:10  kja
--More syntax/identifier length changes.
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
--$Id$
--
--
