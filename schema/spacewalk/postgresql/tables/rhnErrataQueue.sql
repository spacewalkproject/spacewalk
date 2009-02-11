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
rhnErrataQueue
(
	errata_id		number not null
				constraint rhn_equeue_eid_fk
					references rhnErrata(id)
					on delete cascade,
	next_action		timestamp,
	created			timestamp default(current_timestamp) not null,
	modified		timestamp default(current_timestamp) not null,
	constraint rhn_equeue_eoid_uq unique ( errata_id )
)
;

create index rhn_equeue_eid_idx
	on rhnErrataQueue ( errata_id )
--	tablespace [[4m_tbs]]
  ;
	

create index rhn_equeue_na_eid_idx
	on rhnErrataQueue ( next_action, errata_id )
--	tablespace [[8m_tbs]]
  ;
