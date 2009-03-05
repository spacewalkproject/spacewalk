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
rhnPrivateChannelFamily
(
	channel_family_id	numeric not null 
				constraint rhn_privcf_cfid_fk
					references rhnChannelFamily(id),
	org_id			numeric not null
				constraint rhn_privcf_oid_fk
					references web_customer(id)
					on delete cascade,
	max_members		numeric,
	current_members		numeric default (0) not null,
	created			timestamp default (current_timestamp) not null,
	modified		timestamp default (current_timestamp) not null,
				constraint rhn_privcf_oid_cfid_uq unique (org_id, channel_family_id)
--				using tablespace [[2m_tbs]]
)
;

create index rhn_cfperm_cfid_oid_idx on
	rhnPrivateChannelFamily( channel_family_id, org_id )
--	tablespace [[2m_tbs]]
;

--
--
-- Revision 1.1  2004/04/14 00:09:24  pjones
-- bugzilla: 120761 -- split rhnChannelPermissions into two tables, eliminating
-- a frequent full table scan
--
