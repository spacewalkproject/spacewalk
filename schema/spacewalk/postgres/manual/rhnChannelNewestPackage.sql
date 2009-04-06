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
-- A cache of the newest package in a channel.  This should *really* be
-- a materialized view, and the function to recreate it should just call
-- the refresh view calls, but alas...

-- No created/modified, it's really just a cache.  If you want to
-- know when it got there, look in rhnChannelPackage .
create table
rhnChannelNewestPackage
(
	channel_id		numeric
				not null
				constraint rhn_cnp_cid_fk
				references rhnChannel(id)
				on delete cascade,
	name_id			numeric
				not null
				constraint rhn_cnp_nid_fk
				references rhnPackageName(id),
	evr_id			numeric
				not null
				constraint rhn_cnp_eid_fk
				references rhnPackageEVR(id),
	package_arch_id		numeric
				not null
				constraint rhn_cnp_paid_fk
				references rhnPackageArch(id),
	package_id		numeric
				not null
				constraint rhn_cnp_pid_fk
				references rhnPackage(id)
				on delete cascade,
                                constraint rhn_cnp_cid_nid_uq 
                                unique( channel_id, name_id, package_arch_id )
)
  ;

create index rhn_cnp_cnep_idx
	on rhnChannelNewestPackage(channel_id, name_id, 
		package_arch_id, evr_id, package_id)
--	tablespace [[8m_tbs]]
  ;

create index rhn_cnp_necp_idx
	on rhnChannelNewestPackage(name_id, evr_id, channel_id, package_id)
--	tablespace [[8m_tbs]]
  ;

-- robin wants this so that deletion of packages is quicker
create index rhn_cnp_pid_idx
	on rhnChannelNewestPackage( package_id )
--	tablespace [[2m_tbs]]
  ;

--
-- Revision 1.6  2003/03/18 20:33:45  pjones
-- make package deletion faster
--
-- Revision 1.5  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.4  2002/12/15 06:05:19  pjones
-- formatting
--
-- Revision 1.3  2002/12/14 21:20:09  misa
-- Added on delete cascade for the package and channel constraints
--
-- Revision 1.2  2002/12/11 22:18:46  pjones
-- rhnChannelNewestPackage
--
-- Revision 1.1  2002/12/10 21:02:18  pjones
-- add the newest package cache.
-- TODO: population function; should also be for
-- changes/dev/rhnChannelNewestPackage
--
