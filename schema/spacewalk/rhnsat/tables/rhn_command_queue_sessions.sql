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
    contact_id          number   (12)
        constraint rhn_cqses_contact_id_nn not null,
    session_id          varchar2 (255),
    expiration_date     date,
    last_update_user    varchar2 (40),        
    last_update_date    date
)  
    storage ( freelists 16 )
    enable row movement
    initrans 32;

comment on table rhn_command_queue_sessions 
    is 'cqses  command queue sessions';

create unique index rhn_cqses_cid_uq
	on rhn_command_queue_sessions( contact_id )
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32;

alter table rhn_command_queue_sessions
    add constraint rhn_cqses_cntct_contact_idfk
    foreign key ( contact_id )
    references web_contact( id );

--
--Revision 1.4  2004/05/28 22:27:32  pjones
--bugzilla: none -- audit usage of rhnServer/web_contact/web_customer in
--monitoring schema
--
--Revision 1.3  2004/04/28 23:10:52  kja
--Moving foreign keys where applicable and no circular dependencies exist.
--
--Revision 1.2  2004/04/16 21:49:57  kja
--Adjusted small table sizes.  Documented small tables that are primarily static
--as "reference tables."  Fixed up a few syntactical errs.
--
--Revision 1.1  2004/04/12 22:41:48  kja
--More monitoring schema.  Tweaked some sizes/syntax on previously added scripts.
--
--
--
--
--
