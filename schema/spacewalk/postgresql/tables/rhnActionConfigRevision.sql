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

create sequence rhn_actioncr_id_seq;

create table
rhnActionConfigRevision
(
	id			numeric not null
				constraint rhn_actioncr_id_pk primary key
--					using index tablespace [[2m_tbs]]
					,
	action_id		numeric not null
				constraint rhn_actioncr_aid_fk
					references rhnAction(id)
					on delete cascade,
	server_id		numeric not null
				constraint rhn_actioncr_sid_fk
					references rhnServer(id),
	-- we don't need the revision or the configchannel here,
	-- because they're derivable from config_revision_id
	config_revision_id	numeric not null
				constraint rhn_actioncr_crid_fk
					references rhnConfigRevision(id)
					on delete cascade,
        failure_id              numeric
				constraint rhn_actioncr_failid_fk
					references rhnConfigFileFailure(id),
	created			timestamp default(current_timestamp) not null,
	modified		timestamp default(current_timestamp) not null,

	constraint rhn_actioncr_aid_sid_crid_uq ( action_id, server_id, config_revision_id )
--		using index tablespace [[4m_tbs]]
);

create index rhn_actioncr_sid_aid_idx
	on rhnActionConfigRevision( server_id, action_id )
--	tablespace [[2m_tbs]]
  ;

create index rhn_act_cr_crid_idx
on rhnActionConfigRevision ( config_revision_id )
--        tablespace [[4m_tbs]]
;

