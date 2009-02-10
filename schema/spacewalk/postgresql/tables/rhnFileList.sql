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

create sequence rhn_filelist_id_seq;

create table
rhnFileList
(
	id		numeric not null
			constraint rhn_filelist_id_pk primary key
--				using index tablespace [[4m_tbs]],
	label		varchar(128) not null,
	org_id		numeric not null
			constraint rhn_filelist_oid_fk
				references web_customer(id),
	created		timestamp default (current_timestamp) not null,
	modified	timestamp default (current_timestamp) not null,
			constraint rhn_filelist_oid_l_uq unique ( org_id, label )
--        		tablespace [[8m_tbs]]
)
  ;

/*
create or replace trigger
rhn_filelist_mod_trig
before insert or update on rhnFileList
for each row
begin
	:new.modified := sysdate;
end rhn_filelist_mod_trig;
/
show errors
*/
--
--
-- Revision 1.1  2004/05/25 02:25:34  pjones
-- bugzilla: 123426 -- tables in which to keep lists of files to be preserved.
--
