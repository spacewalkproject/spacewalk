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

