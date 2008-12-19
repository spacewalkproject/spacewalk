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

create table rhnServerNeededErrataCache
(
	org_id
			number
			constraint rhn_snec_oid_nn not null
			constraint rhn_snec_oid_fk
				references web_customer(id)
				on delete cascade,
	server_id	number
			constraint rhn_snec_sid_nn not null
			constraint rhn_snec_sid_fk
				references rhnServer(id)
				on delete cascade,
	errata_id	number
			constraint rhn_snec_eid_fk
				references rhnErrata(id)
				on delete cascade
)
	enable row movement
  ;

alter table rhnServerNeededErrataCache nologging;

create index rhn_snec_eid_sid_idx
	on rhnServerNeededErrataCache(errata_id, server_id)
	parallel 6
	tablespace [[128m_tbs]]
	nologging;

create index rhn_snec_sid_eid_idx
	on rhnServerNeededErrataCache(server_id, errata_id) 
	parallel 6
	tablespace [[128m_tbs]]
	nologging;

create index rhn_snec_oid_eid_sid_idx
	on rhnServerNeededErrataCache(org_id, errata_id, server_id)
	parallel 6
	tablespace [[128m_tbs]]
	nologging;

--
--
-- Revision 1.6  2004/07/12 22:44:58  pjones
-- bugzilla: 125938 -- fix constraint names
--
-- Revision 1.5  2004/07/12 22:41:35  pjones
-- bugzilla: 125938 -- create tables for errata cache
--
