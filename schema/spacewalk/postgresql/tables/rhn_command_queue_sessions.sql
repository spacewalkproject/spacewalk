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

--command_queue_sessions current prod row count = 9
create table 
rhn_command_queue_sessions
(
    contact_id          numeric   (12) not null,
    session_id          varchar (255),
    expiration_date     timestamp,
    last_update_user    varchar (40),        
    last_update_date    timestamp,
    constraint rhn_cqses_cntct_contact_idfk foreign key ( contact_id ) references web_contact( id )
)  
--    enable row movement
  ;

comment on table rhn_command_queue_sessions 
    is 'cqses  command queue sessions';

create unique index rhn_cqses_cid_uq
	on rhn_command_queue_sessions( contact_id )
--	tablespace [[4m_tbs]]
  ;

--alter table rhn_command_queue_sessions
--    add constraint rhn_cqses_cntct_contact_idfk
--    foreign key ( contact_id )
--    references web_contact( id );

