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

create table rhnServerNeededCache
(
	server_id	number
			constraint rhn_sncp_sid_nn not null
			constraint rhn_sncp_sid_fk
				references rhnServer(id)
				on delete cascade,
	errata_id	number
			constraint rhn_sncp_eid_fk
				references rhnErrata(id)
				on delete cascade,
	package_id	number
			constraint rhn_sncp_pid_nn not null
			constraint rhn_sncp_pid_fk
				references rhnPackage(id)
				on delete cascade
)
	enable row movement
	nologging;

create index rhn_snc_pid_idx
	on rhnServerNeededCache(package_id)
	parallel
	tablespace [[128m_tbs]]
	nologging;

create index rhn_snc_sid_idx
	on rhnServerNeededCache(server_id)
	parallel
	tablespace [[128m_tbs]]
	nologging;

create index rhn_snc_eid_idx
	on rhnServerNeededCache(errata_id)
	parallel
	tablespace [[128m_tbs]]
	nologging;

--
-- Revision 1.24  2004/09/13 20:56:44  pjones
-- bugzilla: 117597 --
-- 1) make the constraints look like they do in prod.
-- 2) remove the sat-only errata_id index
-- 3) remove duplicate server_id based index.
-- 4) make a new index that starts with errata
--
-- Revision 1.23  2003/09/17 15:28:32  pjones
-- bugzilla: none
--
-- move the [errata_id, server_id] index to only being on sat environments
--
-- Revision 1.22  2003/08/20 14:48:45  pjones
-- bugzilla: 102263
--
-- change the rhnServerNeededPackageCache index
--
-- Revision 1.21  2003/08/19 14:51:51  uid2174
-- bugzilla: 102263
--
-- indices
--
-- Revision 1.20  2003/08/14 19:59:07  pjones
-- bugzilla: none
--
-- reformat "on delete cascade" on things that reference rhnErrata*
--
-- Revision 1.19  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.18  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
