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
rhnDailySummaryQueue
(
	org_id		numeric
			not null
                        constraint rhn_dsqueue_oid_uq unique
             		constraint rhn_dsqueue_oid_fk
			references web_customer(id),
	created		date default(current_date)
			not null,
	modified	date default(current_date)
			not null
)
  ;

create index rhn_dsqueue_oid_idx
	on rhnDailySummaryQueue ( org_id )
--	tablespace [[2m_tbs]]
  ;
	

--
-- Revision 1.1  2003/03/19 17:22:23  pjones
-- daily summary queue for bretm
--
