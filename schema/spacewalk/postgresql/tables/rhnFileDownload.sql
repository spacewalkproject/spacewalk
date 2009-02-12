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
-- this keeps track of when a file has been downloaded

create table
rhnFileDownload
(
	file_id			numeric
				not null
				constraint rhn_filedl_fid_fk
				references rhnFile(id),
	location		varchar(2000)
				not null,
	token			varchar(48),
	requestor_ip		varchar(15)
				not null,
	start_time		date default(sysdate)
				not null,
	user_id			number
				constraint rhn_filedl_uid_fk
				references web_contact(id)
				on delete set null
)
  ;

create index rhn_filedl_uid_fid_idx
	on rhnFileDownload ( user_id, file_id )
--	tablespace [[4m_tbs]]
  ;

create index rhn_filedl_token_idx
	on rhnFileDownload ( token )
--	tablespace [[8m_tbs]]
  ;

create index rhn_filedl_start_idx
        on rhnFileDownload ( start_time )
--        tablespace [[8m_tbs]]
  ;

--
-- Revision 1.4  2003/12/02 21:47:31  cturner
-- add index on file download log... who would have thought it would actually have much data
--
-- Revision 1.3  2003/04/02 17:18:20  pjones
-- Kill the not nulls on things we're setting null.
--
-- Revision 1.2  2003/04/02 17:00:04  pjones
-- bugzilla: none
--
-- fix some spots we missed on user del path.
--
-- To find these, do
--
-- select table_name, constraint_name, delete_rule from all_constraints
-- where r_constraint_name = 'WEB_CONTACT_PK'
--         and delete_rule not in ('CASCADE','SET NULL')
--
-- Note that right now in webqa and web there's a "WEB_UBERBLOB" table that's
-- not got the constraints that live does.  how quaint.
--
-- Revision 1.1  2003/03/24 22:35:14  pjones
-- rhnFileDownload, to track files downloaded (i.e. instant iso downloads)
--
