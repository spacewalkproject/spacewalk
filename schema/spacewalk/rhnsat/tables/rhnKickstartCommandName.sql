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
-- $Id$
--

create table
rhnKickstartCommandName
(
        id              number
            			constraint rhn_kscommandname_id_nn not null
                        constraint rhn_kscommandname_id_pk primary key
        				using index tablespace [[2m_tbs]],
        name            varchar2(128)
		            	constraint rhn_kscommand_name_nn not null,
        uses_arguments  char(1)
                        constraint rhn_kscommandname_uses_args_nn not null
                        constraint rhn_kscommandname_uses_args_ck 
                        check (uses_arguments in ('Y','N')),
        sort_order      number
                        constraint rhn_kscommandname_sortordr_nn not null,
        required        char(1) default 'N'
                        constraint rhn_kscommandname_reqrd_nn not null
                        constraint rhn_kscommandname_reqrd_ck
                            check ( required in ('Y', 'N') )
)

	storage ( freelists 16 )
	enable row movement
	initrans 32;

create sequence rhn_kscommandname_id_seq;

create index rhn_kscommandname_name_id_idx
	on rhnKickstartCommandName( name, id )
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnKickstartCommandName add constraint rhn_kscommandname_name_uq
	unique ( name );

--
-- $Log$
-- Revision 1.1  2003/09/11 20:55:42  pjones
-- bugzilla: 104231
--
-- tables to handle kickstart data
--
