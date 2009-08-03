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
rhnDownloadType
(
	id		numeric
			constraint rhn_download_type_pk primary key,
	label		varchar(48)
			not null
                        constraint rhn_download_type_label_uq unique,
	name		varchar(96)
			not null
                        constraint rhn_download_type_name_uq unique
)
 ;
	

--
-- Revision 1.1  2003/08/04 17:20:54  bretm
-- bugzilla:  98685
--
-- tables + grants + synonyms for reorg of channel/iso downloadsx
--
