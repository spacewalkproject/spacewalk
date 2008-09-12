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
-- this logs failures of actions which involve package removals

-- *bretm* def submit(self, system_id, action_id, result, message="", data={}):
-- *bretm* where data i believe is the stuff the client sends you.

-- maybe this shouldn't be constraint to removal, but that's
-- what we've got right now

create table
rhnActionPackageRemovalFailure
(
	server_id		number
				constraint rhn_apr_failure_sid_nn not null
				constraint rhn_apr_failure_sid_fk
					references rhnServer(id),
	action_id		number
				constraint rhn_apr_failure_aid_nn not null
				constraint rhn_apr_failure_aid_fk
					references rhnAction(id)
					on delete cascade,
	name_id			number
				constraint rhn_apr_failure_nid_nn not null
				constraint rhn_apr_failure_nid_fk
					references rhnPackageName(id),
	evr_id			number
				constraint rhn_apr_failure_eid_nn not null
				constraint rhn_apr_failure_eid_fk
					references rhnPackageEVR(id),
	capability_id		number
				constraint rhn_apr_failure_capid_nn not null
				constraint rhn_apr_failure_capid_fk
					references rhnPackageCapability(id),
	flags			number
				constraint rhn_apr_failure_flags_nn not null,
	suggested		number
				constraint rhn_apr_failure_suggested_fk
					references rhnPackageName(id),
	sense			number
				constraint rhn_apr_failure_sense_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create index rhn_apr_failure_aid_sid_idx
	on rhnActionPackageRemovalFailure( action_id, server_id )
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create index rhn_apr_failure_sid_idx
	on rhnActionPackageRemovalFailure( server_id )
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32;

-- $Log$
-- Revision 1.6  2004/02/24 17:35:42  pjones
-- bugzilla: none -- fix rhnActionPackageRemovalFailure to be removed properly
-- with rhnServer; also add rhnServerActionPackageResult and
-- rhnServerActionScriptResult to be deleted.
--
-- Revision 1.5  2004/02/09 16:38:38  pjones
-- bugzilla: 115049 -- rework delete_server to be driven from the pl/sql instead
-- of with cascaded deletes
--
-- Revision 1.4  2003/08/25 14:59:44  pjones
-- bugzilla: none
--
-- fix rhnAction cascades
--
-- Revision 1.3  2003/03/03 16:46:51  misa
-- bugzilla: 83674  Reworked the schema for package removal
--
-- Revision 1.2  2003/02/28 18:38:34  pjones
-- kill bogus not null
--
-- Revision 1.1  2003/02/26 15:50:05  pjones
-- log for package removal failures
--
