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
rhnFileLocation
(
	file_id 	number
			constraint rhn_fileloc_fid_nn not null
			constraint rhn_fileloc_fid_fk
			     	references rhnFile(id),
        location        varchar2(128)
	    	    	constraint rhn_fileloc_loc_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create unique index rhn_fileloc_file_loc_uq
	on rhnFileLocation(file_id, location)
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;
