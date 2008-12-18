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

create table
rhnServerLock
(
        server_id       number
			constraint rhn_server_lock_sid_nn not null
                        constraint rhn_server_lock_sid_fk
				references rhnServer(id),
        locker_id       number
                        constraint rhn_server_lock_lid_fk
				references web_contact(id) on delete set null,
	reason          varchar2(4000),
        created         date default (sysdate)
			constraint rhn_server_lock_created_nn not null
)
	enable row movement
  ;

create unique index rhn_server_lock_sid_unq on
        rhnServerLock(server_id)
	tablespace [[4m_tbs]]
  ;

create index rhn_server_lock_lid_unq on
        rhnServerLock(locker_id)
	tablespace [[4m_tbs]]
  ;
