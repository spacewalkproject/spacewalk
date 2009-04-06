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

create sequence rhn_actionks_id_seq;

create table
rhnActionKickstart
(
	id			numeric not null
				constraint rhn_actionks_aid_uq unique
--					using index tablespace [[8m_tbs]]
				constraint rhn_actionks_id_pk
					primary key,
	action_id		numeric not null
				constraint rhn_actionks_aid_fk
					references rhnAction(id)
					on delete cascade,
	append_string		varchar(1024),
	kickstart_host		varchar(256),
	static_device           varchar(32),
	created			timestamp default(current_timestamp) not null,
	modified		timestamp default(current_timestamp) not null
);

create index rhn_actionks_id_idx
	on rhnActionKickstart( id )
--	tablespace [[4m_tbs]]
;

