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
	errata_id		number
				constraint rhn_equeue_eid_nn not null
				constraint rhn_equeue_eid_fk
					references rhnErrata(id)
					on delete cascade,
        channel_id              number
                                constraint rhn_equeue_cid_nn not null
                                constraint rhn_equeue_cid_fk
                                references rhnChannel(id)
                                on delete cascade,
	next_action		date,
	created			date default(sysdate)
				constraint rhn_equeue_created_nn not null,
	modified		date default(sysdate)
				constraint rhn_equeue_modified_nn not null
)
	enable row movement
  ;

create index rhn_equeue_eid_idx
	on rhnErrataQueue ( errata_id )
	tablespace [[4m_tbs]]
  ;

create index rhn_equeue_na_eid_idx
	on rhnErrataQueue ( next_action, errata_id )
	tablespace [[8m_tbs]]
  ;
