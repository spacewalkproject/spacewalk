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

create sequence rhn_actscript_id_seq;

create table
rhnActionScript
(
	id		numeric not null
			constraint rhn_actscript_id_pk primary key
--				using index tablespace [[4m_tbs]]
				,
	action_id	numeric not null
			constraint rhn_actscript_aid_uq_idx unique
--				using index tablespace [[4m_tbs]]
			constraint rhn_actscript_aid_fk
				references rhnAction(id)
				on delete cascade,
	username	varchar(32) not null,
	groupname	varchar(32) not null,
	script		bytea,
	timeout		numeric,
	created		timestamp default(current_timestamp) not null,
	modified	timestamp default(current_timestamp) not null
)
--	tablespace [[blob]]
;

