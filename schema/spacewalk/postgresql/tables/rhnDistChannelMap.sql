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
rhnDistChannelMap 
(
	os		varchar(64)
			not null,
	release		varchar(64)
			not null,
	channel_arch_id	numeric
			not null
			constraint rhn_dcm_caid_fk
			references rhnChannelArch(id),
	channel_id	numeric
			not null 
			constraint rhn_dcm_cid_fk
			references rhnChannel(id) on delete cascade,
                        constraint rhn_dcm_os_release_caid_uq
                        unique ( os, release, channel_arch_id )
)
  ;

create index rhn_dcm_os_release_caid_idx
	on rhnDistChannelMap(os, release, channel_arch_id)
--	tablespace [[64k_tbs]]
  ;

--
-- Revision 1.17  2003/02/26 21:56:34  pjones
-- change the uniqueness on rhnDistChannelMap; this is breaking UBS's case
-- where Ian has added duplicate entries by hand
--
-- Revision 1.16  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.15  2002/11/14 17:31:37  pjones
-- more arch changes -- remove the old fields
--
-- Revision 1.14  2002/11/13 22:45:20  pjones
-- add appropriate arch fields.
-- haven't deleted the old ones yet though
--
-- Revision 1.13  2002/11/13 00:46:41  misa
-- Fix rhnDistChannelMap, while we're at it
--
-- Revision 1.12  2002/05/20 13:34:26  pjones
-- on delete cascade for rhnChannel foreign keys
--
-- Revision 1.11  2002/03/19 22:41:31  pjones
-- index tablespace names to match current dev/qa/prod (rhn_ind_xxx)
--
-- Revision 1.10  2002/03/08 23:01:05  pjones
-- split imports out into seperate files
--
-- Revision 1.9  2002/02/26 17:40:37  misa
-- missing foreign key for channel_id
--
-- Revision 1.8  2002/02/21 16:27:19  pjones
-- rhn_ind -> [[64k_tbs]]
-- rhn_ind_02 -> [[server_package_index_tablespace]]
-- rhn_tbs_02 -> [[server_package_tablespace]]
--
-- for perl-Satcon so satellite can be created more directly.
--
-- Revision 1.7  2001/10/17 19:11:53  pjones
-- 7.2
--
-- Revision 1.6  2001/10/16 21:15:14  pjones
-- add ia64
--
-- Revision 1.5  2001/07/03 23:41:17  pjones
-- change unique constraints to unique indexes
-- move to something like a single postfix for uniques (_uq)
-- try to compensate for bad style
--
-- Revision 1.4  2001/07/01 06:16:56  gafton
-- named constraints, dammit.
--
-- Revision 1.3  2001/07/01 01:45:02  gafton
-- commit inserts
--
-- Revision 1.2  2001/06/27 05:04:35  pjones
-- this makes tables work
--
-- Revision 1.1  2001/06/27 02:00:55  pjones
-- channel stuff, initial checkin
