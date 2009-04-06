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
rhnActionKickstartFileList
(
	action_ks_id		numeric not null
				constraint rhn_actionksfl_askid_fk
					references rhnActionKickstart(id)
					on delete cascade,
	file_list_id		numeric not null
				constraint rhn_actionksfl_flid_fk
					references rhnFileList(id)
					on delete cascade,
	created			timestamp default (current_timestamp) not null,
	modified		timestamp default (current_timestamp) not null,

	constraint rhn_actionksfl_aksid_flid_uq unique ( action_ks_id, file_list_id )
--		using index tablespace [[8m_tbs]]
);

create index rhn_actionksfl_flid_idx
	on rhnActionKickstartFileList( file_list_id )
--	tablespace [[4m_tbs]]
;

