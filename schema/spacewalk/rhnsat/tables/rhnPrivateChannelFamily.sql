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

create table
rhnPrivateChannelFamily
(
	channel_family_id	number
				constraint rhn_privcf_cfid_nn not null 
				constraint rhn_privcf_cfid_fk
					references rhnChannelFamily(id),
	org_id			number
				constraint rhn_privcf_oid_nn not null
				constraint rhn_privcf_oid_fk
					references web_customer(id)
					on delete cascade,
	max_members		number,
	current_members		number default (0)
				constraint rhn_privcf_curmembers_nn not null,
	created			date default (sysdate)
				constraint rhn_privcf_created_nn not null,
	modified		date default (sysdate)
				constraint rhn_privcf_modified_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create unique index rhn_privcf_oid_cfid_uq
	on rhnPrivateChannelFamily( org_id, channel_family_id )
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create index rhn_cfperm_cfid_oid_idx on
	rhnPrivateChannelFamily( channel_family_id, org_id )
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32
	nologging;

--
-- $Log$
-- Revision 1.1  2004/04/14 00:09:24  pjones
-- bugzilla: 120761 -- split rhnChannelPermissions into two tables, eliminating
-- a frequent full table scan
--
