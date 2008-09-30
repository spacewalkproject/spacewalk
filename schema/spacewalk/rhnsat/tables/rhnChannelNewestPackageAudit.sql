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
-- An audit trail for when we populated rhnCannelNewestPackage
create table
rhnChannelNewestPackageAudit
(
        refresh_time            date default sysdate
                                constraint rhn_cnp_at_rt_nn not null,
	channel_id		number
				constraint rhn_cnp_at_cid_nn not null
				constraint rhn_cnp_at_cid_fk
					references rhnChannel(id)
                                        on delete cascade,
        caller                  varchar2(256)
                                constraint rhn_cnp_at_caller_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create index rhn_cnp_a_t_all_idx
	on rhnChannelNewestPackageAudit(channel_id, refresh_time, caller)
	tablespace [[8m_tbs]]
	storage ( freelists 16 )
	initrans 32;

-- $Log$
-- Revision 1.2  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.1  2002/12/19 17:33:05  misa
-- Added audit trail for rhnChannelNewestPackage
--
