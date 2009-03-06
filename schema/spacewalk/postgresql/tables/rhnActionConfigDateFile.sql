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
rhnActionConfigDateFile
(
	action_id		numeric not null
				constraint rhn_actioncd_file_aid_fk
					references rhnAction(id)
					on delete cascade,
	file_name		varchar(512) not null,
	-- I could make this a lookup table, if anybody wants me to.
	-- right now it's 'W' for whitelist, 'B' for blacklist.
	file_type		char(1) not null
				constraint rhn_actioncd_file_ft_ck
					check (file_type in ('W','B')),
	created			timestamp default(current_timestamp) not null,
	modified		timestamp default(current_timestamp) not null
);

create index rhn_actioncd_file_aid_fn_idx
	on rhnActionConfigDateFile(action_id, file_name)
--	tablespace [[4m_tbs]]
;

