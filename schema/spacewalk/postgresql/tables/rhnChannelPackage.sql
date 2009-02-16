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
--/

create table
rhnChannelPackage
(
	channel_id	numeric not null 
			constraint rhn_cp_cid_fk
				references rhnChannel(id) on delete cascade,
	package_id	numeric not null
			constraint rhn_cp_pid_fk
				references rhnPackage(id),
	created		timestamp default (current_timestamp) not null,
	modified	timestamp default (current_timestamp) not null,
			constraint rhn_cp_cp_uq unique (channel_id, package_id)
--			using tablespace [[64k_tbs]]
)
;

create index rhn_cp_pc_idx 
       on rhnChannelPackage(package_id, channel_id)
--       tablespace [[64k_tbs]]
       ;

--
-- Revision 1.16  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.15  2002/05/20 13:34:26  pjones
-- on delete cascade for rhnChannel foreign keys
--
-- Revision 1.14  2002/04/10 19:57:24  pjones
-- move triggers out of rhnChannelPackage.sql
--
-- Revision 1.13  2002/04/09 20:04:22  pjones
-- make rhnChannelErrata accurate with triggers instead of just occasionally
-- getting it right.  Also should support delete of packages/channels/errata
-- now
--
-- Revision 1.12  2002/03/19 22:41:30  pjones
-- index tablespace names to match current dev/qa/prod (rhn_ind_xxx)
--
-- Revision 1.11  2002/02/21 16:27:19  pjones
-- rhn_ind -> [[64k_tbs]]
-- rhn_ind_02 -> [[server_package_index_tablespace]]
-- rhn_tbs_02 -> [[server_package_tablespace]]
--
-- for perl-Satcon so satellite can be created more directly.
--
-- Revision 1.10  2001/11/08 18:46:39  pjones
-- slightly more readable way
--
-- Revision 1.9  2001/11/08 18:35:11  pjones
-- this should fix the race condition between 2 errata updating a channel
-- during the same second.  I think.
--
-- Revision 1.8  2001/09/14 03:32:28  cturner
-- adding an index for package_id,channel_id in rhnChannelPackage
--
-- Revision 1.7  2001/09/06 17:39:19  pjones
-- fixed trigger bug.  Oracle should _ERROR_ on this case.
--
-- Revision 1.6  2001/07/03 23:41:17  pjones
-- change unique constraints to unique indexes
-- move to something like a single postfix for uniques (_uq)
-- try to compensate for bad style
--
-- Revision 1.5  2001/07/01 17:40:22  cturner
-- renaming rhn*PackageObj to rhn*Package.  more work on conversions.
--
-- Revision 1.4  2001/07/01 05:22:00  gafton
-- named constraints
--
-- Revision 1.3  2001/06/27 05:04:35  pjones
-- this makes tables work
--
-- Revision 1.2  2001/06/27 02:03:01  pjones
-- triggers and indexes
--
-- Revision 1.1  2001/06/27 02:00:55  pjones
-- channel stuff, initial checkin
