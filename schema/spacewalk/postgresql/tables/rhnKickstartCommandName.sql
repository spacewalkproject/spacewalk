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

create table
rhnKickstartCommandName
(
        id              numeric
            		constraint rhn_kscommandname_id_pk primary key
--        		using index tablespace [[2m_tbs]]
                        ,
        name            varchar(128)
		        not null
                        constraint rhn_kscommandname_name_uq unique,
        uses_arguments  char(1)
                        not null
                        constraint rhn_kscommandname_uses_args_ck 
                        check (uses_arguments in ('Y','N')),
        sort_order      numeric
                        not null,
        required        char(1) default 'N'
                        not null
                        constraint rhn_kscommandname_reqrd_ck
                            check ( required in ('Y', 'N') )
)
  ;

create sequence rhn_kscommandname_id_seq;

create index rhn_kscommandname_name_id_idx
	on rhnKickstartCommandName( name, id )
--	tablespace [[2m_tbs]]
  ;

--
--
-- Revision 1.1  2003/09/11 20:55:42  pjones
-- bugzilla: 104231
--
-- tables to handle kickstart data
--
