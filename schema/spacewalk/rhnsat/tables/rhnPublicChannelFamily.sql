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
rhnPublicChannelFamily
(
	channel_family_id	number
				constraint rhn_pubcf_cfid_nn not null
				constraint rhn_pubcf_cfid_fk
					references rhnChannelFamily(id),
	created			date default(sysdate)
				constraint rhn_pubcf_creat_nn not null,
	modified		date default(sysdate)
				constraint rhn_pubcf_mod_nn not null
)
	enable row movement
;

create unique index rhn_pubcf_co_uq on
	rhnPublicChannelFamily(channel_family_id)
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;

--
--
-- Revision 1.1  2004/04/14 00:09:24  pjones
-- bugzilla: 120761 -- split rhnChannelPermissions into two tables, eliminating
-- a frequent full table scan
--
