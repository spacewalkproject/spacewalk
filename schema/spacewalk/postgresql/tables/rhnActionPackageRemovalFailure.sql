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
-- this logs failures of actions which involve package removals

-- *bretm* def submit(self, system_id, action_id, result, message="", data={}):
-- *bretm* where data i believe is the stuff the client sends you.

-- maybe this shouldn't be constraint to removal, but that's
-- what we've got right now

create table
rhnActionPackageRemovalFailure
(
	server_id		numeric not null
				constraint rhn_apr_failure_sid_fk
					references rhnServer(id),
	action_id		numeric not null
				constraint rhn_apr_failure_aid_fk
					references rhnAction(id)
					on delete cascade,
	name_id			numeric not null
				constraint rhn_apr_failure_nid_fk
					references rhnPackageName(id),
	evr_id			numeric not null
				constraint rhn_apr_failure_eid_fk
					references rhnPackageEVR(id),
	capability_id		numeric not null
				constraint rhn_apr_failure_capid_fk
					references rhnPackageCapability(id),
	flags			numeric not null,
	suggested		numeric
				constraint rhn_apr_failure_suggested_fk
					references rhnPackageName(id),
	sense			numeric not null
);

create index rhn_apr_failure_aid_sid_idx
	on rhnActionPackageRemovalFailure( action_id, server_id )
--	tablespace [[4m_tbs]]
;

create index rhn_apr_failure_sid_idx
	on rhnActionPackageRemovalFailure( server_id )
--	tablespace [[4m_tbs]]
;

