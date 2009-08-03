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
rhnActionConfigChannel
(
	action_id		numeric not null
				constraint rhn_actioncc_aid_fk
					references rhnAction(id)
					on delete cascade,
	server_id		numeric not null
				constraint rhn_actioncc_sid_fk
					references rhnServer(id),
        config_channel_id       numeric not null
				constraint rhn_actioncc_ccid_fk
					references rhnConfigChannel(id)
						on delete cascade,
	created			timestamp default(current_timestamp) not null,
	modified		timestamp default(current_timestamp) not null,

	constraint rhn_actioncc_sid_aid_fk foreign key (server_id, action_id)
		references rhnServerAction(server_id, action_id)
			on delete cascade,

	constraint rhn_actioncc_aid_sid_uq unique ( action_id, server_id )
--		using index tablespace [[4m_tbs]]
);

create index rhn_actioncc_sid_aid_ccid_idx
	on rhnActionConfigChannel ( server_id, action_id, config_channel_id )
--	tablespace [[4m_tbs]]
;

create index rhn_act_cc_ccid_aid_sid_idx
on rhnActionConfigChannel (config_channel_id, action_id, server_id)
--        tablespace [[4m_tbs]]
;
