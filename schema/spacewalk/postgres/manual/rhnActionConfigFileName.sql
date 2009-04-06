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
rhnActionConfigFileName
(
	action_id		numeric not null,
	server_id		numeric not null,
	config_file_name_id	numeric not null
				constraint rhn_actioncf_name_cfnid_fk
					references rhnConfigFileName(id),
	config_revision_id	numeric
				constraint rhn_actioncf_name_crid_fk
					references rhnConfigRevision(id)
					on delete set null,
	failure_id		numeric
				constraint rhn_actioncf_failure_id_fk
					references rhnConfigFileFailure(id),
	created			timestamp default(current_timestamp) not null,
	modified		timestamp default(current_timestamp) not null,

	constraint rhn_actioncf_name_aid_sid_fk foreign key ( server_id, action_id )
		references rhnServerAction( server_id, action_id ) on delete cascade,

	constraint rhn_actioncf_name_asc_uq unique ( action_id, server_id, config_file_name_id )
--		using index tablespace [[2m_tbs]]
		,

	constraint rhn_actioncf_name_sac_uq unique ( server_id, action_id, config_file_name_id )
--		using index  tablespace [[2m_tbs]]

);

create index rhn_act_cnfg_fn_crid_idx
on rhnActionConfigFileName ( config_revision_id )
--        tablespace [[2m_tbs]]
;

