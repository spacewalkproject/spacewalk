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
create table
rhnChannelParent
(
        channel 	numeric 
			not null
   			constraint rhn_cp_ch_fk
			references rhnChannel(id) on delete cascade,
	parent_channel 	numeric
			not null
   			constraint rhn_cp_parent_ch_fk
                        references rhnChannel(id),
        created         date default (current_date)
                        not null,
        modified        date default (current_date)
                        not null,
                        constraint rhn_cp_c_uq
                        unique(channel, parent_channel) 
)
  ;

--
-- Revision 0.1 2007/07/18 13:33:00 shughes
-- initial version
