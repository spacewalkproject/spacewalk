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

create sequence rhn_confchan_id_seq;

create table
rhnConfigChannel
(
	id			number
				constraint rhn_confchan_id_nn not null
				constraint rhn_confchan_id_pk primary key
					using index tablespace [[2m_tbs]],
	org_id			number
				constraint rhn_confchan_oid_nn not null
				constraint rhn_confchan_oid_fk
					references web_customer(id),
	confchan_type_id	number
				constraint rhn_confchan_ctid_nn not null
				constraint rhn_confchan_ctid_fk
					references rhnConfigChannelType(id),
	name			varchar2(128)
				constraint rhn_confchan_name_nn not null,
	label			varchar2(64)
				constraint rhn_confchan_label_nn not null,
	description		varchar2(1024)
				constraint rhn_confchan_desc_nn not null,
	created			date default(sysdate)
				constraint rhn_confchan_creat_nn not null,
	modified		date default(sysdate)
				constraint rhn_confchan_mod_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create unique index rhn_confchan_oid_label_type_uq
	on rhnConfigChannel( org_id, label, confchan_type_id )
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32;

--
--
-- Revision 1.4  2003/12/08 19:16:21  cturner
-- bugzilla: 111512, give config channels labels, too
--
-- Revision 1.3  2003/11/11 16:57:45  pjones
-- bugzilla: none -- index should be unique
--
-- Revision 1.2  2003/11/09 18:18:03  pjones
-- bugzilla: 109083 -- triggers for snapshot invalidation on confchan change
-- bugfix in server group snapshot invalidation
--
-- Revision 1.1  2003/11/07 18:05:42  pjones
-- bugzilla: 109083
-- kill old config file schema (currently just an exclude except for
--   rhnConfigFile which is replaced)
-- exclude the snapshot stuff, and comment it from triggers and procs
-- more to come, but the basic config file stuff is in.
--
