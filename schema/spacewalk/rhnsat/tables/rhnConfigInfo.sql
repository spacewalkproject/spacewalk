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

create sequence rhn_confinfo_id_seq;

create table
rhnConfigInfo
(
	id			number
				constraint rhn_confinfo_id_nn not null
				constraint rhn_confinfo_id_pk primary key
					using index tablespace [[2m_tbs]],
	username		varchar2(32)
				constraint rhn_confinfo_username_nn not null,
	groupname		varchar2(32)
				constraint rhn_confinfo_groupname_nn not null,
	filemode		number
				constraint rhn_confinfo_filemode_nn not null,
	created			date default(sysdate)
				constraint rhn_confinfo_creat_nn not null,
	modified		date default(sysdate)
				constraint rhn_confinfo_mod_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create unique index rhn_confinfo_ugf_uq
	on rhnConfigInfo( username, groupname, filemode )
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_confinfo_mod_trig
before insert or update on rhnConfigInfo
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

--
-- $Log$
-- Revision 1.1  2003/11/07 18:05:42  pjones
-- bugzilla: 109083
-- kill old config file schema (currently just an exclude except for
--   rhnConfigFile which is replaced)
-- exclude the snapshot stuff, and comment it from triggers and procs
-- more to come, but the basic config file stuff is in.
--
