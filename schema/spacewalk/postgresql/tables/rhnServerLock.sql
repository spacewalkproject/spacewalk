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
        server_id       numeric not null
                        constraint rhn_server_lock_sid_fk
				references rhnServer(id)
			constraint rhn_server_lock_sid_unq unique, 
--		      	using index tablespace [[4m_tbs]]
        locker_id       numeric
                        constraint rhn_server_lock_lid_fk
				references web_contact(id) on delete set null,
	reason          varchar(4000),
        created         timestamp default (current_timestamp) not null
)
  ;

create index rhn_server_lock_lid_unq on
        rhnServerLock(locker_id)
--	tablespace [[4m_tbs]]
  ;
