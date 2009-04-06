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
rhnChannelDownloads
(
	channel_id	numeric
			not null 
			constraint rhn_cd_cid_fk
			references rhnChannel(id) on delete cascade,
	downloads_id	numeric
			not null
			constraint rhn_cd_did_fk
			references rhnDownloads(id),
	created		date default (current_date)
		        not null,
	modified	date default (current_date)
			not null,
                        constraint rhn_cd_ce_uq
                        unique(channel_id, downloads_id)
)
  ;

create index rhn_cd_did_cid_idx
	on rhnChannelDownloads(downloads_id, channel_id);

--
-- Revision 1.1  2003/08/04 17:20:54  bretm
-- bugzilla:  98685
--
-- tables + grants + synonyms for reorg of channel/iso downloadsx
--
