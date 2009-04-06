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
rhnRegTokenConfigChannels
(
	token_id		numeric not null
				constraint rhn_regtok_confchan_tid_fk
					references rhnRegToken(id)
					on delete cascade,
	config_channel_id	numeric not null
				constraint rhn_regtok_confchan_ccid_fk
					references rhnConfigChannel(id)
					on delete cascade,
	position		numeric not null
)
;

create unique index rhn_regtok_confchan_t_cc_uq
	on rhnRegTokenConfigChannels( token_id, config_channel_id )
--	tablespace [[4m_tbs]]
  ;

create index rhn_regtok_confchan_ccid_idx
	on rhnRegTokenConfigChannels( config_channel_id )
--	tablespace [[2m_tbs]]
  ;

