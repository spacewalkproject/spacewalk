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
db_change_lock
(
	locked			char(1)
				constraint dc_lock_locked_nn not null,
	bug_id			number
				constraint dc_lock_bid_nn not null,
	seq_no			number
				constraint dc_lock_sn_nn not null,
	owner			varchar2(255)
				constraint dc_lock_owner_nn not null,
	lock_date		date
				constraint dc_lock_ld_nn not null
)
	storage ( freelists 16 )
	initrans 32;

COMMENT ON TABLE db_change_lock IS
	'DBCLK  Database change lock for synchronization ';

create unique index dc_lock_locked_uq
	on db_change_lock( locked )
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32;

--
-- $Log$
-- Revision 1.1  2004/05/24 21:49:37  pjones
-- bugzilla: none -- db change schema scripts
--
