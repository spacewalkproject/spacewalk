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
rhnDownloadType
(
	id		number
			constraint rhn_download_type_id_nn not null
			constraint rhn_download_type_pk primary key,
	label		varchar2(48)
			constraint rhn_download_type_label_nn not null,
	name		varchar2(96)
			constraint rhn_download_type_name_nn not null
);
	
create unique index rhn_download_type_label_uq
	on rhnDownloadType(label);
create unique index rhn_download_type_name_uq
	on rhnDownloadType(name);

-- $Log$
-- Revision 1.1  2003/08/04 17:20:54  bretm
-- bugzilla:  98685
--
-- tables + grants + synonyms for reorg of channel/iso downloadsx
--
